import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }
  
  // Log page view events
  Future<void> logPageView(String screenName, String screenClass) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }
  
  // Log button click events
  Future<void> logButtonClick(String buttonName, String screenName) async {
    await _analytics.logEvent(
      name: 'button_click',
      parameters: {
        'button_name': buttonName,
        'screen_name': screenName,
      },
    );
  }
  
  // Log search events
  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }
  
  // Log asset view events
  Future<void> logAssetView(int assetId, String assetName) async {
    await _analytics.logEvent(
      name: 'asset_view',
      parameters: {
        'asset_id': assetId.toString(),
        'asset_name': assetName,
      },
    );
  }
  
  // Log project view events
  Future<void> logProjectView(int projectId, String projectName) async {
    await _analytics.logEvent(
      name: 'project_view',
      parameters: {
        'project_id': projectId.toString(),
        'project_name': projectName,
      },
    );
  }
  
  // Log work order view events
  Future<void> logWorkOrderView(int workOrderId, String workOrderTitle) async {
    await _analytics.logEvent(
      name: 'work_order_view',
      parameters: {
        'work_order_id': workOrderId.toString(),
        'work_order_title': workOrderTitle,
      },
    );
  }
  
  // Log inspection view events
  Future<void> logInspectionView(int inspectionId, String inspectionTitle) async {
    await _analytics.logEvent(
      name: 'inspection_view',
      parameters: {
        'inspection_id': inspectionId.toString(),
        'inspection_title': inspectionTitle,
      },
    );
  }
  
  // Log device view events
  Future<void> logDeviceView(int deviceId, String deviceName) async {
    await _analytics.logEvent(
      name: 'device_view',
      parameters: {
        'device_id': deviceId.toString(),
        'device_name': deviceName,
      },
    );
  }
  
  // Log report generation events
  Future<void> logReportGeneration(String reportType) async {
    await _analytics.logEvent(
      name: 'report_generation',
      parameters: {
        'report_type': reportType,
      },
    );
  }
  
  // Log user properties
  Future<void> setUserProperties({
    required String userId,
    required String userRole,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'user_role', value: userRole);
  }
  
  // Log error events
  Future<void> logError(String errorCode, String errorMessage) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_code': errorCode,
        'error_message': errorMessage,
      },
    );
  }
}