import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buildpro360_mobile/features/compliance/domain/models/inspection.dart';
import 'package:buildpro360_mobile/features/compliance/presentation/bloc/compliance_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InspectionDetailPage extends StatefulWidget {
  final int? inspectionId;
  
  const InspectionDetailPage({super.key, this.inspectionId});

  @override
  State<InspectionDetailPage> createState() => _InspectionDetailPageState();
}

class _InspectionDetailPageState extends State<InspectionDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (widget.inspectionId != null) {
      context.read<ComplianceBloc>().add(
        FetchInspectionDetailEvent(inspectionId: widget.inspectionId!),
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
    return BlocConsumer<ComplianceBloc, ComplianceState>(
      listener: (context, state) {
        if (state is InspectionUpdatedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inspection updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ComplianceErrorState) {
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
              state is InspectionDetailLoadedState 
                  ? state.inspection.title 
                  : 'Inspection Details',
            ),
            bottom: state is InspectionDetailLoadedState
                ? TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Checklist'),
                      Tab(text: 'Evidence'),
                    ],
                  )
                : null,
            actions: [
              if (state is InspectionDetailLoadedState && !state.inspection.isComplete)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    // Handle menu actions
                    switch (value) {
                      case 'update_status':
                        _showUpdateStatusDialog(context, state.inspection);
                        break;
                      case 'assign':
                        _showAssignDialog(context, state.inspection);
                        break;
                      case 'reschedule':
                        _showRescheduleDialog(context, state.inspection);
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
                      value: 'reschedule',
                      child: Row(
                        children: [
                          Icon(Icons.event),
                          SizedBox(width: 8),
                          Text('Reschedule'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: _buildBody(state),
          bottomNavigationBar: state is InspectionDetailLoadedState && !state.inspection.isComplete
              ? _buildActionBar(state.inspection)
              : null,
        );
      },
    );
  }
  
  Widget _buildBody(ComplianceState state) {
    if (state is ComplianceLoadingState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is InspectionDetailLoadedState) {
      final inspection = state.inspection;
      
      return TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(inspection),
          _buildChecklistTab(inspection),
          _buildEvidenceTab(inspection),
        ],
      );
    } else if (state is ComplianceErrorState) {
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
                if (widget.inspectionId != null) {
                  context.read<ComplianceBloc>().add(
                    FetchInspectionDetailEvent(inspectionId: widget.inspectionId!),
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
        child: Text('Inspection details not available'),
      );
    }
  }
  
  Widget _buildOverviewTab(Inspection inspection) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Type Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildStatusChip(inspection.status),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Type',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTypeChip(inspection.type),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (inspection.isComplete && inspection.result != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Result',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildResultChip(inspection.result!),
                  ],
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
              child: Text(inspection.description),
            ),
          ),
          const SizedBox(height: 16),
          
          // Progress
          if (inspection.items != null && inspection.items!.isNotEmpty) ...[
            const Text(
              'Progress',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${inspection.completedItemsCount}/${inspection.totalItemsCount} items completed',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${inspection.completionPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(inspection.completionPercentage),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: inspection.completionPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(inspection.completionPercentage),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Dates
          const Text(
            'Schedule',
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
                  _buildInfoRow('Created', inspection.formattedCreatedAt, Icons.event),
                  const Divider(),
                  _buildInfoRow(
                    'Scheduled', 
                    inspection.formattedScheduledDate, 
                    Icons.event_available,
                    valueColor: inspection.isOverdue ? Colors.red : null,
                  ),
                  
                  if (inspection.isComplete) ...[
                    const Divider(),
                    _buildInfoRow(
                      'Completed', 
                      inspection.formattedCompletedDate, 
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
                    inspection.assetName ?? 'Not assigned', 
                    Icons.build,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    'Assigned To', 
                    inspection.assignedToName ?? 'Not assigned', 
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
              child: inspection.notes != null && inspection.notes!.isNotEmpty
                  ? ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: inspection.notes!.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final note = inspection.notes![index];
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
  
  Widget _buildChecklistTab(Inspection inspection) {
    final items = inspection.items;
    
    if (items == null || items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.checklist,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No checklist items found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Add checklist items to this inspection',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Add checklist item functionality
                _showAddChecklistItemDialog(context, inspection);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Checklist Item'),
            ),
          ],
        ),
      );
    }
    
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildItemStatusIndicator(item.status),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (item.notes != null && item.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  item.notes!,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                              if (item.completedAt != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Completed: ${DateFormat('MMM d, yyyy').format(item.completedAt!)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                if (item.completedBy != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'By: ${item.completedBy}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!inspection.isComplete) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (item.isPending) ...[
                            ElevatedButton.icon(
                              onPressed: () {
                                // Mark as passed
                                _showUpdateItemStatusDialog(context, inspection, item, 'pass');
                              },
                              icon: const Icon(Icons.check),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              label: const Text('Pass'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Mark as failed
                                _showUpdateItemStatusDialog(context, inspection, item, 'fail');
                              },
                              icon: const Icon(Icons.close),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              label: const Text('Fail'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Mark as not applicable
                                _showUpdateItemStatusDialog(context, inspection, item, 'n/a');
                              },
                              icon: const Icon(Icons.not_interested),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                              label: const Text('N/A'),
                            ),
                          ] else ...[
                            OutlinedButton.icon(
                              onPressed: () {
                                // Reset item
                                _showResetItemConfirmation(context, inspection, item);
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        if (!inspection.isComplete)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'add_checklist_item',
              mini: true,
              onPressed: () {
                // Add checklist item functionality
                _showAddChecklistItemDialog(context, inspection);
              },
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
  
  Widget _buildEvidenceTab(Inspection inspection) {
    final images = inspection.images;
    
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
                      'No evidence images found',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add images as evidence for this inspection',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (!inspection.isComplete)
                      ElevatedButton.icon(
                        onPressed: () {
                          // Add image functionality
                          _showImageSourceDialog(context);
                        },
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Add Evidence'),
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
        if (!inspection.isComplete)
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
  
  Widget _buildActionBar(Inspection inspection) {
    if (inspection.isComplete) return const SizedBox.shrink();
    
    bool allItemsCompleted = inspection.items != null && 
                            inspection.items!.isNotEmpty && 
                            inspection.items!.every((item) => item.status != 'pending');
    
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
              onPressed: allItemsCompleted
                  ? () {
                      // Complete inspection functionality
                      _showCompleteInspectionDialog(context, inspection);
                    }
                  : null,
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
      case 'scheduled':
        chipColor = Colors.blue;
        displayText = 'Scheduled';
        break;
      case 'in_progress':
        chipColor = Colors.orange;
        displayText = 'In Progress';
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
      case 'scheduled':
        return Icons.event;
      case 'in_progress':
        return Icons.engineering;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
  
  Widget _buildTypeChip(String type) {
    Color chipColor;
    IconData chipIcon;
    String displayText;
    
    switch (type) {
      case 'safety':
        chipColor = Colors.red;
        chipIcon = Icons.health_and_safety;
        displayText = 'Safety';
        break;
      case 'quality':
        chipColor = Colors.blue;
        chipIcon = Icons.thumb_up;
        displayText = 'Quality';
        break;
      case 'environmental':
        chipColor = Colors.green;
        chipIcon = Icons.eco;
        displayText = 'Environmental';
        break;
      case 'regulatory':
        chipColor = Colors.purple;
        chipIcon = Icons.gavel;
        displayText = 'Regulatory';
        break;
      case 'maintenance':
        chipColor = Colors.orange;
        chipIcon = Icons.build;
        displayText = 'Maintenance';
        break;
      default:
        chipColor = Colors.grey;
        chipIcon = Icons.assignment;
        displayText = type.replaceAll('_', ' ').split(' ').map((word) => 
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
            chipIcon,
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
  
  Widget _buildResultChip(String result) {
    Color chipColor;
    IconData chipIcon;
    
    switch (result) {
      case 'pass':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case 'fail':
        chipColor = Colors.red;
        chipIcon = Icons.cancel;
        break;
      case 'conditional_pass':
        chipColor = Colors.orange;
        chipIcon = Icons.error;
        break;
      default:
        chipColor = Colors.grey;
        chipIcon = Icons.help;
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
            chipIcon,
            color: chipColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            result.replaceAll('_', ' ').split(' ').map((word) => 
              word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
            ).join(' '),
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildItemStatusIndicator(String status) {
    Color indicatorColor;
    IconData indicatorIcon;
    
    switch (status) {
      case 'pass':
        indicatorColor = Colors.green;
        indicatorIcon = Icons.check_circle;
        break;
      case 'fail':
        indicatorColor = Colors.red;
        indicatorIcon = Icons.cancel;
        break;
      case 'n/a':
        indicatorColor = Colors.grey;
        indicatorIcon = Icons.not_interested;
        break;
      default:
        indicatorColor = Colors.blue;
        indicatorIcon = Icons.radio_button_unchecked;
    }
    
    return CircleAvatar(
      backgroundColor: indicatorColor.withOpacity(0.1),
      child: Icon(
        indicatorIcon,
        color: indicatorColor,
      ),
    );
  }
  
  Color _getProgressColor(double progress) {
    if (progress >= 75) {
      return Colors.green;
    } else if (progress >= 50) {
      return Colors.blue;
    } else if (progress >= 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  void _showUpdateStatusDialog(BuildContext context, Inspection inspection) {
    final statuses = ['scheduled', 'in_progress', 'completed', 'cancelled'];
    
    showDialog(
      context: context,
      builder: (context) {
        String selectedStatus = inspection.status;
        
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
                    
                    // Update inspection status
                    context.read<ComplianceBloc>().add(
                      UpdateInspectionStatusEvent(
                        inspectionId: inspection.id,
                        status: selectedStatus,
                      ),
                    );
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
  
  void _showAssignDialog(BuildContext context, Inspection inspection) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Inspection'),
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
  
  void _showRescheduleDialog(BuildContext context, Inspection inspection) {
    final scheduledDateController = TextEditingController(
      text: inspection.scheduledDate != null 
          ? DateFormat('yyyy-MM-dd').format(inspection.scheduledDate!) 
          : '',
    );
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reschedule Inspection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: scheduledDateController,
                decoration: const InputDecoration(
                  labelText: 'New Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: inspection.scheduledDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  
                  if (date != null) {
                    scheduledDateController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Reason for Rescheduling',
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
                // Reschedule functionality
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reschedule functionality coming soon!'),
                  ),
                );
              },
              child: const Text('Reschedule'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddChecklistItemDialog(BuildContext context, Inspection inspection) {
    final itemController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Checklist Item'),
          content: TextField(
            controller: itemController,
            decoration: const InputDecoration(
              labelText: 'Item Description',
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
                // Add checklist item functionality
                Navigator.pop(context);
                if (itemController.text.trim().isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add checklist item functionality coming soon!'),
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
  
  void _showUpdateItemStatusDialog(BuildContext context, Inspection inspection, InspectionItem item, String newStatus) {
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mark Item as ${newStatus.toUpperCase()}'),
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
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
                // Update item status functionality
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Update item status functionality coming soon!'),
                  ),
                );
              },
              child: const Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == 'pass' 
                    ? Colors.green 
                    : newStatus == 'fail' 
                        ? Colors.red 
                        : Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showResetItemConfirmation(BuildContext context, Inspection inspection, InspectionItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Item'),
          content: const Text('Are you sure you want to reset this item to pending status?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Reset item functionality
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reset item functionality coming soon!'),
                  ),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
  
  void _showCompleteInspectionDialog(BuildContext context, Inspection inspection) {
    String selectedResult = 'pass';
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Complete Inspection'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select the final result of this inspection:'),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text('Pass'),
                    value: 'pass',
                    groupValue: selectedResult,
                    onChanged: (value) {
                      setState(() {
                        selectedResult = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Conditional Pass'),
                    value: 'conditional_pass',
                    groupValue: selectedResult,
                    onChanged: (value) {
                      setState(() {
                        selectedResult = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Fail'),
                    value: 'fail',
                    groupValue: selectedResult,
                    onChanged: (value) {
                      setState(() {
                        selectedResult = value!;
                      });
                    },
                  ),
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
                    
                    // Complete inspection functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Complete inspection functionality coming soon!'),
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
  
  void _showImageDetail(BuildContext context, InspectionImage image) {
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