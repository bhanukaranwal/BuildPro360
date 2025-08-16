import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buildpro360_mobile/config/constants/app_constants.dart';
import 'package:buildpro360_mobile/config/routes/app_router.dart';
import 'package:buildpro360_mobile/features/assets/domain/models/asset.dart';
import 'package:buildpro360_mobile/features/assets/presentation/bloc/assets_bloc.dart';

class AssetsListPage extends StatefulWidget {
  const AssetsListPage({super.key});

  @override
  State<AssetsListPage> createState() => _AssetsListPageState();
}

class _AssetsListPageState extends State<AssetsListPage> {
  final _scrollController = ScrollController();
  String? _selectedStatus;
  String? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initial fetch
    context.read<AssetsBloc>().add(FetchAssetsEvent());
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isBottom) {
      final state = context.read<AssetsBloc>().state;
      if (state is AssetsLoadedState && !state.hasReachedMax) {
        context.read<AssetsBloc>().add(
          FetchAssetsEvent(
            page: state.currentPage + 1,
            status: _selectedStatus,
            category: _selectedCategory,
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
        title: const Text('Assets'),
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
      body: BlocBuilder<AssetsBloc, AssetsState>(
        builder: (context, state) {
          if (state is AssetsInitialState || state is AssetsLoadingState && state is! AssetsLoadedState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AssetsLoadedState) {
            return _buildAssetList(state.assets);
          } else if (state is AssetsErrorState) {
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
                      context.read<AssetsBloc>().add(
                        FetchAssetsEvent(
                          status: _selectedStatus,
                          category: _selectedCategory,
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
          // Add asset functionality would go here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add asset functionality coming soon!'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildAssetList(List<Asset> assets) {
    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.engineering,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No assets found',
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
                  _selectedCategory = null;
                });
                
                context.read<AssetsBloc>().add(FetchAssetsEvent());
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AssetsBloc>().add(
          FetchAssetsEvent(
            status: _selectedStatus,
            category: _selectedCategory,
          ),
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: assets.length + 1, // +1 for the loader
        itemBuilder: (context, index) {
          if (index == assets.length) {
            // Show loader at the bottom if we're still loading
            final state = context.watch<AssetsBloc>().state;
            if (state is AssetsLoadedState && !state.hasReachedMax) {
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
          
          final asset = assets[index];
          return _buildAssetListItem(asset);
        },
      ),
    );
  }
  
  Widget _buildAssetListItem(Asset asset) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.assetDetail,
            arguments: {'assetId': asset.id},
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
                      asset.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(asset.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.category, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(asset.typeDisplay),
                  const SizedBox(width: 16),
                  const Icon(Icons.construction, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(asset.categoryDisplay),
                ],
              ),
              const SizedBox(height: 8),
              if (asset.serialNumber != null)
                Row(
                  children: [
                    const Icon(Icons.numbers, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('SN: ${asset.serialNumber}'),
                  ],
                ),
              const SizedBox(height: 8),
              if (asset.location != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(asset.location!),
                  ],
                ),
              const SizedBox(height: 8),
              if (asset.currentProjectName != null)
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Project: ${asset.currentProjectName}'),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (asset.condition != null)
                    _buildConditionIndicator(asset.condition!),
                  if (asset.nextMaintenance != null)
                    _buildMaintenanceIndicator(asset.nextMaintenance!),
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
      case 'available':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case 'in_use':
      case 'assigned':
        chipColor = Colors.blue;
        chipIcon = Icons.engineering;
        break;
      case 'maintenance':
        chipColor = Colors.orange;
        chipIcon = Icons.build;
        break;
      case 'out_of_service':
        chipColor = Colors.red;
        chipIcon = Icons.error;
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
  
  Widget _buildConditionIndicator(double condition) {
    Color indicatorColor;
    String conditionText;
    
    if (condition >= 80) {
      indicatorColor = Colors.green;
      conditionText = 'Excellent';
    } else if (condition >= 60) {
      indicatorColor = Colors.lightGreen;
      conditionText = 'Good';
    } else if (condition >= 40) {
      indicatorColor = Colors.orange;
      conditionText = 'Fair';
    } else if (condition >= 20) {
      indicatorColor = Colors.deepOrange;
      conditionText = 'Poor';
    } else {
      indicatorColor = Colors.red;
      conditionText = 'Critical';
    }
    
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Condition: $conditionText',
          style: TextStyle(color: indicatorColor),
        ),
      ],
    );
  }
  
  Widget _buildMaintenanceIndicator(DateTime nextMaintenance) {
    final now = DateTime.now();
    final difference = nextMaintenance.difference(now);
    
    Color indicatorColor;
    String maintenanceText;
    
    if (difference.isNegative) {
      indicatorColor = Colors.red;
      maintenanceText = 'Maintenance Overdue';
    } else if (difference.inDays < 7) {
      indicatorColor = Colors.orange;
      maintenanceText = 'Maintenance Due Soon';
    } else {
      indicatorColor = Colors.green;
      maintenanceText = 'Maintenance Scheduled';
    }
    
    return Row(
      children: [
        Icon(Icons.build, size: 16, color: indicatorColor),
        const SizedBox(width: 4),
        Text(
          maintenanceText,
          style: TextStyle(color: indicatorColor),
        ),
      ],
    );
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempStatus = _selectedStatus;
        String? tempCategory = _selectedCategory;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Assets'),
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
                      ...['available', 'in_use', 'assigned', 'maintenance', 'out_of_service']
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
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: tempCategory,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...AppConstants.assetCategories
                          .map((category) => DropdownMenuItem<String>(
                                value: category.toLowerCase().replaceAll(' ', '_'),
                                child: Text(category),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tempCategory = value;
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
                      tempCategory = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = tempStatus;
                      _selectedCategory = tempCategory;
                    });
                    
                    context.read<AssetsBloc>().add(
                      FetchAssetsEvent(
                        status: _selectedStatus,
                        category: _selectedCategory,
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