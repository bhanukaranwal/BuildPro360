class AppConstants {
  // API URLs
  static const String baseApiUrl = 'https://api.buildpro360.com/v1';
  static const String baseWebSocketUrl = 'wss://api.buildpro360.com/ws';
  
  // Shared Preferences Keys
  static const String prefsKeyAuthToken = 'auth_token';
  static const String prefsKeyUserId = 'user_id';
  static const String prefsKeyUsername = 'username';
  static const String prefsKeyUserRole = 'user_role';
  static const String prefsKeyDarkMode = 'dark_mode';
  static const String prefsKeyBiometricEnabled = 'biometric_enabled';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Asset Categories
  static const List<String> assetCategories = [
    'equipment',
    'tools',
    'vehicles',
    'safety_gear',
    'electronics',
    'office',
    'other',
  ];
  
  // Asset Statuses
  static const List<String> assetStatuses = [
    'available',
    'in_use',
    'maintenance',
    'out_of_service',
  ];
  
  // Project Statuses
  static const List<String> projectStatuses = [
    'planning',
    'in_progress',
    'on_hold',
    'completed',
    'cancelled',
  ];
  
  // Work Order Priorities
  static const List<String> workOrderPriorities = [
    'low',
    'medium',
    'high',
    'critical',
  ];
  
  // Work Order Statuses
  static const List<String> workOrderStatuses = [
    'open',
    'assigned',
    'in_progress',
    'on_hold',
    'completed',
    'cancelled',
  ];
  
  // Inspection Types
  static const List<String> inspectionTypes = [
    'safety',
    'quality',
    'environmental',
    'regulatory',
    'maintenance',
  ];
  
  // Inspection Statuses
  static const List<String> inspectionStatuses = [
    'scheduled',
    'in_progress',
    'completed',
    'cancelled',
  ];
  
  // Device Types
  static const List<String> deviceTypes = [
    'sensor',
    'camera',
    'gateway',
    'controller',
    'tracker',
  ];
  
  // Alert Severities
  static const List<String> alertSeverities = [
    'critical',
    'high',
    'medium',
    'low',
    'info',
  ];
  
  // Alert Statuses
  static const List<String> alertStatuses = [
    'active',
    'acknowledged',
    'resolved',
  ];
  
  // Report Types
  static const List<String> reportTypes = [
    'asset_inventory',
    'asset_utilization',
    'project_status',
    'maintenance_summary',
    'compliance_summary',
    'iot_analytics',
  ];
  
  // Date Formats
  static const String dateFormatFull = 'MMMM d, yyyy';
  static const String dateFormatShort = 'MMM d, yyyy';
  static const String dateFormatISO = 'yyyy-MM-dd';
  static const String timeFormatFull = 'h:mm:ss a';
  static const String timeFormatShort = 'h:mm a';
  static const String dateTimeFormatFull = 'MMMM d, yyyy h:mm:ss a';
  static const String dateTimeFormatShort = 'MMM d, yyyy h:mm a';
  
  // Permission error messages
  static const String permissionDeniedMessage = 'You do not have permission to perform this action.';
  static const String permissionCameraMessage = 'Camera permission is required to take photos.';
  static const String permissionLocationMessage = 'Location permission is required to use this feature.';
  static const String permissionStorageMessage = 'Storage permission is required to save files.';
  
  // Other Constants
  static const int refreshInterval = 60; // in seconds
  static const int maxImageUploadSize = 10 * 1024 * 1024; // 10 MB
  static const int sessionTimeout = 30 * 60 * 1000; // 30 minutes in milliseconds
}