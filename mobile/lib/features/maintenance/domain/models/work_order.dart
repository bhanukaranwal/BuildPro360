import 'package:intl/intl.dart';

class WorkOrder {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final int? assetId;
  final String? assetName;
  final int? assignedToId;
  final String? assignedToName;
  final List<WorkOrderTask>? tasks;
  final List<WorkOrderNote>? notes;
  final List<WorkOrderImage>? images;
  
  WorkOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    this.completedDate,
    this.assetId,
    this.assetName,
    this.assignedToId,
    this.assignedToName,
    this.tasks,
    this.notes,
    this.images,
  });
  
  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['created_at']),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      completedDate: json['completed_date'] != null ? DateTime.parse(json['completed_date']) : null,
      assetId: json['asset_id'],
      assetName: json['asset_name'],
      assignedToId: json['assigned_to_id'],
      assignedToName: json['assigned_to_name'],
      tasks: json['tasks'] != null
          ? List<WorkOrderTask>.from(json['tasks'].map((x) => WorkOrderTask.fromJson(x)))
          : null,
      notes: json['notes'] != null
          ? List<WorkOrderNote>.from(json['notes'].map((x) => WorkOrderNote.fromJson(x)))
          : null,
      images: json['images'] != null
          ? List<WorkOrderImage>.from(json['images'].map((x) => WorkOrderImage.fromJson(x)))
          : null,
    );
  }
  
  String get formattedCreatedAt {
    return DateFormat('MMM d, yyyy').format(createdAt);
  }
  
  String get formattedDueDate {
    return dueDate != null
        ? DateFormat('MMM d, yyyy').format(dueDate!)
        : 'Not set';
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
  
  String get priorityDisplay {
    return priority.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
  
  bool get isComplete {
    return status == 'completed';
  }
  
  bool get isOverdue {
    if (dueDate == null || isComplete) return false;
    return DateTime.now().isAfter(dueDate!);
  }
  
  bool get isHighPriority {
    return priority == 'high' || priority == 'critical';
  }
  
  int get completedTasksCount {
    if (tasks == null) return 0;
    return tasks!.where((task) => task.isCompleted).length;
  }
  
  int get totalTasksCount {
    return tasks?.length ?? 0;
  }
  
  double get completionPercentage {
    if (totalTasksCount == 0) return 0;
    return (completedTasksCount / totalTasksCount) * 100;
  }
}

class WorkOrderTask {
  final int id;
  final String description;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completedBy;
  
  WorkOrderTask({
    required this.id,
    required this.description,
    required this.isCompleted,
    this.completedAt,
    this.completedBy,
  });
  
  factory WorkOrderTask.fromJson(Map<String, dynamic> json) {
    return WorkOrderTask(
      id: json['id'],
      description: json['description'],
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      completedBy: json['completed_by'],
    );
  }
}

class WorkOrderNote {
  final int id;
  final String content;
  final DateTime createdAt;
  final String createdBy;
  
  WorkOrderNote({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
  });
  
  factory WorkOrderNote.fromJson(Map<String, dynamic> json) {
    return WorkOrderNote(
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

class WorkOrderImage {
  final int id;
  final String url;
  final String? caption;
  final DateTime uploadedAt;
  final String uploadedBy;
  
  WorkOrderImage({
    required this.id,
    required this.url,
    this.caption,
    required this.uploadedAt,
    required this.uploadedBy,
  });
  
  factory WorkOrderImage.fromJson(Map<String, dynamic> json) {
    return WorkOrderImage(
      id: json['id'],
      url: json['url'],
      caption: json['caption'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      uploadedBy: json['uploaded_by'],
    );
  }
}