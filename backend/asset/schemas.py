from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
from datetime import datetime

# Base schemas
class MaintenanceRecordBase(BaseModel):
    maintenance_type: str
    description: Optional[str] = None
    performed_by: Optional[str] = None
    cost: Optional[float] = None
    next_maintenance_date: Optional[datetime] = None
    notes: Optional[str] = None

class AssetDocumentBase(BaseModel):
    name: str
    document_type: Optional[str] = None
    notes: Optional[str] = None

class AssetImageBase(BaseModel):
    caption: Optional[str] = None

class AssetAssignmentBase(BaseModel):
    project_id: Optional[int] = None
    user_id: Optional[int] = None
    notes: Optional[str] = None

class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    parent_id: Optional[int] = None

class AssetTypeBase(BaseModel):
    name: str
    description: Optional[str] = None
    category_id: Optional[int] = None

class AssetBase(BaseModel):
    name: str
    type: str
    category: str
    serial_number: Optional[str] = None
    manufacturer: Optional[str] = None
    model: Optional[str] = None
    purchase_date: Optional[datetime] = None
    purchase_price: Optional[float] = None
    warranty_expiration: Optional[datetime] = None
    location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    status: Optional[str] = "available"
    condition: Optional[float] = None
    notes: Optional[str] = None
    properties: Optional[Dict[str, Any]] = None

# Create schemas
class MaintenanceRecordCreate(MaintenanceRecordBase):
    asset_id: int
    performed_at: Optional[datetime] = None

class AssetDocumentCreate(AssetDocumentBase):
    asset_id: int
    file_path: str

class AssetImageCreate(AssetImageBase):
    asset_id: int
    file_path: str

class AssetAssignmentCreate(AssetAssignmentBase):
    pass

class CategoryCreate(CategoryBase):
    pass

class AssetTypeCreate(AssetTypeBase):
    pass

class AssetCreate(AssetBase):
    pass

# Update schemas
class MaintenanceRecordUpdate(MaintenanceRecordBase):
    pass

class AssetDocumentUpdate(AssetDocumentBase):
    file_path: Optional[str] = None

class AssetImageUpdate(AssetImageBase):
    file_path: Optional[str] = None

class AssetAssignmentUpdate(BaseModel):
    status: Optional[str] = None
    returned_at: Optional[datetime] = None
    notes: Optional[str] = None

class CategoryUpdate(CategoryBase):
    pass

class AssetTypeUpdate(AssetTypeBase):
    pass

class AssetUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    category: Optional[str] = None
    serial_number: Optional[str] = None
    manufacturer: Optional[str] = None
    model: Optional[str] = None
    purchase_date: Optional[datetime] = None
    purchase_price: Optional[float] = None
    warranty_expiration: Optional[datetime] = None
    location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    status: Optional[str] = None
    condition: Optional[float] = None
    current_project_id: Optional[int] = None
    assigned_user_id: Optional[int] = None
    last_maintenance: Optional[datetime] = None
    next_maintenance: Optional[datetime] = None
    last_inspection: Optional[datetime] = None
    utilization_rate: Optional[float] = None
    notes: Optional[str] = None
    properties: Optional[Dict[str, Any]] = None

# Read schemas
class MaintenanceRecord(MaintenanceRecordBase):
    id: int
    asset_id: int
    performed_at: datetime
    created_at: datetime
    
    class Config:
        orm_mode = True

class AssetDocument(AssetDocumentBase):
    id: int
    asset_id: int
    file_path: str
    upload_date: datetime
    
    class Config:
        orm_mode = True

class AssetImage(AssetImageBase):
    id: int
    asset_id: int
    file_path: str
    upload_date: datetime
    
    class Config:
        orm_mode = True

class AssetAssignment(AssetAssignmentBase):
    id: int
    asset_id: int
    assigned_at: datetime
    returned_at: Optional[datetime] = None
    status: str
    
    class Config:
        orm_mode = True

class Category(CategoryBase):
    id: int
    
    class Config:
        orm_mode = True

class AssetType(AssetTypeBase):
    id: int
    
    class Config:
        orm_mode = True

class Asset(AssetBase):
    id: int
    current_project_id: Optional[int] = None
    assigned_user_id: Optional[int] = None
    last_maintenance: Optional[datetime] = None
    next_maintenance: Optional[datetime] = None
    last_inspection: Optional[datetime] = None
    utilization_rate: Optional[float] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        orm_mode = True

class AssetDetail(Asset):
    maintenance_records: List[MaintenanceRecord] = []
    documents: List[AssetDocument] = []
    images: List[AssetImage] = []
    assignments: List[AssetAssignment] = []
    
    class Config:
        orm_mode = True

class AssetDelete(BaseModel):
    id: int
    deleted: bool

class AssetUtilization(BaseModel):
    asset_id: int
    utilization_rate: float
    daily_utilization: Optional[Dict[str, float]] = None
    monthly_utilization: Optional[Dict[str, float]] = None
    total_hours_used: Optional[float] = None
    idle_hours: Optional[float] = None
    downtime_hours: Optional[float] = None
    
    class Config:
        orm_mode = True