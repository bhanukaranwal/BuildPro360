from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
import models
import schemas

# Asset CRUD operations
def get_asset(db: Session, asset_id: int):
    return db.query(models.Asset).filter(models.Asset.id == asset_id, models.Asset.is_active == True).first()

def get_assets(
    db: Session, 
    skip: int = 0, 
    limit: int = 100, 
    status: Optional[str] = None,
    category: Optional[str] = None,
    search: Optional[str] = None,
    project_id: Optional[int] = None
):
    query = db.query(models.Asset).filter(models.Asset.is_active == True)
    
    if status:
        query = query.filter(models.Asset.status == status)
    
    if category:
        query = query.filter(models.Asset.category == category)
    
    if search:
        search_term = f"%{search}%"
        query = query.filter(
            or_(
                models.Asset.name.ilike(search_term),
                models.Asset.serial_number.ilike(search_term),
                models.Asset.manufacturer.ilike(search_term),
                models.Asset.model.ilike(search_term)
            )
        )
    
    if project_id:
        query = query.filter(models.Asset.current_project_id == project_id)
    
    return query.offset(skip).limit(limit).all()

def create_asset(db: Session, asset: schemas.AssetCreate):
    db_asset = models.Asset(
        name=asset.name,
        type=asset.type,
        category=asset.category,
        serial_number=asset.serial_number,
        manufacturer=asset.manufacturer,
        model=asset.model,
        purchase_date=asset.purchase_date,
        purchase_price=asset.purchase_price,
        warranty_expiration=asset.warranty_expiration,
        location=asset.location,
        latitude=asset.latitude,
        longitude=asset.longitude,
        status=asset.status or "available",
        condition=asset.condition,
        notes=asset.notes,
        properties=asset.properties
    )
    db.add(db_asset)
    db.commit()
    db.refresh(db_asset)
    return db_asset

def update_asset(db: Session, asset_id: int, asset: schemas.AssetUpdate):
    db_asset = get_asset(db, asset_id=asset_id)
    if not db_asset:
        return None
    
    asset_data = asset.dict(exclude_unset=True)
    for key, value in asset_data.items():
        setattr(db_asset, key, value)
    
    db_asset.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(db_asset)
    return db_asset

def delete_asset(db: Session, asset_id: int):
    db_asset = get_asset(db, asset_id=asset_id)
    if not db_asset:
        return False
    
    db_asset.is_active = False
    db.commit()
    return True

def get_asset_maintenance_history(db: Session, asset_id: int):
    return db.query(models.MaintenanceRecord).filter(
        models.MaintenanceRecord.asset_id == asset_id
    ).order_by(models.MaintenanceRecord.performed_at.desc()).all()

def get_asset_utilization(
    db: Session, 
    asset_id: int,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None
):
    # Convert string dates to datetime if provided
    start_dt = datetime.fromisoformat(start_date) if start_date else datetime.utcnow() - timedelta(days=30)
    end_dt = datetime.fromisoformat(end_date) if end_date else datetime.utcnow()
    
    # Get the asset
    asset = get_asset(db, asset_id)
    if not asset:
        return None
    
    # In a real application, this would query actual utilization data
    # For this example, we'll return a dummy utilization report
    
    # Calculate days in the period
    days_in_period = (end_dt - start_dt).days
    
    # Generate dummy daily utilization
    daily_utilization = {}
    current_date = start_dt
    while current_date <= end_dt:
        date_str = current_date.strftime("%Y-%m-%d")
        # Generate a utilization value between 0 and 100
        utilization_value = min(100, max(0, asset.utilization_rate or 70))
        daily_utilization[date_str] = utilization_value
        current_date += timedelta(days=1)
    
    # Generate dummy monthly utilization
    monthly_utilization = {}
    month_start = datetime(start_dt.year, start_dt.month, 1)
    while month_start <= end_dt:
        month_str = month_start.strftime("%Y-%m")
        # Generate a utilization value between 0 and 100
        utilization_value = min(100, max(0, asset.utilization_rate or 70))
        monthly_utilization[month_str] = utilization_value
        
        # Move to next month
        if month_start.month == 12:
            month_start = datetime(month_start.year + 1, 1, 1)
        else:
            month_start = datetime(month_start.year, month_start.month + 1, 1)
    
    # Calculate hours
    total_hours = days_in_period * 24
    utilization_rate = asset.utilization_rate or 70
    total_hours_used = total_hours * (utilization_rate / 100)
    idle_hours = total_hours * ((100 - utilization_rate) / 100) * 0.7
    downtime_hours = total_hours * ((100 - utilization_rate) / 100) * 0.3
    
    # Create and return the utilization report
    utilization_report = schemas.AssetUtilization(
        asset_id=asset_id,
        utilization_rate=utilization_rate,
        daily_utilization=daily_utilization,
        monthly_utilization=monthly_utilization,
        total_hours_used=total_hours_used,
        idle_hours=idle_hours,
        downtime_hours=downtime_hours
    )
    
    return utilization_report

def assign_asset(db: Session, asset_id: int, assignment: schemas.AssetAssignmentCreate):
    # Create assignment record
    db_assignment = models.AssetAssignment(
        asset_id=asset_id,
        project_id=assignment.project_id,
        user_id=assignment.user_id,
        notes=assignment.notes
    )
    db.add(db_assignment)
    
    # Update asset status and assignment references
    db_asset = get_asset(db, asset_id=asset_id)
    db_asset.status = "assigned"
    db_asset.current_project_id = assignment.project_id
    db_asset.assigned_user_id = assignment.user_id
    db_asset.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(db_assignment)
    return db_assignment

def release_asset(db: Session, asset_id: int):
    # Find the active assignment
    db_assignment = db.query(models.AssetAssignment).filter(
        models.AssetAssignment.asset_id == asset_id,
        models.AssetAssignment.status == "active",
        models.AssetAssignment.returned_at == None
    ).first()
    
    if not db_assignment:
        return None
    
    # Update assignment record
    db_assignment.status = "completed"
    db_assignment.returned_at = datetime.utcnow()
    
    # Update asset status
    db_asset = get_asset(db, asset_id=asset_id)
    db_asset.status = "available"
    db_asset.current_project_id = None
    db_asset.assigned_user_id = None
    db_asset.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(db_assignment)
    return db_assignment

def get_asset_categories(db: Session):
    return db.query(models.Category).all()

def get_asset_types(db: Session):
    return db.query(models.AssetType).all()