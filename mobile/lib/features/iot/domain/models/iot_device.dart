import 'package:intl/intl.dart';

class IoTDevice {
  final int id;
  final String name;
  final String type;
  final String status;
  final DateTime lastSeen;
  final double? latitude;
  final double? longitude;
  final String? location;
  final double? batteryLevel;
  final String? firmwareVersion;
  final int? assetId;
  final String? assetName;
  final Map<String, dynamic> latestTelemetry;
  
  IoTDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.lastSeen,
    this.latitude,
    this.longitude,
    this.location,
    this.batteryLevel,
    this.firmwareVersion,
    this.assetId,
    this.assetName,
    required this.latestTelemetry,
  });
  
  factory IoTDevice.fromJson(Map<String, dynamic> json) {
    return IoTDevice(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      status: json['status'],
      lastSeen: DateTime.parse(json['last_seen']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      location: json['location'],
      batteryLevel: json['battery_level'],
      firmwareVersion: json['firmware_version'],
      assetId: json['asset_id'],
      assetName: json['asset_name'],
      latestTelemetry: json['latest_telemetry'] ?? {},
    );
  }
  
  bool get isOnline {
    // Device is considered online if it was seen in the last 5 minutes
    return DateTime.now().difference(lastSeen).inMinutes < 5;
  }
  
  String get formattedLastSeen {
    return DateFormat('MMM d, yyyy h:mm a').format(lastSeen);
  }
  
  String get timeSinceLastSeenDisplay {
    final duration = DateTime.now().difference(lastSeen);
    
    if (duration.inSeconds < 60) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else if (duration.inDays < 7) {
      return '${duration.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(lastSeen);
    }
  }
  
  String get typeDisplay {
    return type.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
  
  String get batteryLevelDisplay {
    if (batteryLevel == null) return 'N/A';
    return '${batteryLevel!.toStringAsFixed(0)}%';
  }
  
  bool get hasLowBattery {
    if (batteryLevel == null) return false;
    return batteryLevel! < 20;
  }
}