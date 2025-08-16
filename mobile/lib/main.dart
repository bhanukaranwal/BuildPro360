import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:buildpro360_mobile/config/routes/app_router.dart';
import 'package:buildpro360_mobile/config/theme/app_theme.dart';
import 'package:buildpro360_mobile/core/services/api_service.dart';
import 'package:buildpro360_mobile/core/services/local_storage_service.dart';
import 'package:buildpro360_mobile/core/services/notification_service.dart';
import 'package:buildpro360_mobile/core/services/analytics_service.dart';
import 'package:buildpro360_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:buildpro360_mobile/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:buildpro360_mobile/features/assets/presentation/bloc/assets_bloc.dart';
import 'package:buildpro360_mobile/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:buildpro360_mobile/features/maintenance/presentation/bloc/maintenance_bloc.dart';
import 'package:buildpro360_mobile/features/compliance/presentation/bloc/compliance_bloc.dart';
import 'package:buildpro360_mobile/features/iot/presentation/bloc/iot_bloc.dart';
import 'package:buildpro360_mobile/features/reports/presentation/bloc/reports_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize services
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final ApiService _apiService = ApiService();
  final AnalyticsService _analyticsService = AnalyticsService();
  ThemeMode _themeMode = ThemeMode.light;
  
  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final isDarkMode = await _localStorageService.isDarkMode();
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            apiService: _apiService,
            localStorageService: _localStorageService,
          )..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(apiService: _apiService),
        ),
        BlocProvider<AssetsBloc>(
          create: (context) => AssetsBloc(apiService: _apiService),
        ),
        BlocProvider<ProjectsBloc>(
          create: (context) => ProjectsBloc(apiService: _apiService),
        ),
        BlocProvider<MaintenanceBloc>(
          create: (context) => MaintenanceBloc(apiService: _apiService),
        ),
        BlocProvider<ComplianceBloc>(
          create: (context) => ComplianceBloc(apiService: _apiService),
        ),
        BlocProvider<IoTBloc>(
          create: (context) => IoTBloc(apiService: _apiService),
        ),
        BlocProvider<ReportsBloc>(
          create: (context) => ReportsBloc(apiService: _apiService),
        ),
      ],
      child: MaterialApp(
        title: 'BuildPro360',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        initialRoute: AppRouter.login,
        onGenerateRoute: AppRouter.generateRoute,
        navigatorObservers: [
          _analyticsService.getAnalyticsObserver(),
        ],
      ),
    );
  }
}
