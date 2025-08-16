import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buildpro360_mobile/config/constants/app_constants.dart';
import 'package:buildpro360_mobile/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _reportTypeNotifier = ValueNotifier<String?>(null);
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  Map<String, dynamic> _reportParameters = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize with default dates
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    _startDateController.text = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(now);
    
    // Fetch templates and jobs
    context.read<ReportsBloc>().add(FetchReportTemplatesEvent());
    context.read<ReportsBloc>().add(FetchReportJobsEvent());
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _reportTypeNotifier.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Generate Report'),
            Tab(text: 'Recent Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGenerateReportTab(),
          _buildRecentReportsTab(),
        ],
      ),
    );
  }
  
  Widget _buildGenerateReportTab() {
    return BlocConsumer<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportGeneratedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report generation started. Check Recent Reports tab for status.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Switch to Recent Reports tab
          _tabController.animateTo(1);
          
          // Refresh report jobs
          context.read<ReportsBloc>().add(FetchReportJobsEvent());
        } else if (state is ReportsErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ReportsLoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ReportTemplatesLoadedState) {
          final templates = state.templates;
          
          if (templates.isEmpty) {
            return const Center(
              child: Text('No report templates available'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report Type Selection
                const Text(
                  'Select Report Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ValueListenableBuilder<String?>(
                      valueListenable: _reportTypeNotifier,
                      builder: (context, selectedReportType, _) {
                        return Column(
                          children: templates.map((template) {
                            final isSelected = selectedReportType == template['id'];
                            
                            return RadioListTile<String>(
                              title: Text(template['name']),
                              subtitle: Text(template['description'] ?? ''),
                              value: template['id'],
                              groupValue: selectedReportType,
                              onChanged: (value) {
                                _reportTypeNotifier.value = value;
                                
                                // Clear and update parameters
                                _reportParameters = {};
                                
                                // Add default date parameters
                                _reportParameters['start_date'] = _startDateController.text;
                                _reportParameters['end_date'] = _endDateController.text;
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Report Parameters
                const Text(
                  'Report Parameters',
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
                        // Date Range
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _startDateController,
                                decoration: const InputDecoration(
                                  labelText: 'Start Date',
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _parseDate(_startDateController.text) ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  
                                  if (date != null) {
                                    _startDateController.text = DateFormat('yyyy-MM-dd').format(date);
                                    _reportParameters['start_date'] = _startDateController.text;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _endDateController,
                                decoration: const InputDecoration(
                                  labelText: 'End Date',
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _parseDate(_endDateController.text) ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  
                                  if (date != null) {
                                    _endDateController.text = DateFormat('yyyy-MM-dd').format(date);
                                    _reportParameters['end_date'] = _endDateController.text;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Additional parameters based on report type
                        ValueListenableBuilder<String?>(
                          valueListenable: _reportTypeNotifier,
                          builder: (context, selectedReportType, _) {
                            if (selectedReportType == null) {
                              return const SizedBox.shrink();
                            }
                            
                            final template = templates.firstWhere(
                              (t) => t['id'] == selectedReportType,
                              orElse: () => <String, dynamic>{},
                            );
                            
                            final parameters = template['parameters'] as List<dynamic>? ?? [];
                            
                            if (parameters.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: parameters.map((param) {
                                final paramId = param['id'] as String;
                                final paramType = param['type'] as String;
                                final paramName = param['name'] as String;
                                final isRequired = param['required'] as bool? ?? false;
                                
                                if (paramType == 'boolean') {
                                  return SwitchListTile(
                                    title: Text(paramName),
                                    subtitle: Text(isRequired ? 'Required' : 'Optional'),
                                    value: _reportParameters[paramId] == true,
                                    onChanged: (value) {
                                      setState(() {
                                        _reportParameters[paramId] = value;
                                      });
                                    },
                                  );
                                } else if (paramType == 'select') {
                                  final options = param['options'] as List<dynamic>? ?? [];
                                  
                                  return DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: paramName,
                                      hintText: isRequired ? 'Required' : 'Optional',
                                    ),
                                    value: _reportParameters[paramId] as String?,
                                    items: [
                                      if (!isRequired)
                                        const DropdownMenuItem<String>(
                                          value: null,
                                          child: Text('All'),
                                        ),
                                      ...options.map((option) {
                                        return DropdownMenuItem<String>(
                                          value: option['value'],
                                          child: Text(option['label']),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _reportParameters[paramId] = value;
                                      });
                                    },
                                  );
                                } else {
                                  // Default to text input
                                  return TextField(
                                    decoration: InputDecoration(
                                      labelText: paramName,
                                      hintText: isRequired ? 'Required' : 'Optional',
                                    ),
                                    onChanged: (value) {
                                      _reportParameters[paramId] = value;
                                    },
                                  );
                                }
                              }).toList(),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Generate Button
                        ValueListenableBuilder<String?>(
                          valueListenable: _reportTypeNotifier,
                          builder: (context, selectedReportType, _) {
                            return ElevatedButton.icon(
                              onPressed: selectedReportType != null
                                  ? () {
                                      _generateReport(selectedReportType);
                                    }
                                  : null,
                              icon: const Icon(Icons.description),
                              label: const Text('Generate Report'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text('Failed to load report templates'),
          );
        }
      },
    );
  }
  
  Widget _buildRecentReportsTab() {
    return BlocConsumer<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportDownloadUrlLoadedState) {
          _launchURL(state.downloadUrl);
        }
      },
      builder: (context, state) {
        if (state is ReportJobsLoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ReportJobsLoadedState) {
          final jobs = state.jobs;
          
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No reports found',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate a report to see it here',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ReportsBloc>().add(FetchReportJobsEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job['report_name'] ?? 'Unknown Report',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatusChip(job['status']),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${_formatDateTime(job['created_at'])}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (job['completed_at'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Completed: ${_formatDateTime(job['completed_at'])}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (job['status'] == 'completed') ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<ReportsBloc>().add(
                                GetReportDownloadUrlEvent(reportId: job['id']),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 36),
                            ),
                          ),
                        ] else if (job['status'] == 'processing') ...[
                          OutlinedButton.icon(
                            onPressed: () {
                              context.read<ReportsBloc>().add(
                                GetReportStatusEvent(reportId: job['id']),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Check Status'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 36),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load reports'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ReportsBloc>().add(FetchReportJobsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color chipColor;
    String displayText;
    
    switch (status) {
      case 'completed':
        chipColor = Colors.green;
        displayText = 'Completed';
        break;
      case 'processing':
        chipColor = Colors.blue;
        displayText = 'Processing';
        break;
      case 'failed':
        chipColor = Colors.red;
        displayText = 'Failed';
        break;
      case 'queued':
        chipColor = Colors.orange;
        displayText = 'Queued';
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
  
  void _generateReport(String reportType) {
    // Validate dates
    final startDate = _parseDate(_startDateController.text);
    final endDate = _parseDate(_endDateController.text);
    
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (startDate.isAfter(endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start date cannot be after end date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Generate the report
    context.read<ReportsBloc>().add(
      GenerateReportEvent(
        reportType: reportType,
        parameters: _reportParameters,
      ),
    );
  }
  
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $url'),
        ),
      );
    }
  }
  
  DateTime? _parseDate(String date) {
    try {
      return DateFormat('yyyy-MM-dd').parse(date);
    } catch (e) {
      return null;
    }
  }
  
  String _formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }
}