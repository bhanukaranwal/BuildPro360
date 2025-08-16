            controller: commandController,
            decoration: const InputDecoration(
              labelText: 'JSON Command',
              hintText: '{"action": "custom_action", "param": "value"}',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
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
                
                try {
                  final commandJson = json.decode(commandController.text);
                  if (commandJson is Map<String, dynamic>) {
                    _sendCommand(device, commandJson);
                  } else {
                    throw FormatException('Invalid JSON format');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid JSON format: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
  
  void _showSensorConfigDialog(BuildContext context, IoTDevice device) {
    final intervalController = TextEditingController(text: '5');
    bool enableAlerts = true;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Configure Sensor'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: intervalController,
                    decoration: const InputDecoration(
                      labelText: 'Reporting Interval (minutes)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Alerts'),
                    value: enableAlerts,
                    onChanged: (value) {
                      setState(() {
                        enableAlerts = value;
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
                    
                    final interval = int.tryParse(intervalController.text);
                    if (interval != null && interval > 0) {
                      _sendCommand(device, {
                        'action': 'configure',
                        'reporting_interval': interval,
                        'enable_alerts': enableAlerts,
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid interval value'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showGatewayConfigDialog(BuildContext context, IoTDevice device) {
    final ssidController = TextEditingController();
    final passwordController = TextEditingController();
    bool autoUpdate = true;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Configure Gateway'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ssidController,
                    decoration: const InputDecoration(
                      labelText: 'WiFi SSID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'WiFi Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Auto Update Firmware'),
                    value: autoUpdate,
                    onChanged: (value) {
                      setState(() {
                        autoUpdate = value;
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
                    
                    final ssid = ssidController.text.trim();
                    final password = passwordController.text.trim();
                    
                    if (ssid.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('SSID cannot be empty'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    _sendCommand(device, {
                      'action': 'configure',
                      'wifi_ssid': ssid,
                      'wifi_password': password,
                      'auto_update': autoUpdate,
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  String _formatTelemetryValue(dynamic value, String sensorName) {
    if (value == null) return 'N/A';
    
    String formatted;
    if (value is double) {
      formatted = value.toStringAsFixed(2);
    } else if (value is bool) {
      formatted = value ? 'On' : 'Off';
    } else {
      formatted = value.toString();
    }
    
    // Add units for common measurements
    if (sensorName.contains('temp')) {
      formatted += '°C';
    } else if (sensorName.contains('humid')) {
      formatted += '%';
    } else if (sensorName.contains('pressure')) {
      formatted += ' hPa';
    } else if (sensorName.contains('speed')) {
      formatted += ' km/h';
    } else if (sensorName.contains('battery')) {
      formatted += '%';
    } else if (sensorName.contains('voltage')) {
      formatted += ' V';
    } else if (sensorName.contains('current')) {
      formatted += ' A';
    }
    
    return formatted;
  }
}