import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buildpro360_mobile/config/constants/app_constants.dart';
import 'package:buildpro360_mobile/config/routes/app_router.dart';
import 'package:buildpro360_mobile/features/projects/domain/models/project.dart';
import 'package:buildpro360_mobile/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:intl/intl.dart';

class ProjectsListPage extends StatefulWidget {
  const ProjectsListPage({super.key});

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  final _scrollController = ScrollController();
  String? _selectedStatus;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initial fetch
    context.read<ProjectsBloc>().add(FetchProjectsEvent());
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isBottom) {
      final state = context.read<ProjectsBloc>().state;
      if (state is ProjectsLoadedState && !state.hasReachedMax) {
        context.read<ProjectsBloc>().add(
          FetchProjectsEvent(
            page: state.currentPage + 1,
            status: _selectedStatus,
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
        title: const Text('Projects'),
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
      body: BlocBuilder<ProjectsBloc, ProjectsState>(
        builder: (context, state) {
          if (state is ProjectsInitialState || state is ProjectsLoadingState && state is! ProjectsLoadedState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ProjectsLoadedState) {
            return _buildProjectList(state.projects);
          } else if (state is ProjectsErrorState) {
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
                      context.read<ProjectsBloc>().add(
                        FetchProjectsEvent(
                          status: _selectedStatus,
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
          // Add project functionality would go here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add project functionality coming soon!'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildProjectList(List<Project> projects) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.business,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No projects found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                });
                
                context.read<ProjectsBloc>().add(FetchProjectsEvent());
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProjectsBloc>().add(
          FetchProjectsEvent(
            status: _selectedStatus,
          ),
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: projects.length + 1, // +1 for the loader
        itemBuilder: (context, index) {
          if (index == projects.length) {
            // Show loader at the bottom if we're still loading
            final state = context.watch<ProjectsBloc>().state;
            if (state is ProjectsLoadedState && !state.hasReachedMax) {
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
          
          final project = projects[index];
          return _buildProjectCard(project);
        },
      ),
    );
  }
  
  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.projectDetail,
            arguments: {'projectId': project.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(project.status),
                ],
              ),
              const SizedBox(height: 16),
              
              // Client and location
              if (project.client != null || project.location != null)
                Row(
                  children: [
                    if (project.client != null)
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(project.client!)),
                          ],
                        ),
                      ),
                    if (project.location != null)
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(project.location!)),
                          ],
                        ),
                      ),
                  ],
                ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress: ${project.progressDisplay}'),
                      Text('${project.completedTasksCount}/${project.totalTasksCount} tasks'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: project.progress / 100,
                    backgroundColor: Colors.grey[300],
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      project.progress > 75
                          ? Colors.green
                          : project.progress > 50
                              ? Colors.blue
                              : project.progress > 25
                                  ? Colors.orange
                                  : Colors.red,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Dates and budget
              Row(
                children: [
                  Expanded(
                    child: _buildProjectInfoItem(
                      'Start',
                      project.formattedStartDate,
                      Icons.calendar_today,
                    ),
                  ),
                  Expanded(
                    child: _buildProjectInfoItem(
                      'Deadline',
                      project.formattedEndDate,
                      Icons.event,
                      isHighlighted: !project.isOnSchedule,
                    ),
                  ),
                  Expanded(
                    child: _buildProjectInfoItem(
                      'Budget',
                      project.formattedBudget,
                      Icons.attach_money,
                      isHighlighted: project.isOverBudget,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData? chipIcon;
    
    switch (status) {
      case 'planning':
        chipColor = Colors.blue;
        chipIcon = Icons.edit;
        break;
      case 'in_progress':
        chipColor = Colors.orange;
        chipIcon = Icons.construction;
        break;
      case 'on_hold':
        chipColor = Colors.amber;
        chipIcon = Icons.pause;
        break;
      case 'completed':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case 'cancelled':
        chipColor = Colors.red;
        chipIcon = Icons.cancel;
        break;
      default:
        chipColor = Colors.grey;
        chipIcon = Icons.help;
    }
    
    return Chip(
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor),
      label: Text(
        status.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
        ).join(' '),
        style: TextStyle(color: chipColor),
      ),
      avatar: Icon(chipIcon, color: chipColor, size: 18),
    );
  }
  
  Widget _buildProjectInfoItem(
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isHighlighted ? Colors.red : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isHighlighted ? Colors.red : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempStatus = _selectedStatus;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Projects'),
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
                      ...AppConstants.projectStatuses
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
                    });
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = tempStatus;
                    });
                    
                    context.read<ProjectsBloc>().add(
                      FetchProjectsEvent(
                        status: _selectedStatus,
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