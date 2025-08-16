import 'package:intl/intl.dart';

class Inspection {
  final int id;
  final String title;
  final String description;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final int? assetId;
  final String? assetName;
  final int? assignedToId;
  final String? assignedToName;
  final List<InspectionItem>? items;
  final List<InspectionNote>? notes;
  final List<InspectionImage>? images;
  final String? result;
  
  Inspection({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.completedDate,
    this.assetId,
    this.assetName,
    this.assignedToId,
    this.assignedToName,
    this.items,
    this.notes,
    this.images,
    this.result,
  });
  
  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      scheduledDate: json['scheduled_date'] != null ? DateTime.parse(json['scheduled_date']) : null,
      completedDate: json['completed_date'] != null ? DateTime.parse(json['completed_date']) : null,
      assetId: json['asset_id'],
      assetName: json['asset_name'],
      assignedToId: json['assigned_to_id'],
      assignedToName: json['assigned_to_name'],
      items: json['items'] != null
          ? List<InspectionItem>.from(json['items'].map((x) => InspectionItem.fromJson(x)))
          : null,
      notes: json['notes'] != null
          ? List<InspectionNote>.from(json['notes'].map((x) => InspectionNote.fromJson(x)))
          : null,
      images: json['images'] != null
          ? List<InspectionImage>.from(json['images'].map((x) => InspectionImage.fromJson(x)))
          : null,
      result: json['result'],
    );
  }
  
  String get formattedCreatedAt {
    return DateFormat('MMM d, yyyy').format(createdAt);
  }
  
  String get formattedScheduledDate {
    return scheduledDate != null
        ? DateFormat('MMM d, yyyy').format(scheduledDate!)
        : 'Not scheduled';
  }
  
  String get formattedCompletedDate {
    return completedDate != null
        ? DateFormat('MMM d, yyyy').format(completedDate!)
        : 'Not completed';
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
  
  String get resultDisplay {
    if (result == null) return 'Not available';
    
    return result!.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
  
  bool get isComplete {
    return status == 'completed';
  }
  
  bool get isOverdue {
    if (scheduledDate == null || isComplete) return false;
    return DateTime.now().isAfter(scheduledDate!);
  }
  
  bool get isPassed {
    return result == 'pass';
  }
  
  bool get isFailed {
    return result == 'fail';
  }
  
  int get completedItemsCount {
    if (items == null) return 0;
    return items!.where((item) => item.status != 'pending').length;
  }
  
  int get totalItemsCount {
    return items?.length ?? 0;
  }
  
  double get completionPercentage {
    if (totalItemsCount == 0) return 0;
    return (completedItemsCount / totalItemsCount) * 100;
  }
}

class InspectionItem {
  final int id;
  final String description;
  final String status; // pending, pass, fail, n/a
  final String? notes;
  final DateTime? completedAt;
  final String? completedBy;
  
  InspectionItem({
    required this.id,
    required this.description,
    required this.status,
    this.notes,
    this.completedAt,
    this.completedBy,
  });
  
  factory InspectionItem.fromJson(Map<String, dynamic> json) {
    return InspectionItem(
      id: json['id'],
      description: json['description'],
      status: json['status'],
      notes: json['notes'],
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      completedBy: json['completed_by'],
    );
  }
  
  String get statusDisplay {
    return status.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
  
  bool get isPending {
    return status == 'pending';
  }
  
  bool get isPassed {
    return status == 'pass';
  }
  
  bool get isFailed {
    return status == 'fail';
  }
}

class InspectionNote {
  final int id;
  final String content;
  final DateTime createdAt;
  final String createdBy;
  
  InspectionNote({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
  });
  
  factory InspectionNote.fromJson(Map<String, dynamic> json) {
    return InspectionNote(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
    );
  }
  
  String get formattedCreatedAt {
    return DateFormat('MMM d, yyyy h:mm a').format(createdAt);
  }
}

class InspectionImage {
  final int id;
  final String url;
  final String? caption;
  final DateTime uploadedAt;
  final String uploadedBy;
  
  InspectionImage({
    required this.id,
    required this.url,
    this.caption,
    required this.uploadedAt,
    required this.uploadedBy,
  });
  
  factory InspectionImage.fromJson(Map<String, dynamic> json) {
    return InspectionImage(
      id: json['id'],
      url: json['url'],
      caption: json['caption'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      uploadedBy: json['uploaded_by'],
    );
  }
}