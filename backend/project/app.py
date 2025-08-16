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
    title="BuildPro360 Project Service",
    description="API for managing construction projects",
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
@app.get("/projects/", response_model=List[schemas.Project])
def read_projects(
    skip: int = 0, 
    limit: int = 100, 
    status: Optional[str] = None,
    search: Optional[str] = None,
    client_id: Optional[int] = None,
    manager_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """
    Get a list of projects with optional filtering
    """
    projects = crud.get_projects(
        db, 
        skip=skip, 
        limit=limit, 
        status=status,
        search=search,
        client_id=client_id,
        manager_id=manager_id
    )
    return projects

@app.get("/projects/{project_id}", response_model=schemas.ProjectDetail)
def read_project(project_id: int, db: Session = Depends(get_db)):
    """
    Get detailed information about a specific project
    """
    db_project = crud.get_project(db, project_id=project_id)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    return db_project

@app.post("/projects/", response_model=schemas.Project, status_code=201)
def create_project(project: schemas.ProjectCreate, db: Session = Depends(get_db)):
    """
    Create a new project
    """
    return crud.create_project(db=db, project=project)

@app.put("/projects/{project_id}", response_model=schemas.Project)
def update_project(project_id: int, project: schemas.ProjectUpdate, db: Session = Depends(get_db)):
    """
    Update an existing project
    """
    db_project = crud.update_project(db=db, project_id=project_id, project=project)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    return db_project

@app.delete("/projects/{project_id}", response_model=schemas.ProjectDelete)
def delete_project(project_id: int, db: Session = Depends(get_db)):
    """
    Delete a project (soft delete)
    """
    success = crud.delete_project(db=db, project_id=project_id)
    if not success:
        raise HTTPException(status_code=404, detail="Project not found")
    return {"id": project_id, "deleted": True}

@app.get("/projects/{project_id}/tasks", response_model=List[schemas.Task])
def read_project_tasks(project_id: int, db: Session = Depends(get_db)):
    """
    Get all tasks for a specific project
    """
    db_project = crud.get_project(db, project_id=project_id)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    
    tasks = crud.get_project_tasks(db, project_id=project_id)
    return tasks

@app.post("/projects/{project_id}/tasks", response_model=schemas.Task, status_code=201)
def create_project_task(project_id: int, task: schemas.TaskCreate, db: Session = Depends(get_db)):
    """
    Create a new task for a project
    """
    db_project = crud.get_project(db, project_id=project_id)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    
    # Set the project_id in the task data
    task_data = task.dict()
    task_data["project_id"] = project_id
    
    return crud.create_task(db=db, task=schemas.TaskCreate(**task_data))

@app.get("/projects/{project_id}/team", response_model=List[schemas.TeamMember])
def read_project_team(project_id: int, db: Session = Depends(get_db)):
    """
    Get all team members for a specific project
    """
    db_project = crud.get_project(db, project_id=project_id)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    
    team_members = crud.get_project_team(db, project_id=project_id)
    return team_members

@app.post("/projects/{project_id}/team", response_model=schemas.TeamMember, status_code=201)
def add_team_member(project_id: int, team_member: schemas.TeamMemberCreate, db: Session = Depends(get_db)):
    """
    Add a team member to a project
    """
    db_project = crud.get_project(db, project_id=project_id)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    
    # Set the project_id in the team member data
    member_data = team_member.dict()
    member_data["project_id"] = project_id
    
    return crud.add_team_member(db=db, team_member=schemas.TeamMemberCreate(**member_data))

@app.get("/projects/{project_id}/assets", response_model=List[schemas.ProjectAsset])
def read_project_assets(project_id: int, db: Session = Depends(get_db)):
    """
    Get all assets assigned to a specific project
    """
    db_project = crud.get_project(db, project_id=project_id)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    
    assets = crud.get_project_assets(db, project_id=project_id)
    return assets

@app.post("/projects/{project_id}/assets", response_model=schemas.ProjectAsset, status_code=201)
def assign_asset_to_project(project_id: int, asset: schemas.ProjectAssetCreate, db: Session = Depends(get_db)):
    """
    Assign an asset to a project
    """
    db_project = crud.get_project(db, project_id=project_id)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    
    # Set the project_id in the asset data
    asset_data = asset.dict()
    asset_data["project_id"] = project_id
    
    return crud.assign_asset_to_project(db=db, project_asset=schemas.ProjectAssetCreate(**asset_data))

@app.get("/projects/{project_id}/timeline", response_model=schemas.ProjectTimeline)
def get_project_timeline(project_id: int, db: Session = Depends(get_db)):
    """
    Get timeline data for a specific project
    """
    db_project = crud.get_project(db, project_id=project_id)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    
    timeline = crud.get_project_timeline(db, project_id=project_id)
    return timeline

@app.get("/projects/{project_id}/budget", response_model=schemas.ProjectBudget)
def get_project_budget(project_id: int, db: Session = Depends(get_db)):
    """
    Get budget information for a specific project
    """
    db_project = crud.get_project(db, project_id=project_id)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    
    budget = crud.get_project_budget(db, project_id=project_id)
    return budget

@app.get("/projects/performance", response_model=schemas.ProjectPerformanceData)
def get_project_performance(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    project_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """
    Get performance data for projects
    """
    performance_data = crud.get_project_performance(
        db, 
        start_date=start_date,
        end_date=end_date,
        project_id=project_id
    )
    return performance_data

# Run the app
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)