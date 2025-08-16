import 'package:intl/intl.dart';

class DashboardData {
  final int totalAssets;
  final int activeProjects;
  final int pendingInspections;
  final int activeAlerts;
  final double assetUtilizationRate;
  final double projectCompletionRate;
  final List<Project> recentProjects;
  final List<WorkOrder> pendingWorkOrders;
  final List<Inspection> upcomingInspections;
  final List<IoTAlert> recentAlerts;
  
  DashboardData({
    required this.totalAssets,
    required this.activeProjects,
    required this.pendingInspections,
    required this.activeAlerts,
    required this.assetUtilizationRate,
    required this.projectCompletionRate,
    required this.recentProjects,
    required this.pendingWorkOrders,
    required this.upcomingInspections,
    required this.recentAlerts,
  });
  
  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalAssets: json['total_assets'],
      activeProjects: json['active_projects'],
      pendingInspections: json['pending_inspections'],
      activeAlerts: json['active_alerts'],
      assetUtilizationRate: json['asset_utilization_rate'].toDouble(),
      projectCompletionRate: json['project_completion_rate'].toDouble(),
      recentProjects: (json['recent_projects'] as List)
          .map((project) => Project.fromJson(project))
          .toList(),
      pendingWorkOrders: (json['pending_work_orders'] as List)
          .map((workOrder) => WorkOrder.fromJson(workOrder))
          .toList(),
      upcomingInspections: (json['upcoming_inspections'] as List)
          .map((inspection) => Inspection.fromJson(inspection))
          .toList(),
      recentAlerts: (json['recent_alerts'] as List)
          .map((alert) => IoTAlert.fromJson(alert))
          .toList(),
    );
  }
}

class Project {
  final int id;
  final String name;
  final String status;
  final double progress;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? client;
  final String? location;
  final double? budget;
  final double? actualCost;
  final String? managerName;
  final int completedTasksCount;
  final int totalTasksCount;
  
  Project({
    required this.id,
    required this.name,
    required this.status,
    required this.progress,
    this.startDate,
    this.endDate,
    this.client,
    this.location,
    this.budget,
    this.actualCost,
    this.managerName,
    required this.completedTasksCount,
    required this.totalTasksCount,
  });
  
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      progress: json['progress'].toDouble(),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      client: json['client'],
      location: json['location'],
      budget: json['budget'] != null ? json['budget'].toDouble() : null,
      actualCost: json['actual_cost'] != null ? json['actual_cost'].toDouble() : null,
      managerName: json['manager_name'],
      completedTasksCount: json['completed_tasks_count'] ?? 0,
      totalTasksCount: json['total_tasks_count'] ?? 0,
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
  
  String get progressDisplay {
    return '${progress.toStringAsFixed(1)}%';
  }
  
  String get formattedBudget {
    return budget != null
        ? NumberFormat.currency(symbol: '\$').format(budget)
        : 'Not set';
  }
  
  String get formattedActualCost {
    return actualCost != null
        ? NumberFormat.currency(symbol: '\$').format(actualCost)
        : 'Not set';
  }
  
  String get budgetVarianceDisplay {
    if (budget == null || actualCost == null) return 'N/A';
    
    final variance = budget! - actualCost!;
    final percentage = (variance / budget! * 100).abs();
    
    return variance >= 0
        ? 'Under budget by ${NumberFormat.currency(symbol: '\$').format(variance)} (${percentage.toStringAsFixed(1)}%)'
        : 'Over budget by ${NumberFormat.currency(symbol: '\$').format(variance.abs())} (${percentage.toStringAsFixed(1)}%)';
  }
  
  bool get isOverBudget {
    if (budget == null || actualCost == null) return false;
    return actualCost! > budget!;
  }
  
  bool get isOnSchedule {
    if (endDate == null) return true;
    return !endDate!.isBefore(DateTime.now());
  }
  
  String get statusDisplay {
    return status.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
}

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
    );
  }
  
  String get formattedDueDate {
    return dueDate != null
        ? DateFormat('MMM d, yyyy').format(dueDate!)
        : 'Not set';
  }
  
  String get priorityDisplay {
    return priority.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
  
  bool get isOverdue {
    if (dueDate == null || status == 'completed' || status == 'cancelled') return false;
    return DateTime.now().isAfter(dueDate!);
  }
}

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
    );
  }
  
  String get formattedScheduledDate {
    return scheduledDate != null
        ? DateFormat('MMM d, yyyy').format(scheduledDate!)
        : 'Not scheduled';
  }
  
  String get typeDisplay {
    return type.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
  
  bool get isOverdue {
    if (scheduledDate == null || status == 'completed' || status == 'cancelled') return false;
    return DateTime.now().isAfter(scheduledDate!);
  }
}

class IoTAlert {
  final int id;
  final String title;
  final String message;
  final String severity;
  final String status;
  final DateTime timestamp;
  final String? deviceId;
  final String? deviceName;
  
  IoTAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.status,
    required this.timestamp,
    this.deviceId,
    this.deviceName,
  });
  
  factory IoTAlert.fromJson(Map<String, dynamic> json) {
    return IoTAlert(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      severity: json['severity'],
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      deviceId: json['device_id'],
      deviceName: json['device_name'],
    );
  }
}