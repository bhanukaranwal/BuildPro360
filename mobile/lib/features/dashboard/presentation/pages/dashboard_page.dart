                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    alert.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: _buildAlertStatusChip(alert.status),
                  onTap: () {
                    if (alert.deviceId != null) {
                      Navigator.pushNamed(
                        context,
                        AppRouter.iotDeviceDetail,
                        arguments: {'deviceId': int.parse(alert.deviceId!)},
                      );
                    } else {
                      Navigator.pushNamed(context, AppRouter.iotAlerts);
                    }
                  },
                ),
              );
            },
          ),
      ],
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
  
  Widget _buildInspectionTypeIndicator(String type) {
    Color indicatorColor;
    IconData indicatorIcon;
    
    switch (type) {
      case 'safety':
        indicatorColor = Colors.red;
        indicatorIcon = Icons.health_and_safety;
        break;
      case 'quality':
        indicatorColor = Colors.blue;
        indicatorIcon = Icons.thumb_up;
        break;
      case 'environmental':
        indicatorColor = Colors.green;
        indicatorIcon = Icons.eco;
        break;
      case 'regulatory':
        indicatorColor = Colors.purple;
        indicatorIcon = Icons.gavel;
        break;
      case 'maintenance':
        indicatorColor = Colors.orange;
        indicatorIcon = Icons.build;
        break;
      default:
        indicatorColor = Colors.grey;
        indicatorIcon = Icons.assignment;
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
  
  Widget _buildInspectionStatusChip(String status) {
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
  
  Widget _buildAlertSeverityIndicator(String severity) {
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
  
  Widget _buildAlertStatusChip(String status) {
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
  
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
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
                context.read<AuthBloc>().add(LogoutEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}