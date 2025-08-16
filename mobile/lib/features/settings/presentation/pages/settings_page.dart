import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buildpro360_mobile/core/services/local_storage_service.dart';
import 'package:buildpro360_mobile/core/services/notification_service.dart';
import 'package:buildpro360_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _darkMode = false;
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  String _appVersion = '';
  String _buildNumber = '';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }
  
  Future<void> _loadSettings() async {
    final isDarkMode = await _localStorageService.isDarkMode();
    final isBiometricEnabled = await _localStorageService.isBiometricEnabled();
    
    setState(() {
      _darkMode = isDarkMode;
      _biometricEnabled = isBiometricEnabled;
    });
  }
  
  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LogoutSuccessState) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: ListView(
          children: [
            const SizedBox(height: 16),
            
            // Appearance
            _buildSectionHeader('Appearance'),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme throughout the app'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
                _localStorageService.setDarkMode(value);
                
                // This would be handled by a BLoC in a real app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please restart the app to apply theme changes'),
                  ),
                );
              },
            ),
            
            // Security
            _buildSectionHeader('Security'),
            SwitchListTile(
              title: const Text('Biometric Authentication'),
              subtitle: const Text('Use fingerprint or face ID to login'),
              value: _biometricEnabled,
              onChanged: (value) async {
                // In a real app, we would verify biometric hardware is available
                setState(() {
                  _biometricEnabled = value;
                });
                await _localStorageService.setBiometricEnabled(value);
              },
            ),
            ListTile(
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              leading: const Icon(Icons.lock),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to change password page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Change password functionality coming soon!'),
                  ),
                );
              },
            ),
            
            // Notifications
            _buildSectionHeader('Notifications'),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive alerts and updates'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                
                // In a real app, we would update notification settings
                final notificationService = NotificationService();
                if (value) {
                  notificationService.init();
                } else {
                  notificationService.cancelAllNotifications();
                }
              },
            ),
            ListTile(
              title: const Text('Notification Preferences'),
              subtitle: const Text('Configure what notifications you receive'),
              leading: const Icon(Icons.notifications_active),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to notification preferences page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification preferences coming soon!'),
                  ),
                );
              },
            ),
            
            // Data Management
            _buildSectionHeader('Data Management'),
            ListTile(
              title: const Text('Clear Cache'),
              subtitle: const Text('Remove temporary data to free up space'),
              leading: const Icon(Icons.cleaning_services),
              onTap: () async {
                await _localStorageService.clearCache();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Download Data'),
              subtitle: const Text('Save local data for offline use'),
              leading: const Icon(Icons.download),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to download data page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Download data functionality coming soon!'),
                  ),
                );
              },
            ),
            
            // Support
            _buildSectionHeader('Support & About'),
            ListTile(
              title: const Text('Help Center'),
              subtitle: const Text('View FAQs and documentation'),
              leading: const Icon(Icons.help),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _launchURL('https://buildpro360.com/help');
              },
            ),
            ListTile(
              title: const Text('Contact Support'),
              subtitle: const Text('Get assistance from our team'),
              leading: const Icon(Icons.support_agent),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _launchURL('mailto:support@buildpro360.com');
              },
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              leading: const Icon(Icons.privacy_tip),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _launchURL('https://buildpro360.com/privacy');
              },
            ),
            ListTile(
              title: const Text('Terms of Service'),
              leading: const Icon(Icons.description),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _launchURL('https://buildpro360.com/terms');
              },
            ),
            ListTile(
              title: const Text('About'),
              subtitle: Text('Version $_appVersion (Build $_buildNumber)'),
              leading: const Icon(Icons.info),
              onTap: () {
                _showAboutDialog();
              },
            ),
            
            // Account
            _buildSectionHeader('Account'),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () {
                _showLogoutConfirmation();
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
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
  
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'BuildPro360',
      applicationVersion: 'Version $_appVersion (Build $_buildNumber)',
      applicationIcon: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.construction,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      children: [
        const SizedBox(height: 24),
        const Text(
          'BuildPro360 is a comprehensive construction management application designed to streamline asset tracking, project management, maintenance, and compliance processes.',
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2025 BuildPro360 Inc. All rights reserved.',
        ),
      ],
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
}