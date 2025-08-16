import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buildpro360_mobile/config/routes/app_router.dart';
import 'package:buildpro360_mobile/features/iot/presentation/bloc/iot_bloc.dart';
import 'package:intl/intl.dart';

class IoTAlertsPage extends StatefulWidget {
  const IoTAlertsPage({super.key});

  @override
  State<IoTAlertsPage> createState() => _IoTAlertsPageState();
}

class _IoTAlertsPageState extends State<IoTAlertsPage> {
  final _scrollController = ScrollController();
  String? _selectedStatus;
  String? _selectedSeverity;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initial fetch
    context.read<IoTBloc>().add(FetchAlertsEvent());
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isBottom) {
      final state = context.read<IoTBloc>().state;
      if (state is AlertsLoadedState && !state.hasReachedMax) {
        context.read<IoTBloc>().add(
          FetchAlertsEvent(
            page: state.currentPage + 1,
            status: _selectedStatus,
            severity: _selectedSeverity,
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
        title: const Text('IoT Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocBuilder<IoTBloc, IoTState>(
        builder: (context, state) {
          if (state is IoTInitialState || state is IoTLoadingState && state is! AlertsLoadedState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AlertsLoadedState) {
            return _buildAlertsList(state.alerts);
          } else if (state is IoTErrorState) {
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
                      context.read<IoTBloc>().add(
                        FetchAlertsEvent(
                          status: _selectedStatus,
                          severity: _selectedSeverity,
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
    );
  }
  
  Widget _buildAlertsList(List<dynamic> alerts) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'No alerts found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'All systems are running normally',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<IoTBloc>().add(
          FetchAlertsEvent(
            status: _selectedStatus,
            severity: _selectedSeverity,
          ),
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: alerts.length + 1, // +1 for the loader
        itemBuilder: (context, index) {
          if (index == alerts.length) {
            // Show loader at the bottom if we're still loading
            final state = context.watch<IoTBloc>().state;
            if (state is AlertsLoadedState && !state.hasReachedMax) {
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
          
          final alert = alerts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () {
                if (alert['device_id'] != null) {
                  Navigator.pushNamed(
                    context,
                    AppRouter.iotDeviceDetail,
                    arguments: {'deviceId': alert['device_id']},
                  );
                } else {
                  _showAlertDetailsDialog(context, alert);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildSeverityIndicator(alert['severity']),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alert['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusChip(alert['status']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alert['message'],
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Device: ${alert['device_name'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy h:mm a').format(DateTime.parse(alert['timestamp'])),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (alert['status'] == 'active') ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              _acknowledgeAlert(context, alert);
                            },
                            child: const Text('Acknowledge'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              _resolveAlert(context, alert);
                            },
                            child: const Text('Resolve'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSeverityIndicator(String severity) {
    Color indicatorColor;
    IconData indicatorIcon;
    
    switch (severity) {
      case 'critical':
        indicatorColor = Colors.red;
        indicatorIcon = Icons.warning;
        break;
      case 'high':
        indicatorColor = Colors.orange;
        indicatorIcon = Icons.warning;
        break;
      case 'medium':
        indicatorColor = Colors.amber;
        indicatorIcon = Icons.warning;
        break;
      case 'low':
        indicatorColor = Colors.blue;
        indicatorIcon = Icons.info;
        break;
      case 'info':
        indicatorColor = Colors.green;
        indicatorIcon = Icons.info;
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
  
  Widget _buildStatusChip(String status) {
    Color chipColor;
    String displayText;
    
    switch (status) {
      case 'active':
        chipColor = Colors.red;
        displayText = 'Active';
        break;
      case 'acknowledged':
        chipColor = Colors.orange;
        displayText = 'Acknowledged';
        break;
      case 'resolved':
        chipColor = Colors.green;
        displayText = 'Resolved';
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
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempStatus = _selectedStatus;
        String? tempSeverity = _selectedSeverity;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Alerts'),
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
                      ...['active', 'acknowledged', 'resolved']
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
                      labelText: 'Severity',
                      border: OutlineInputBorder(),
                    ),
                    value: tempSeverity,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Severities'),
                      ),
                      ...['critical', 'high', 'medium', 'low', 'info']
                          .map((severity) => DropdownMenuItem<String>(
                                value: severity,
                                child: Text(
                                  severity.replaceAll('_', ' ').split(' ').map((word) => 
                                    word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
                                  ).join(' '),
                                ),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tempSeverity = value;
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
                      tempSeverity = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = tempStatus;
                      _selectedSeverity = tempSeverity;
                    });
                    
                    context.read<IoTBloc>().add(
                      FetchAlertsEvent(
                        status: _selectedStatus,
                        severity: _selectedSeverity,
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
  
  void _showAlertDetailsDialog(BuildContext context, Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(alert['title']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Severity and Status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Severity',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert['severity'].replaceAll('_', ' ').split(' ').map((word) => 
                              word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
                            ).join(' '),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getSeverityColor(alert['severity']),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert['status'].replaceAll('_', ' ').split(' ').map((word) => 
                              word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
                            ).join(' '),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(alert['status']),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Message
                const Text(
                  'Message',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(alert['message']),
                const SizedBox(height: 16),
                
                // Device Info
                const Text(
                  'Device Information',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Device: ${alert['device_name'] ?? 'Unknown'}'),
                if (alert['device_id'] != null) ...[
                  const SizedBox(height: 4),
                  Text('Device ID: ${alert['device_id']}'),
                ],
                const SizedBox(height: 16),
                
                // Timestamp
                const Text(
                  'Timestamp',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(DateFormat('MMM d, yyyy h:mm:ss a').format(DateTime.parse(alert['timestamp']))),
                
                // Additional Information
                if (alert['additional_info'] != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...(alert['additional_info'] as Map<String, dynamic>).entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
          actions: [
            if (alert['status'] == 'active') ...[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _acknowledgeAlert(context, alert);
                },
                child: const Text('Acknowledge'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resolveAlert(context, alert);
                },
                child: const Text('Resolve'),
              ),
            ] else ...[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ],
        );
      },
    );
  }
  
  void _acknowledgeAlert(BuildContext context, Map<String, dynamic> alert) {
    context.read<IoTBloc>().add(
      AcknowledgeAlertEvent(
        alertId: alert['id'],
        username: 'current_user', // In a real app, this would be the logged-in user
      ),
    );
  }
  
  void _resolveAlert(BuildContext context, Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) {
        final notesController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Resolve Alert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add resolution notes (optional):'),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Resolution Notes',
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
              onPressed: () {
                Navigator.pop(context);
                
                context.read<IoTBloc>().add(
                  ResolveAlertEvent(
                    alertId: alert['id'],
                    username: 'current_user', // In a real app, this would be the logged-in user
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                  ),
                );
              },
              child: const Text('Resolve'),
            ),
          ],
        );
      },
    );
  }
  
  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.blue;
      case 'info':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.red;
      case 'acknowledged':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}