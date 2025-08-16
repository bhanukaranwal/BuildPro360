                            style: TextStyle(
                              color: device.hasLowBattery ? Colors.red : Colors.grey[700],
                              fontWeight: device.hasLowBattery ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      if (device.hasLowBattery)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Low Battery',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Latest telemetry
                    if (device.latestTelemetry.isNotEmpty) ...[
                      const Text(
                        'Latest Readings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: device.latestTelemetry.entries
                            .take(3)
                            .map((entry) => _buildTelemetryChip(entry.key, entry.value))
                            .toList(),
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
  
  Widget _buildDeviceTypeIcon(String type) {
    IconData iconData;
    Color iconColor;
    
    type = type.toLowerCase();
    
    if (type.contains('sensor')) {
      iconData = Icons.sensors;
      iconColor = Colors.blue;
    } else if (type.contains('camera')) {
      iconData = Icons.camera_alt;
      iconColor = Colors.purple;
    } else if (type.contains('gateway')) {
      iconData = Icons.router;
      iconColor = Colors.orange;
    } else if (type.contains('controller')) {
      iconData = Icons.desktop_windows;
      iconColor = Colors.green;
    } else if (type.contains('tracker')) {
      iconData = Icons.location_on;
      iconColor = Colors.red;
    } else {
      iconData = Icons.devices_other;
      iconColor = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(
        iconData,
        color: iconColor,
      ),
    );
  }
  
  Widget _buildTelemetryChip(String key, dynamic value) {
    String displayKey = key.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
    
    String displayValue;
    if (value is double) {
      displayValue = value.toStringAsFixed(1);
    } else if (value is bool) {
      displayValue = value ? 'On' : 'Off';
    } else {
      displayValue = value.toString();
    }
    
    // Add units for common measurements
    if (key.contains('temp')) {
      displayValue += '°C';
    } else if (key.contains('humid')) {
      displayValue += '%';
    } else if (key.contains('pressure')) {
      displayValue += ' hPa';
    } else if (key.contains('speed')) {
      displayValue += ' km/h';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue),
      ),
      child: Text(
        '$displayKey: $displayValue',
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempStatus = _selectedStatus;
        String? tempType = _selectedType;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Devices'),
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
                      ...['online', 'offline', 'maintenance', 'error']
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
                      labelText: 'Device Type',
                      border: OutlineInputBorder(),
                    ),
                    value: tempType,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Types'),
                      ),
                      ...['sensor', 'camera', 'gateway', 'controller', 'tracker']
                          .map((type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type.replaceAll('_', ' ').split(' ').map((word) => 
                                    word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
                                  ).join(' '),
                                ),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tempType = value;
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
                      tempType = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = tempStatus;
                      _selectedType = tempType;
                    });
                    
                    context.read<IoTBloc>().add(
                      FetchDevicesEvent(
                        status: _selectedStatus,
                        deviceType: _selectedType,
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
  
  void _showAlertsPage(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.iotAlerts);
  }
}