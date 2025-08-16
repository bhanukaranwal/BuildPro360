from fastapi import FastAPI, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import uvicorn
import models
import schemas
import crud
from database import SessionLocal, engine

# Create database tables
models.Base.metadata.create_all(bind=engine)

# Initialize FastAPI app
app = FastAPI(
    title="BuildPro360 Asset Service",
    description="API for managing construction assets",
    version="1.0.0"
)

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Routes
@app.get("/assets/", response_model=List[schemas.Asset])
def read_assets(
    skip: int = 0, 
    limit: int = 100, 
    status: Optional[str] = None,
    category: Optional[str] = None,
    search: Optional[str] = None,
    project_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """
    Get a list of assets with optional filtering
    """
    assets = crud.get_assets(
        db, 
        skip=skip, 
        limit=limit, 
        status=status,
        category=category,
        search=search,
        project_id=project_id
    )
    return assets

@app.get("/assets/{asset_id}", response_model=schemas.AssetDetail)
def read_asset(asset_id: int, db: Session = Depends(get_db)):
    """
    Get detailed information about a specific asset
    """
    db_asset = crud.get_asset(db, asset_id=asset_id)
    if db_asset is None:
        raise HTTPException(status_code=404, detail="Asset not found")
    return db_asset

@app.post("/assets/", response_model=schemas.Asset, status_code=201)
def create_asset(asset: schemas.AssetCreate, db: Session = Depends(get_db)):
    """
    Create a new asset
    """
    return crud.create_asset(db=db, asset=asset)

@app.put("/assets/{asset_id}", response_model=schemas.Asset)
def update_asset(asset_id: int, asset: schemas.AssetUpdate, db: Session = Depends(get_db)):
    """
    Update an existing asset
    """
    db_asset = crud.update_asset(db=db, asset_id=asset_id, asset=asset)
    if db_asset is None:
        raise HTTPException(status_code=404, detail="Asset not found")
    return db_asset

@app.delete("/assets/{asset_id}", response_model=schemas.AssetDelete)
def delete_asset(asset_id: int, db: Session = Depends(get_db)):
    """
    Delete an asset (soft delete)
    """
    success = crud.delete_asset(db=db, asset_id=asset_id)
    if not success:
        raise HTTPException(status_code=404, detail="Asset not found")
    return {"id": asset_id, "deleted": True}

@app.get("/assets/categories/", response_model=List[schemas.Category])
def get_asset_categories(db: Session = Depends(get_db)):
    """
    Get all asset categories
    """
    categories = crud.get_asset_categories(db)
    return categories

@app.get("/assets/types/", response_model=List[schemas.AssetType])
def get_asset_types(db: Session = Depends(get_db)):
    """
    Get all asset types
    """
    types = crud.get_asset_types(db)
    return types

@app.get("/assets/{asset_id}/maintenance-history", response_model=List[schemas.MaintenanceRecord])
def get_asset_maintenance_history(asset_id: int, db: Session = Depends(get_db)):
    """
    Get maintenance history for an asset
    """
    db_asset = crud.get_asset(db, asset_id=asset_id)
    if db_asset is None:
        raise HTTPException(status_code=404, detail="Asset not found")
    
    maintenance_records = crud.get_asset_maintenance_history(db, asset_id=asset_id)
    return maintenance_records

@app.get("/assets/{asset_id}/utilization", response_model=schemas.AssetUtilization)
def get_asset_utilization(
    asset_id: int, 
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Get utilization data for an asset
    """
    db_asset = crud.get_asset(db, asset_id=asset_id)
    if db_asset is None:
        raise HTTPException(status_code=404, detail="Asset not found")
    
    utilization = crud.get_asset_utilization(
        db, 
        asset_id=asset_id,
        start_date=start_date,
        end_date=end_date
    )
    return utilization

@app.post("/assets/{asset_id}/assign", response_model=schemas.AssetAssignment)
def assign_asset(
    asset_id: int,
    assignment: schemas.AssetAssignmentCreate,
    db: Session = Depends(get_db)
):
    """
    Assign an asset to a project or user
    """
    db_asset = crud.get_asset(db, asset_id=asset_id)
    if db_asset is None:
        raise HTTPException(status_code=404, detail="Asset not found")
    
    # Check if asset is available
    if db_asset.status != "available":
        raise HTTPException(status_code=400, detail="Asset is not available for assignment")
    
    assignment_record = crud.assign_asset(db, asset_id=asset_id, assignment=assignment)
    return assignment_record

@app.post("/assets/{asset_id}/release", response_model=schemas.AssetAssignment)
def release_asset(asset_id: int, db: Session = Depends(get_db)):
    """
    Release an asset from its current assignment
    """
    db_asset = crud.get_asset(db, asset_id=asset_id)
    if db_asset is None:
        raise HTTPException(status_code=404, detail="Asset not found")
    
    # Check if asset is assigned
    if db_asset.status == "available":
        raise HTTPException(status_code=400, detail="Asset is not currently assigned")
    
    assignment_record = crud.release_asset(db, asset_id=asset_id)
    return assignment_record

# Run the app
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)