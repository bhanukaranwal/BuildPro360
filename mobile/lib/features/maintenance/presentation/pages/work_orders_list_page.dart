import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buildpro360_mobile/config/routes/app_router.dart';
import 'package:buildpro360_mobile/features/maintenance/domain/models/work_order.dart';
import 'package:buildpro360_mobile/features/maintenance/presentation/bloc/maintenance_bloc.dart';
import 'package:intl/intl.dart';

class WorkOrdersListPage extends StatefulWidget {
  const WorkOrdersListPage({super.key});

  @override
  State<WorkOrdersListPage> createState() => _WorkOrdersListPageState();
}

class _WorkOrdersListPageState extends State<WorkOrdersListPage> {
  final _scrollController = ScrollController();
  String? _selectedStatus;
  String? _selectedPriority;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initial fetch
    context.read<MaintenanceBloc>().add(FetchWorkOrdersEvent());
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isBottom) {
      final state = context.read<MaintenanceBloc>().state;
      if (state is WorkOrdersLoadedState && !state.hasReachedMax) {
        context.read<MaintenanceBloc>().add(
          FetchWorkOrdersEvent(
            page: state.currentPage + 1,
            status: _selectedStatus,
            priority: _selectedPriority,
          ),
        );
      }
    }
  }
  
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    
    // Load more when we're 200 pixels from the bottom
    return currentScroll >= (maxScroll - 200);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
        ],
      ),
      body: BlocBuilder<MaintenanceBloc, MaintenanceState>(
        builder: (context, state) {
          if (state is MaintenanceInitialState || 
              state is MaintenanceLoadingState && state is! WorkOrdersLoadedState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is WorkOrdersLoadedState) {
            return _buildWorkOrdersList(state.workOrders);
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
                      context.read<MaintenanceBloc>().add(
                        FetchWorkOrdersEvent(
                          status: _selectedStatus,
                          priority: _selectedPriority,
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('Unknown state'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create work order functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create work order functionality coming soon!'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildWorkOrdersList(List<WorkOrder> workOrders) {
    if (workOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No work orders found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or create a new work order',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                  _selectedPriority = null;
                });
                
                context.read<MaintenanceBloc>().add(FetchWorkOrdersEvent());
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MaintenanceBloc>().add(
          FetchWorkOrdersEvent(
            status: _selectedStatus,
            priority: _selectedPriority,
          ),
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: workOrders.length + 1, // +1 for the loader
        itemBuilder: (context, index) {
          if (index == workOrders.length) {
            // Show loader at the bottom if we're still loading
            final state = context.watch<MaintenanceBloc>().state;
            if (state is WorkOrdersLoadedState && !state.hasReachedMax) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }
          
          final workOrder = workOrders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.workOrderDetail,
                  arguments: {'workOrderId': workOrder.id},
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildPriorityIndicator(workOrder.priority),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            workOrder.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusChip(workOrder.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Asset',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.build, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(workOrder.assetName ?? 'Not assigned'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Assigned To',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(workOrder.assignedToName ?? 'Not assigned'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (workOrder.dueDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 16,
                            color: workOrder.isOverdue ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${workOrder.formattedDueDate}',
                            style: TextStyle(
                              fontWeight: workOrder.isOverdue ? FontWeight.bold : null,
                              color: workOrder.isOverdue ? Colors.red : null,
                            ),
                          ),
                          if (workOrder.isOverdue) ...[
                            const SizedBox(width: 4),
                            const Text(
                              'OVERDUE',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        border: Border.all(color: chipColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(color: chipColor),
      ),
    );
  }
  
  Widget _buildPriorityIndicator(String priority) {
    Color indicatorColor;
    IconData indicatorIcon;
    
    switch (priority) {
      case 'low':
        indicatorColor = Colors.green;
        indicatorIcon = Icons.arrow_downward;
        break;
      case 'medium':
        indicatorColor = Colors.orange;
        indicatorIcon = Icons.remove;
        break;
      case 'high':
        indicatorColor = Colors.red;
        indicatorIcon = Icons.arrow_upward;
        break;
      case 'critical':
        indicatorColor = Colors.purple;
        indicatorIcon = Icons.priority_high;
        break;
      default:
        indicatorColor = Colors.grey;
        indicatorIcon = Icons.help;
    }
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        border: Border.all(color: indicatorColor),
        shape: BoxShape.circle,
      ),
      child: Icon(
        indicatorIcon,
        color: indicatorColor,
        size: 16,
      ),
    );
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempStatus = _selectedStatus;
        String? tempPriority = _selectedPriority;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Work Orders'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    value: tempStatus,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...['open', 'assigned', 'in_progress', 'on_hold', 'completed', 'cancelled']
                          .map((status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(
                                  status.replaceAll('_', ' ').split(' ').map((word) => 
                                    word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
                                  ).join(' '),
                                ),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tempStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    value: tempPriority,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Priorities'),
                      ),
                      ...['low', 'medium', 'high', 'critical']
                          .map((priority) => DropdownMenuItem<String>(
                                value: priority,
                                child: Text(
                                  priority.replaceAll('_', ' ').split(' ').map((word) => 
                                    word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
                                  ).join(' '),
                                ),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tempPriority = value;
                      });
                    },
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
                TextButton(
                  onPressed: () {
                    setState(() {
                      tempStatus = null;
                      tempPriority = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = tempStatus;
                      _selectedPriority = tempPriority;
                    });
                    
                    context.read<MaintenanceBloc>().add(
                      FetchWorkOrdersEvent(
                        status: _selectedStatus,
                        priority: _selectedPriority,
                      ),
                    );
                    
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}