import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buildpro360_mobile/features/maintenance/domain/models/work_order.dart';
import 'package:buildpro360_mobile/features/maintenance/presentation/bloc/maintenance_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class WorkOrderDetailPage extends StatefulWidget {
  final int? workOrderId;
  
  const WorkOrderDetailPage({super.key, this.workOrderId});

  @override
  State<WorkOrderDetailPage> createState() => _WorkOrderDetailPageState();
}

class _WorkOrderDetailPageState extends State<WorkOrderDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (widget.workOrderId != null) {
      context.read<MaintenanceBloc>().add(
        FetchWorkOrderDetailEvent(workOrderId: widget.workOrderId!),
      );
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MaintenanceBloc, MaintenanceState>(
      listener: (context, state) {
        if (state is WorkOrderUpdatedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Work order updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is MaintenanceErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is WorkOrderDetailLoadedState 
                  ? state.workOrder.title 
                  : 'Work Order Details',
            ),
            bottom: state is WorkOrderDetailLoadedState
                ? TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Tasks'),
                      Tab(text: 'Media'),
                    ],
                  )
                : null,
            actions: [
              if (state is WorkOrderDetailLoadedState && !state.workOrder.isComplete)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    // Handle menu actions
                    switch (value) {
                      case 'update_status':
                        _showUpdateStatusDialog(context, state.workOrder);
                        break;
                      case 'assign':
                        _showAssignDialog(context, state.workOrder);
                        break;
                      case 'edit':
                        _showEditDialog(context, state.workOrder);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'update_status',
                      child: Row(
                        children: [
                          Icon(Icons.update),
                          SizedBox(width: 8),
                          Text('Update Status'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'assign',
                      child: Row(
                        children: [
                          Icon(Icons.person_add),
                          SizedBox(width: 8),
                          Text('Assign'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: _buildBody(state),
          bottomNavigationBar: state is WorkOrderDetailLoadedState && !state.workOrder.isComplete
              ? _buildActionBar(state.workOrder)
              : null,
        );
      },
    );
  }
  
  Widget _buildBody(MaintenanceState state) {
    if (state is MaintenanceLoadingState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is WorkOrderDetailLoadedState) {
      final workOrder = state.workOrder;
      
      return TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(workOrder),
          _buildTasksTab(workOrder),
          _buildMediaTab(workOrder),
        ],
      );
    } else if (state is MaintenanceErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (widget.workOrderId != null) {
                  context.read<MaintenanceBloc>().add(
                    FetchWorkOrderDetailEvent(workOrderId: widget.workOrderId!),
                  );
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      return const Center(
        child: Text('Work order details not available'),
      );
    }
  }
  
  Widget _buildDetailsTab(WorkOrder workOrder) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusChip(workOrder.status),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Priority',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildPriorityIndicator(workOrder.priority),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(workOrder.description),
            ),
          ),
          const SizedBox(height: 16),
          
          // Basic Info
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow('Created', workOrder.formattedCreatedAt, Icons.event),
                  const Divider(),
                  _buildInfoRow(
                    'Due Date', 
                    workOrder.formattedDueDate, 
                    Icons.event_available,
                    valueColor: workOrder.isOverdue ? Colors.red : null,
                  ),
                  
                  if (workOrder.isComplete) ...[
                    const Divider(),
                    _buildInfoRow(
                      'Completed', 
                      workOrder.formattedCompletedDate, 
                      Icons.check_circle,
                      valueColor: Colors.green,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Asset and Assignment Info
          const Text(
            'Assignment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Asset', 
                    workOrder.assetName ?? 'Not assigned', 
                    Icons.build,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    'Assigned To', 
                    workOrder.assignedToName ?? 'Not assigned', 
                    Icons.person,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Notes
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: workOrder.notes != null && workOrder.notes!.isNotEmpty
                  ? ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workOrder.notes!.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final note = workOrder.notes![index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  note.createdBy,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  note.formattedCreatedAt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(note.content),
                          ],
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No notes added yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildTasksTab(WorkOrder workOrder) {
    final tasks = workOrder.tasks;
    
    if (tasks == null || tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tasks found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Add tasks to this work order',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Add task functionality
                _showAddTaskDialog(context, workOrder);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
      );
    }
    
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                value: task.isCompleted,
                onChanged: !workOrder.isComplete 
                    ? (value) {
                        // Update task completion status
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task update functionality coming soon!'),
                          ),
                        );
                      }
                    : null,
                title: Text(
                  task.description,
                  style: TextStyle(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: task.completedAt != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Completed: ${DateFormat('MMM d, yyyy').format(task.completedAt!)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (task.completedBy != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'By: ${task.completedBy}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      )
                    : null,
                secondary: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: !workOrder.isComplete
                      ? () {
                          // Show task options
                          _showTaskOptionsDialog(context, task);
                        }
                      : null,
                ),
              ),
            );
          },
        ),
        if (!workOrder.isComplete)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'add_task',
              mini: true,
              onPressed: () {
                // Add task functionality
                _showAddTaskDialog(context, workOrder);
              },
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
  
  Widget _buildMediaTab(WorkOrder workOrder) {
    final images = workOrder.images;
    
    return Stack(
      children: [
        images == null || images.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.image,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No images found',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add images to document this work order',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (!workOrder.isComplete)
                      ElevatedButton.icon(
                        onPressed: () {
                          // Add image functionality
                          _showImageSourceDialog(context);
                        },
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Add Image'),
                      ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return GestureDetector(
                    onTap: () {
                      // Show image in full screen
                      _showImageDetail(context, image);
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image.url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / 
                                        loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (image.caption != null && image.caption!.isNotEmpty)
                                  Text(
                                    image.caption!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                Text(
                                  DateFormat('MMM d, yyyy').format(image.uploadedAt),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        if (!workOrder.isComplete)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'add_image',
              onPressed: () {
                // Add image functionality
                _showImageSourceDialog(context);
              },
              child: const Icon(Icons.add_a_photo),
            ),
          ),
      ],
    );
  }
  
  Widget _buildActionBar(WorkOrder workOrder) {
    if (workOrder.isComplete) return const SizedBox.shrink();
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Add a note...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _notesController.text.trim().isNotEmpty
                  ? () {
                      // Add note functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add note functionality coming soon!'),
                        ),
                      );
                      _notesController.clear();
                    }
                  : null,
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // Complete work order functionality
                _showCompleteWorkOrderDialog(context, workOrder);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color chipColor;
    String displayText;
    
    switch (status) {
      case 'open':
        chipColor = Colors.blue;
        displayText = 'Open';
        break;
      case 'assigned':
        chipColor = Colors.purple;
        displayText = 'Assigned';
        break;
      case 'in_progress':
        chipColor = Colors.orange;
        displayText = 'In Progress';
        break;
      case 'on_hold':
        chipColor = Colors.amber;
        displayText = 'On Hold';
        break;
      case 'completed':
        chipColor = Colors.green;
        displayText = 'Completed';
        break;
      case 'cancelled':
        chipColor = Colors.red;
        displayText = 'Cancelled';
        break;
      default:
        chipColor = Colors.grey;
        displayText = status.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
        ).join(' ');
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        border: Border.all(color: chipColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            color: chipColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            displayText,
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'open':
        return Icons.fiber_new;
      case 'assigned':
        return Icons.person;
      case 'in_progress':
        return Icons.engineering;
      case 'on_hold':
        return Icons.pause;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
  
  Widget _buildPriorityIndicator(String priority) {
    Color indicatorColor;
    String displayText;
    
    switch (priority) {
      case 'low':
        indicatorColor = Colors.green;
        displayText = 'Low';
        break;
      case 'medium':
        indicatorColor = Colors.orange;
        displayText = 'Medium';
        break;
      case 'high':
        indicatorColor = Colors.red;
        displayText = 'High';
        break;
      case 'critical':
        indicatorColor = Colors.purple;
        displayText = 'Critical';
        break;
      default:
        indicatorColor = Colors.grey;
        displayText = priority.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
        ).join(' ');
    }
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          displayText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: indicatorColor,
          ),
        ),
      ],
    );
  }
  
  void _showUpdateStatusDialog(BuildContext context, WorkOrder workOrder) {
    final statuses = ['open', 'assigned', 'in_progress', 'on_hold', 'completed', 'cancelled'];
    
    showDialog(
      context: context,
      builder: (context) {
        String selectedStatus = workOrder.status;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final status in statuses)
                    RadioListTile<String>(
                      title: Text(
                        status.replaceAll('_', ' ').split(' ').map((word) => 
                          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
                        ).join(' '),
                      ),
                      value: status,
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  if (selectedStatus == 'completed' || selectedStatus == 'cancelled') ...[
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      controller: _notesController,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    
                    // Update work order status
                    context.read<MaintenanceBloc>().add(
                      UpdateWorkOrderStatusEvent(
                        workOrderId: workOrder.id,
                        status: selectedStatus,
                        notes: _notesController.text.trim().isNotEmpty 
                            ? _notesController.text.trim() 
                            : null,
                      ),
                    );
                    
                    _notesController.clear();
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showAssignDialog(BuildContext context, WorkOrder workOrder) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Work Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Assign To',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Select User'),
                  ),
                  // Mock user data
                  ...List.generate(
                    3,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text('User ${index + 1}'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  // Handle user selection
                },
              ),
              const SizedBox(height: 16),
              // Notes field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Assign functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assignment functionality coming soon!'),
                  ),
                );
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }
  
  void _showEditDialog(BuildContext context, WorkOrder workOrder) {
    final titleController = TextEditingController(text: workOrder.title);
    final descriptionController = TextEditingController(text: workOrder.description);
    final dueDateController = TextEditingController(
      text: workOrder.dueDate != null 
          ? DateFormat('yyyy-MM-dd').format(workOrder.dueDate!) 
          : '',
    );
    
    showDialog(
      context: context,
      builder: (context) {
        String selectedPriority = workOrder.priority;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Work Order'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dueDateController,
                      decoration: const InputDecoration(
                        labelText: 'Due Date (YYYY-MM-DD)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: workOrder.dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        
                        if (date != null) {
                          setState(() {
                            dueDateController.text = DateFormat('yyyy-MM-dd').format(date);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Priority'),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'low',
                          groupValue: selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              selectedPriority = value!;
                            });
                          },
                        ),
                        const Text('Low'),
                        Radio<String>(
                          value: 'medium',
                          groupValue: selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              selectedPriority = value!;
                            });
                          },
                        ),
                        const Text('Medium'),
                        Radio<String>(
                          value: 'high',
                          groupValue: selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              selectedPriority = value!;
                            });
                          },
                        ),
                        const Text('High'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'critical',
                          groupValue: selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              selectedPriority = value!;
                            });
                          },
                        ),
                        const Text('Critical'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Edit work order functionality
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit functionality coming soon!'),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showAddTaskDialog(BuildContext context, WorkOrder workOrder) {
    final taskController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(
              labelText: 'Task Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add task functionality
                Navigator.pop(context);
                if (taskController.text.trim().isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add task functionality coming soon!'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  void _showTaskOptionsDialog(BuildContext context, WorkOrderTask task) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Task'),
                onTap: () {
                  Navigator.pop(context);
                  // Edit task functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit task functionality coming soon!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: Text(task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete'),
                onTap: () {
                  Navigator.pop(context);
                  // Mark task functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task update functionality coming soon!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Task', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // Delete task functionality
                  _showDeleteTaskConfirmation(context, task);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showDeleteTaskConfirmation(BuildContext context, WorkOrderTask task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                // Delete task functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delete task functionality coming soon!'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  
  void _showCompleteWorkOrderDialog(BuildContext context, WorkOrder workOrder) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete Work Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to mark this work order as completed?'),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Completion Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                
                // Complete work order
                context.read<MaintenanceBloc>().add(
                  UpdateWorkOrderStatusEvent(
                    workOrderId: workOrder.id,
                    status: 'completed',
                    notes: _notesController.text.trim().isNotEmpty 
                        ? _notesController.text.trim() 
                        : null,
                  ),
                );
                
                _notesController.clear();
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );
  }
  
  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _getImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      
      if (pickedFile != null) {
        // Handle picked image
        _showAddImageCaptionDialog(context, pickedFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showAddImageCaptionDialog(BuildContext context, XFile imageFile) {
    final captionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Caption'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(imageFile.path),
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  labelText: 'Caption (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Upload image functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upload image functionality coming soon!'),
                  ),
                );
              },
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }
  
  void _showImageDetail(BuildContext context, WorkOrderImage image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  image.url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                              loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.red,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(image.caption ?? 'Image'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // Share image functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share functionality coming soon!'),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        // Download image functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Download functionality coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (image.caption != null && image.caption!.isNotEmpty) ...[
                        Text(
                          image.caption!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        'Uploaded by ${image.uploadedBy} on ${DateFormat('MMM d, yyyy h:mm a').format(image.uploadedAt)}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}