import 'package:intl/intl.dart';

class Asset {
  final int id;
  final String name;
  final String type;
  final String category;
  final String status;
  final String? serialNumber;
  final String? manufacturer;
  final String? model;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final DateTime? warrantyExpiration;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? lastMaintenance;
  final DateTime? nextMaintenance;
  final DateTime? lastInspection;
  final double? utilizationRate;
  final double? condition;
  final int? currentProjectId;
  final String? currentProjectName;
  final String? assignedTo;
  final int? assignedUserId;
  final String? notes;
  final List<AssetDocument>? documents;
  final List<AssetImage>? images;
  
  Asset({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.status,
    this.serialNumber,
    this.manufacturer,
    this.model,
    this.purchaseDate,
    this.purchasePrice,
    this.warrantyExpiration,
    this.location,
    this.latitude,
    this.longitude,
    this.lastMaintenance,
    this.nextMaintenance,
    this.lastInspection,
    this.utilizationRate,
    this.condition,
    this.currentProjectId,
    this.currentProjectName,
    this.assignedTo,
    this.assignedUserId,
    this.notes,
    this.documents,
    this.images,
  });
  
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      category: json['category'],
      status: json['status'],
      serialNumber: json['serial_number'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      purchaseDate: json['purchase_date'] != null ? DateTime.parse(json['purchase_date']) : null,
      purchasePrice: json['purchase_price'] != null ? json['purchase_price'].toDouble() : null,
      warrantyExpiration: json['warranty_expiration'] != null ? DateTime.parse(json['warranty_expiration']) : null,
      location: json['location'],
      latitude: json['latitude'] != null ? json['latitude'].toDouble() : null,
      longitude: json['longitude'] != null ? json['longitude'].toDouble() : null,
      lastMaintenance: json['last_maintenance'] != null ? DateTime.parse(json['last_maintenance']) : null,
      nextMaintenance: json['next_maintenance'] != null ? DateTime.parse(json['next_maintenance']) : null,
      lastInspection: json['last_inspection'] != null ? DateTime.parse(json['last_inspection']) : null,
      utilizationRate: json['utilization_rate'] != null ? json['utilization_rate'].toDouble() : null,
      condition: json['condition'] != null ? json['condition'].toDouble() : null,
      currentProjectId: json['current_project_id'],
      currentProjectName: json['current_project_name'],
      assignedTo: json['assigned_to'],
      assignedUserId: json['assigned_user_id'],
      notes: json['notes'],
      documents: json['documents'] != null 
          ? List<AssetDocument>.from(json['documents'].map((x) => AssetDocument.fromJson(x)))
          : null,
      images: json['images'] != null 
          ? List<AssetImage>.from(json['images'].map((x) => AssetImage.fromJson(x)))
          : null,
    );
  }
  
  String get formattedPurchaseDate {
    return purchaseDate != null 
        ? DateFormat('MMM d, yyyy').format(purchaseDate!)
        : 'Not available';
  }
  
  String get formattedPurchasePrice {
    return purchasePrice != null 
        ? NumberFormat.currency(symbol: '\$').format(purchasePrice)
        : 'Not available';
  }
  
  String get formattedLastMaintenance {
    return lastMaintenance != null 
        ? DateFormat('MMM d, yyyy').format(lastMaintenance!)
        : 'Not available';
  }
  
  String get formattedNextMaintenance {
    return nextMaintenance != null 
        ? DateFormat('MMM d, yyyy').format(nextMaintenance!)
        : 'Not scheduled';
  }
  
  String get statusDisplay {
    return status.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
  
  String get typeDisplay {
    return type.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
  
  String get categoryDisplay {
    return category.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
  
  bool get isAvailable {
    return status == 'available';
  }
  
  bool get needsMaintenance {
    return nextMaintenance != null && nextMaintenance!.isBefore(DateTime.now());
  }
  
  bool get hasWarranty {
    return warrantyExpiration != null && warrantyExpiration!.isAfter(DateTime.now());
  }
}

class AssetDocument {
  final int id;
  final String name;
  final String type;
  final String url;
  final DateTime uploadDate;
  
  AssetDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.uploadDate,
  });
  
  factory AssetDocument.fromJson(Map<String, dynamic> json) {
    return AssetDocument(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      url: json['url'],
      uploadDate: DateTime.parse(json['upload_date']),
    );
  }
}

class AssetImage {
  final int id;
  final String url;
  final String? caption;
  final DateTime uploadDate;
  
  AssetImage({
    required this.id,
    required this.url,
    this.caption,
    required this.uploadDate,
  });
  
  factory AssetImage.fromJson(Map<String, dynamic> json) {
    return AssetImage(
      id: json['id'],
      url: json['url'],
      caption: json['caption'],
      uploadDate: DateTime.parse(json['upload_date']),
    );
  }
}