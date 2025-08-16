# Fix import at the top
from datetime import datetime, timedelta
import os
import json
import httpx
import asyncio
from typing import List, Dict, Any, Optional
from sqlalchemy.orm import Session

import models
import schemas
import crud

class AlertProcessor:
    def __init__(self, db: Session):
        self.db = db
        self.alert_thresholds = self._load_alert_thresholds()
        self.notification_endpoints = self._load_notification_endpoints()
        self.active_alerts = {}  # device_id -> {alert_type -> alert_data}
        
    def _load_alert_thresholds(self) -> Dict[str, Dict[str, Any]]:
        """Load alert thresholds from configuration"""
        # In a real application, this would load from a database or config file
        return {
            "temperature": {
                "warning": 75,  # degrees Celsius
                "critical": 90,
                "duration": 300,  # seconds
            },
            "pressure": {
                "warning": 180,  # PSI
                "critical": 220,
                "duration": 120,
            },
            "vibration": {
                "warning": 15,  # mm/s
                "critical": 25,
                "duration": 180,
            },
            "fuel_level": {
                "warning": 15,  # percent
                "critical": 5,
                "duration": 0,  # immediate
            },
            "battery": {
                "warning": 20,  # percent
                "critical": 10,
                "duration": 0,  # immediate
            },
            "utilization": {
                "warning": 90,  # percent
                "critical": 95,
                "duration": 3600,  # 1 hour
            },
            "motion": {
                "unexpected": True,
                "duration": 0,  # immediate
            },
            "geofence": {
                "exit": True,
                "duration": 0,  # immediate
            }
        }
    
    def _load_notification_endpoints(self) -> Dict[str, str]:
        """Load notification endpoints from configuration"""
        # In a real application, this would load from a database or config file
        return {
            "email": os.environ.get("EMAIL_NOTIFICATION_ENDPOINT", "http://notification-service/email"),
            "sms": os.environ.get("SMS_NOTIFICATION_ENDPOINT", "http://notification-service/sms"),
            "push": os.environ.get("PUSH_NOTIFICATION_ENDPOINT", "http://notification-service/push"),
            "webhook": os.environ.get("WEBHOOK_NOTIFICATION_ENDPOINT", "http://notification-service/webhook"),
        }
    
    async def process_telemetry(self, device_id: str, telemetry: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Process telemetry data and generate alerts if thresholds are exceeded"""
        alerts = []
        
        # Get device information
        device = crud.get_device(self.db, device_id)
        if not device:
            return alerts
        
        # Process each sensor reading
        timestamp = telemetry.get("timestamp") or datetime.utcnow().isoformat()
        readings = telemetry.get("readings", {})
        
        for sensor_type, value in readings.items():
            if sensor_type in self.alert_thresholds:
                threshold = self.alert_thresholds[sensor_type]
                
                # Check if the value exceeds any thresholds
                alert_data = self._check_threshold(
                    device_id=device_id,
                    device_name=device.name,
                    sensor_type=sensor_type,
                    value=value,
                    threshold=threshold,
                    timestamp=timestamp
                )
                
                if alert_data:
                    # Create or update the alert in the database
                    alert = await self._create_or_update_alert(alert_data)
                    if alert:
                        alerts.append(alert)
                        
                        # Send notification for the alert
                        await self._send_notification(alert)
        
        return alerts
    
    def _check_threshold(
        self, 
        device_id: str, 
        device_name: str,
        sensor_type: str, 
        value: Any, 
        threshold: Dict[str, Any],
        timestamp: str
    ) -> Optional[Dict[str, Any]]:
        """Check if a sensor reading exceeds the configured thresholds"""
        alert_key = f"{device_id}_{sensor_type}"
        
        # Handle special case for boolean triggers (motion, geofence)
        if "unexpected" in threshold or "exit" in threshold:
            trigger_key = "unexpected" if "unexpected" in threshold else "exit"
            if value == threshold[trigger_key]:
                return {
                    "device_id": device_id,
                    "device_name": device_name,
                    "sensor_type": sensor_type,
                    "value": value,
                    "threshold_value": threshold[trigger_key],
                    "severity": "warning",
                    "message": f"Unexpected {sensor_type} detected for {device_name}",
                    "timestamp": timestamp
                }
            return None
        
        # Handle numeric thresholds
        severity = None
        threshold_value = None
        
        if "critical" in threshold and value >= threshold["critical"]:
            severity = "critical"
            threshold_value = threshold["critical"]
        elif "warning" in threshold and value >= threshold["warning"]:
            severity = "warning"
            threshold_value = threshold["warning"]
        
        if severity:
            # If this is a new alert or escalation, create it
            existing_alert = self.active_alerts.get(alert_key)
            if not existing_alert or existing_alert["severity"] != severity:
                alert_data = {
                    "device_id": device_id,
                    "device_name": device_name,
                    "sensor_type": sensor_type,
                    "value": value,
                    "threshold_value": threshold_value,
                    "severity": severity,
                    "message": self._generate_alert_message(
                        device_name, sensor_type, value, threshold_value, severity
                    ),
                    "timestamp": timestamp
                }
                
                # Store in active alerts
                self.active_alerts[alert_key] = alert_data
                return alert_data
            
            # Update existing alert with new value
            existing_alert["value"] = value
            existing_alert["timestamp"] = timestamp
            return None
        else:
            # If value is below thresholds and there was an active alert, resolve it
            if alert_key in self.active_alerts:
                alert_data = self.active_alerts[alert_key].copy()
                alert_data["resolved"] = True
                alert_data["resolved_timestamp"] = datetime.utcnow().isoformat()
                
                # Remove from active alerts
                del self.active_alerts[alert_key]
                return alert_data
        
        return None
    
    def _generate_alert_message(
        self, device_name: str, sensor_type: str, value: Any, threshold: Any, severity: str
    ) -> str:
        """Generate a human-readable alert message"""
        sensor_name = sensor_type.replace("_", " ").title()
        
        if severity == "critical":
            return f"CRITICAL: {sensor_name} on {device_name} is {value}, exceeding critical threshold of {threshold}"
        else:
            return f"WARNING: {sensor_name} on {device_name} is {value}, exceeding warning threshold of {threshold}"
    
    async def _create_or_update_alert(self, alert_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Create a new alert or update an existing one in the database"""
        try:
            # Check for existing unresolved alert for this device and sensor type
            device_id = alert_data["device_id"]
            sensor_type = alert_data["sensor_type"]
            
            if alert_data.get("resolved"):
                # Resolve the alert
                alert = crud.resolve_alert(
                    self.db,
                    device_id=device_id,
                    sensor_type=sensor_type
                )
                if alert:
                    return {
                        "id": alert.id,
                        "device_id": alert.device_id,
                        "device_name": alert_data["device_name"],
                        "sensor_type": alert.sensor_type,
                        "message": f"Resolved: {alert.message}",
                        "severity": alert.severity,
                        "created_at": alert.created_at.isoformat(),
                        "resolved_at": datetime.utcnow().isoformat(),
                        "resolved": True
                    }
            else:
                # Create or update alert
                alert_create = schemas.AlertCreate(
                    device_id=device_id,
                    sensor_type=sensor_type,
                    value=str(alert_data["value"]),
                    threshold_value=str(alert_data["threshold_value"]),
                    message=alert_data["message"],
                    severity=alert_data["severity"]
                )
                
                alert = crud.create_or_update_alert(self.db, alert=alert_create)
                
                return {
                    "id": alert.id,
                    "device_id": alert.device_id,
                    "device_name": alert_data["device_name"],
                    "sensor_type": alert.sensor_type,
                    "message": alert.message,
                    "severity": alert.severity,
                    "created_at": alert.created_at.isoformat(),
                    "acknowledged": alert.acknowledged,
                    "resolved": alert.resolved
                }
                
        except Exception as e:
            print(f"Error creating or updating alert: {e}")
            return None
    
    async def _send_notification(self, alert: Dict[str, Any]) -> None:
        """Send notifications for an alert via configured channels"""
        try:
            # Skip notifications for resolved alerts
            if alert.get("resolved"):
                return
            
            # Prepare notification payload
            notification = {
                "alert_id": alert["id"],
                "device_id": alert["device_id"],
                "device_name": alert["device_name"],
                "message": alert["message"],
                "severity": alert["severity"],
                "timestamp": alert.get("created_at", datetime.utcnow().isoformat())
            }
            
            # Determine which channels to use based on severity
            channels = ["push"]  # Always send push notifications
            
            if alert["severity"] == "critical":
                channels.extend(["email", "sms"])
            
            # Send to each channel
            for channel in channels:
                if channel in self.notification_endpoints:
                    try:
                        async with httpx.AsyncClient() as client:
                            response = await client.post(
                                self.notification_endpoints[channel],
                                json=notification,
                                timeout=5.0
                            )
                            if response.status_code != 200:
                                print(f"Failed to send {channel} notification: {response.text}")
                    except Exception as e:
                        print(f"Error sending {channel} notification: {e}")
            
        except Exception as e:
            print(f"Error in send_notification: {e}")