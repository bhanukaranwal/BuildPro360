import 'package:intl/intl.dart';

class Project {
  final int id;
  final String name;
  final String status;
  final String? description;
  final String? client;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? actualEndDate;
  final double progress;
  final double? budget;
  final double? actualCost;
  final int? managerId;
  final String? managerName;
  final List<ProjectTask>? tasks;
  final List<ProjectMember>? team;
  final List<AssetAssignment>? assets;
  
  Project({
    required this.id,
    required this.name,
    required this.status,
    this.description,
    this.client,
    this.location,
    this.latitude,
    this.longitude,
    this.startDate,
    this.endDate,
    this.actualEndDate,
    required this.progress,
    this.budget,
    this.actualCost,
    this.managerId,
    this.managerName,
    this.tasks,
    this.team,
    this.assets,
  });
  
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      description: json['description'],
      client: json['client'],
      location: json['location'],
      latitude: json['latitude'] != null ? json['latitude'].toDouble() : null,
      longitude: json['longitude'] != null ? json['longitude'].toDouble() : null,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      actualEndDate: json['actual_end_date'] != null ? DateTime.parse(json['actual_end_date']) : null,
      progress: json['progress'] != null ? json['progress'].toDouble() : 0.0,
      budget: json['budget'] != null ? json['budget'].toDouble() : null,
      actualCost: json['actual_cost'] != null ? json['actual_cost'].toDouble() : null,
      managerId: json['manager_id'],
      managerName: json['manager_name'],
      tasks: json['tasks'] != null 
          ? List<ProjectTask>.from(json['tasks'].map((x) => ProjectTask.fromJson(x)))
          : null,
      team: json['team'] != null 
          ? List<ProjectMember>.from(json['team'].map((x) => ProjectMember.fromJson(x)))
          : null,
      assets: json['assets'] != null 
          ? List<AssetAssignment>.from(json['assets'].map((x) => AssetAssignment.fromJson(x)))
          : null,
    );
  }
  
  String get formattedStartDate {
    return startDate != null 
        ? DateFormat('MMM d, yyyy').format(startDate!)
        : 'Not set';
  }
  
  String get formattedEndDate {
    return endDate != null 
        ? DateFormat('MMM d, yyyy').format(endDate!)
        : 'Not set';
  }
  
  String get formattedBudget {
    return budget != null 
        ? NumberFormat.currency(symbol: '\$').format(budget)
        : 'Not set';
  }
  
  String get formattedActualCost {
    return actualCost != null 
        ? NumberFormat.currency(symbol: '\$').format(actualCost)
        : '\$0.00';
  }
  
  String get statusDisplay {
    return status.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
  
  String get progressDisplay {
    return '${progress.toStringAsFixed(1)}%';
  }
  
  bool get isCompleted {
    return status == 'completed';
  }
  
  bool get isActive {
    return ['in_progress', 'planning'].contains(status);
  }
  
  int get completedTasksCount {
    if (tasks == null) return 0;
    return tasks!.where((task) => task.status == 'completed').length;
  }
  
  int get totalTasksCount {
    return tasks?.length ?? 0;
  }
  
  double get budgetVariance {
    if (budget == null || actualCost == null) return 0;
    return ((actualCost! - budget!) / budget!) * 100;
  }
  
  String get budgetVarianceDisplay {
    final variance = budgetVariance;
    final prefix = variance >= 0 ? '+' : '';
    return '$prefix${variance.toStringAsFixed(1)}%';
  }
  
  bool get isOverBudget {
    return budgetVariance > 0;
  }
  
  bool get isOnSchedule {
    if (endDate == null) return true;
    final now = DateTime.now();
    return now.isBefore(endDate!);
  }
}

class ProjectTask {
  final int id;
  final String name;
  final String status;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final double progress;
  final int? assigneeId;
  final String? assigneeName;
  final List<int>? dependencyIds;
  
  ProjectTask({
    required this.id,
    required this.name,
    required this.status,
    this.description,
    this.startDate,
    this.endDate,
    this.actualStart,
    this.actualEnd,
    required this.progress,
    this.assigneeId,
    this.assigneeName,
    this.dependencyIds,
  });
  
  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    return ProjectTask(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      description: json['description'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      actualStart: json['actual_start'] != null ? DateTime.parse(json['actual_start']) : null,
      actualEnd: json['actual_end'] != null ? DateTime.parse(json['actual_end']) : null,
      progress: json['progress'] != null ? json['progress'].toDouble() : 0.0,
      assigneeId: json['assignee_id'],
      assigneeName: json['assignee_name'],
      dependencyIds: json['dependency_ids'] != null 
          ? List<int>.from(json['dependency_ids'].map((x) => x))
          : null,
    );
  }
}

class ProjectMember {
  final int userId;
  final String name;
  final String role;
  final DateTime joinedDate;
  final String? profileImageUrl;
  
  ProjectMember({
    required this.userId,
    required this.name,
    required this.role,
    required this.joinedDate,
    this.profileImageUrl,
  });
  
  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      userId: json['user_id'],
      name: json['name'],
      role: json['role'],
      joinedDate: DateTime.parse(json['joined_date']),
      profileImageUrl: json['profile_image_url'],
    );
  }
}

class AssetAssignment {
  final int assetId;
  final String assetName;
  final String assetType;
  final DateTime assignedDate;
  final DateTime? returnDate;
  
  AssetAssignment({
    required this.assetId,
    required this.assetName,
    required this.assetType,
    required this.assignedDate,
    this.returnDate,
  });
  
  factory AssetAssignment.fromJson(Map<String, dynamic> json) {
    return AssetAssignment(
      assetId: json['asset_id'],
      assetName: json['asset_name'],
      assetType: json['asset_type'],
      assignedDate: DateTime.parse(json['assigned_date']),
      returnDate: json['return_date'] != null ? DateTime.parse(json['return_date']) : null,
    );
  }
}