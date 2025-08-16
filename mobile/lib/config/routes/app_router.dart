import 'package:flutter/material.dart';
import 'package:buildpro360_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:buildpro360_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:buildpro360_mobile/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:buildpro360_mobile/features/assets/presentation/pages/assets_list_page.dart';
import 'package:buildpro360_mobile/features/assets/presentation/pages/asset_detail_page.dart';
import 'package:buildpro360_mobile/features/projects/presentation/pages/projects_list_page.dart';
import 'package:buildpro360_mobile/features/projects/presentation/pages/project_detail_page.dart';
import 'package:buildpro360_mobile/features/maintenance/presentation/pages/work_orders_list_page.dart';
import 'package:buildpro360_mobile/features/maintenance/presentation/pages/work_order_detail_page.dart';
import 'package:buildpro360_mobile/features/compliance/presentation/pages/inspections_list_page.dart';
import 'package:buildpro360_mobile/features/compliance/presentation/pages/inspection_detail_page.dart';
import 'package:buildpro360_mobile/features/iot/presentation/pages/iot_device_list_page.dart';
import 'package:buildpro360_mobile/features/iot/presentation/pages/iot_device_detail_page.dart';
import 'package:buildpro360_mobile/features/reports/presentation/pages/reports_page.dart';
import 'package:buildpro360_mobile/features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  // Route names
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String assets = '/assets';
  static const String assetDetail = '/assets/detail';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/detail';
  static const String workOrders = '/work-orders';
  static const String workOrderDetail = '/work-orders/detail';
  static const String inspections = '/inspections';
  static const String inspectionDetail = '/inspections/detail';
  static const String iotDevices = '/iot-devices';
  static const String iotDeviceDetail = '/iot-devices/detail';
  static const String iotAlerts = '/iot-alerts';
  static const String reports = '/reports';
  static const String settings = '/settings';
  
  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      
      case assets:
        return MaterialPageRoute(builder: (_) => const AssetsListPage());
      
      case assetDetail:
        final assetId = args['assetId'] as int?;
        return MaterialPageRoute(builder: (_) => AssetDetailPage(assetId: assetId));
      
      case projects:
        return MaterialPageRoute(builder: (_) => const ProjectsListPage());
      
      case projectDetail:
        final projectId = args['projectId'] as int?;
        return MaterialPageRoute(builder: (_) => ProjectDetailPage(projectId: projectId));
      
      case workOrders:
        return MaterialPageRoute(builder: (_) => const WorkOrdersListPage());
      
      case workOrderDetail:
        final workOrderId = args['workOrderId'] as int?;
        return MaterialPageRoute(builder: (_) => WorkOrderDetailPage(workOrderId: workOrderId));
      
      case inspections:
        return MaterialPageRoute(builder: (_) => const InspectionsListPage());
      
      case inspectionDetail:
        final inspectionId = args['inspectionId'] as int?;
        return MaterialPageRoute(builder: (_) => InspectionDetailPage(inspectionId: inspectionId));
      
      case iotDevices:
        return MaterialPageRoute(builder: (_) => const IoTDeviceListPage());
      
      case iotDeviceDetail:
        final deviceId = args['deviceId'] as int?;
        return MaterialPageRoute(builder: (_) => IoTDeviceDetailPage(deviceId: deviceId));
      
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsPage());
      
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}