                  icon: const Icon(Icons.add_location),
                  label: const Text('Add Location'),
                ),
              ],
            ),
          );
  }
  
  Widget _buildInfoRow(String label, String value, {IconData? icon, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
          ],
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
  
  Widget _buildMaintenanceStatusItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDocumentItem(
    String name,
    String type,
    String size,
    DateTime uploadDate,
  ) {
    IconData typeIcon;
    
    switch (type.toLowerCase()) {
      case 'pdf':
        typeIcon = Icons.picture_as_pdf;
        break;
      case 'image':
      case 'jpg':
      case 'png':
        typeIcon = Icons.image;
        break;
      case 'doc':
      case 'docx':
        typeIcon = Icons.description;
        break;
      case 'xls':
      case 'xlsx':
        typeIcon = Icons.table_chart;
        break;
      default:
        typeIcon = Icons.insert_drive_file;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(typeIcon, color: Colors.blue),
        ),
        title: Text(name),
        subtitle: Text('$size • Uploaded ${DateFormat('MMM d, yyyy').format(uploadDate)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.blue),
              onPressed: () {
                // Download functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Download functionality coming soon!'),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show more options
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('More options coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () {
          // View document
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('View document functionality coming soon!'),
            ),
          );
        },
      ),
    );
  }
  
  void _showAssignDialog(BuildContext context, Asset asset) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Asset'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Projects dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Project',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Select Project'),
                  ),
                  // Mock project data
                  ...List.generate(
                    3,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text('Project ${index + 1}'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  // Handle project selection
                },
              ),
              const SizedBox(height: 16),
              // Users dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'User',
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
                // Assign asset functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Asset assignment functionality coming soon!'),
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
  
  void _showCreateMaintenanceDialog(BuildContext context, Asset asset) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Maintenance Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Maintenance type dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Maintenance Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Type'),
                  ),
                  ...['Preventive', 'Corrective', 'Inspection']
                      .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                ],
                onChanged: (value) {
                  // Handle type selection
                },
              ),
              const SizedBox(height: 16),
              // Description field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Performed by field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Performed By',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Cost field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Cost',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
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
                // Create maintenance record functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Maintenance record creation functionality coming soon!'),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
  
  void _showQRCodeDialog(BuildContext context, Asset asset) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Asset QR Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_2,
                    size: 150,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Asset ID: ${asset.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                asset.name,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Print QR code functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Print functionality coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.print),
              label: const Text('Print'),
            ),
          ],
        );
      },
    );
  }
  
  void _shareAssetDetails(Asset asset) {
    // Share asset details functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }
  
  void _launchMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps'),
        ),
      );
    }
  }
}