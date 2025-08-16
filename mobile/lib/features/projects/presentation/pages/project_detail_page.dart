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
  
  Color _getTaskStatusColor(String status) {
    switch (status) {
      case 'not_started':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'delayed':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  Widget _getTaskStatusIcon(String status) {
    switch (status) {
      case 'not_started':
        return const Icon(Icons.schedule, color: Colors.white);
      case 'in_progress':
        return const Icon(Icons.sync, color: Colors.white);
      case 'completed':
        return const Icon(Icons.check, color: Colors.white);
      case 'delayed':
        return const Icon(Icons.warning, color: Colors.white);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.white);
      default:
        return const Icon(Icons.help, color: Colors.white);
    }
  }
  
  Color _getTaskProgressColor(double progress) {
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
  
  IconData _getAssetTypeIcon(String assetType) {
    assetType = assetType.toLowerCase();
    
    if (assetType.contains('vehicle') || assetType.contains('truck')) {
      return Icons.local_shipping;
    } else if (assetType.contains('tool')) {
      return Icons.handyman;
    } else if (assetType.contains('equipment') || assetType.contains('machine')) {
      return Icons.precision_manufacturing;
    } else if (assetType.contains('scaffold')) {
      return Icons.architecture;
    } else if (assetType.contains('safety')) {
      return Icons.health_and_safety;
    } else {
      return Icons.build;
    }
  }
  
  void _showTeamMemberOptions(BuildContext context, ProjectMember member) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('View Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // View profile functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View profile functionality coming soon!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Message'),
                onTap: () {
                  Navigator.pop(context);
                  // Message functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message functionality coming soon!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Role'),
                onTap: () {
                  Navigator.pop(context);
                  // Edit role functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit role functionality coming soon!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove from Project', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // Remove functionality
                  _showRemoveMemberConfirmation(context, member);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showRemoveMemberConfirmation(BuildContext context, ProjectMember member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Team Member'),
          content: Text('Are you sure you want to remove ${member.name} from this project?'),
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
                // Remove member functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Remove member functionality coming soon!'),
                  ),
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
  
  void _generateReport(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Generate Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select report type:'),
              const SizedBox(height: 16),
              ...['Project Status Report', 'Budget Report', 'Timeline Report', 'Team Performance Report']
                .map((type) => ListTile(
                  title: Text(type),
                  leading: Radio<String>(
                    value: type,
                    groupValue: null, // This would be set by a state variable in a real implementation
                    onChanged: (value) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Generating $value'),
                        ),
                      );
                    },
                  ),
                ))
                .toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  
  void _exportProject(Project project) {
    // Export project functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
      ),
    );
  }
  
  void _shareProject(Project project) {
    // Share project functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }
}