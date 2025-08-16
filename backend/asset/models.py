from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Float, DateTime, Text, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class Asset(Base):
    __tablename__ = "assets"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    type = Column(String(100), nullable=False)
    category = Column(String(100), nullable=False)
    serial_number = Column(String(100), index=True)
    manufacturer = Column(String(255))
    model = Column(String(255))
    purchase_date = Column(DateTime)
    purchase_price = Column(Float)
    warranty_expiration = Column(DateTime)
    location = Column(String(255))
    latitude = Column(Float)
    longitude = Column(Float)
    status = Column(String(50), default="available")
    condition = Column(Float)  # Percentage value (0-100)
    current_project_id = Column(Integer, ForeignKey("projects.id"), nullable=True)
    assigned_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    last_maintenance = Column(DateTime)
    next_maintenance = Column(DateTime)
    last_inspection = Column(DateTime)
    utilization_rate = Column(Float)  # Percentage value (0-100)
    notes = Column(Text)
    properties = Column(JSON)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    current_project = relationship("Project", back_populates="assigned_assets")
    assigned_user = relationship("User", back_populates="assigned_assets")
    maintenance_records = relationship("MaintenanceRecord", back_populates="asset")
    documents = relationship("AssetDocument", back_populates="asset")
    images = relationship("AssetImage", back_populates="asset")
    assignments = relationship("AssetAssignment", back_populates="asset")
    inspection_records = relationship("InspectionRecord", back_populates="asset")

class Project(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False)
    
    # Relationships
    assigned_assets = relationship("Asset", back_populates="current_project")

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False)
    
    # Relationships
    assigned_assets = relationship("Asset", back_populates="assigned_user")

class MaintenanceRecord(Base):
    __tablename__ = "maintenance_records"

    id = Column(Integer, primary_key=True, index=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=False)
    maintenance_type = Column(String(50), nullable=False)  # preventive, corrective, etc.
    description = Column(Text)
    performed_by = Column(String(255))
    performed_at = Column(DateTime, default=datetime.utcnow)
    cost = Column(Float)
    next_maintenance_date = Column(DateTime)
    notes = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    asset = relationship("Asset", back_populates="maintenance_records")

class AssetDocument(Base):
    __tablename__ = "asset_documents"

    id = Column(Integer, primary_key=True, index=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=False)
    name = Column(String(255), nullable=False)
    document_type = Column(String(50))  # manual, certificate, invoice, etc.
    file_path = Column(String(255), nullable=False)
    upload_date = Column(DateTime, default=datetime.utcnow)
    notes = Column(Text)
    
    # Relationships
    asset = relationship("Asset", back_populates="documents")

class AssetImage(Base):
    __tablename__ = "asset_images"

    id = Column(Integer, primary_key=True, index=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=False)
    file_path = Column(String(255), nullable=False)
    caption = Column(String(255))
    upload_date = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    asset = relationship("Asset", back_populates="images")

class AssetAssignment(Base):
    __tablename__ = "asset_assignments"

    id = Column(Integer, primary_key=True, index=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=False)
    project_id = Column(Integer, ForeignKey("projects.id"), nullable=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    assigned_at = Column(DateTime, default=datetime.utcnow)
    returned_at = Column(DateTime, nullable=True)
    status = Column(String(50), default="active")
    notes = Column(Text)
    
    # Relationships
    asset = relationship("Asset", back_populates="assignments")
    project = relationship("Project")
    user = relationship("User")

class InspectionRecord(Base):
    __tablename__ = "inspection_records"

    id = Column(Integer, primary_key=True, index=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=False)
    inspection_type = Column(String(50), nullable=False)
    performed_by = Column(String(255))
    performed_at = Column(DateTime, default=datetime.utcnow)
    result = Column(String(50))  # pass, fail, conditional
    notes = Column(Text)
    next_inspection_date = Column(DateTime)
    
    # Relationships
    asset = relationship("Asset", back_populates="inspection_records")

class Category(Base):
    __tablename__ = "asset_categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, unique=True)
    description = Column(Text)
    parent_id = Column(Integer, ForeignKey("asset_categories.id"), nullable=True)

class AssetType(Base):
    __tablename__ = "asset_types"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, unique=True)
    description = Column(Text)
    category_id = Column(Integer, ForeignKey("asset_categories.id"), nullable=True)