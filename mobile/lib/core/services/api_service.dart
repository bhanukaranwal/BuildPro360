import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:buildpro360_mobile/core/services/local_storage_service.dart';
import 'package:buildpro360_mobile/config/constants/app_constants.dart';
import 'package:buildpro360_mobile/features/assets/domain/models/asset.dart';
import 'package:buildpro360_mobile/features/projects/domain/models/project.dart';
import 'package:buildpro360_mobile/features/maintenance/domain/models/work_order.dart';
import 'package:buildpro360_mobile/features/compliance/domain/models/inspection.dart';
import 'package:buildpro360_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final LocalStorageService _localStorageService = LocalStorageService();
  final http.Client _httpClient = http.Client();
  
  // For production, these would be loaded from environment variables or config
  final String baseUrl = AppConstants.baseApiUrl;
  final String baseWebSocketUrl = 'wss://api.buildpro360.com';
  
  // Headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _localStorageService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Authentication
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _localStorageService.saveAuthToken(data['token']);
        return data;
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<void> logout() async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleApiError(response);
      }
    } catch (e) {
      // Still clear the token even if the API call fails
      debugPrint('Error during logout: $e');
    } finally {
      // Clear the token from local storage
      await _localStorageService.clearAuthToken();
    }
  }
  
  // Dashboard
  Future<DashboardData> getDashboardData() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DashboardData.fromJson(data);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  // Assets
  Future<List<Asset>> getAssets({
    int page = 1,
    int limit = 20,
    String? status,
    String? category,
    int? projectId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (category != null) 'category': category,
        if (projectId != null) 'project_id': projectId.toString(),
      };
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/assets').replace(queryParameters: queryParams),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List).map((item) => Asset.fromJson(item)).toList();
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<Asset> getAssetById(int assetId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/assets/$assetId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Asset.fromJson(data);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  // Projects
  Future<List<Project>> getProjects({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/projects').replace(queryParameters: queryParams),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List).map((item) => Project.fromJson(item)).toList();
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<Project> getProjectById(int projectId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/projects/$projectId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Project.fromJson(data);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  // Work Orders
  Future<List<WorkOrder>> getWorkOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? priority,
    int? assetId,
    int? assignedToId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
        if (assetId != null) 'asset_id': assetId.toString(),
        if (assignedToId != null) 'assigned_to_id': assignedToId.toString(),
      };
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/maintenance/work-orders').replace(queryParameters: queryParams),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List).map((item) => WorkOrder.fromJson(item)).toList();
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<WorkOrder> getWorkOrderById(int workOrderId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/maintenance/work-orders/$workOrderId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WorkOrder.fromJson(data);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<WorkOrder> updateWorkOrderStatus({
    required int workOrderId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('$baseUrl/maintenance/work-orders/$workOrderId/status'),
        headers: await _getHeaders(),
        body: json.encode({
          'status': status,
          if (notes != null) 'notes': notes,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WorkOrder.fromJson(data);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  // Inspections
  Future<List<Inspection>> getInspections({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
    int? assetId,
    int? assignedToId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (type != null) 'type': type,
        if (assetId != null) 'asset_id': assetId.toString(),
        if (assignedToId != null) 'assigned_to_id': assignedToId.toString(),
      };
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/compliance/inspections').replace(queryParameters: queryParams),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List).map((item) => Inspection.fromJson(item)).toList();
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<Inspection> getInspectionById(int inspectionId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/compliance/inspections/$inspectionId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Inspection.fromJson(data);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<Map<String, dynamic>> updateInspectionStatus({
    required int inspectionId,
    required String status,
  }) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('$baseUrl/compliance/inspections/$inspectionId/status'),
        headers: await _getHeaders(),
        body: json.encode({
          'status': status,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  // IoT Devices
  Future<List<dynamic>> getIoTDevices({
    int page = 1,
    int limit = 20,
    String? status,
    String? deviceType,
    int? assetId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (deviceType != null) 'type': deviceType,
        if (assetId != null) 'asset_id': assetId.toString(),
      };
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/iot/devices').replace(queryParameters: queryParams),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] as List;
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<Map<String, dynamic>> getIoTDeviceById(int deviceId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/iot/devices/$deviceId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<List<dynamic>> getDeviceAlerts({
    int page = 1,
    int limit = 20,
    int? deviceId,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (deviceId != null) 'device_id': deviceId.toString(),
        if (status != null) 'status': status,
      };
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/iot/alerts').replace(queryParameters: queryParams),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] as List;
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<List<dynamic>> getDeviceTelemetry({
    required String deviceId,
    String? sensorName,
    int hours = 24,
  }) async {
    try {
      final queryParams = {
        'hours': hours.toString(),
        if (sensorName != null) 'sensor': sensorName,
      };
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/iot/devices/$deviceId/telemetry')
            .replace(queryParameters: queryParams),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as List;
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<Map<String, dynamic>> acknowledgeAlert({
    required int alertId,
    required String username,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/iot/alerts/$alertId/acknowledge'),
        headers: await _getHeaders(),
        body: json.encode({
          'username': username,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<Map<String, dynamic>> resolveAlert({
    required int alertId,
    required String username,
    String? notes,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/iot/alerts/$alertId/resolve'),
        headers: await _getHeaders(),
        body: json.encode({
          'username': username,
          if (notes != null) 'notes': notes,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<Map<String, dynamic>> sendDeviceCommand({
    required String deviceId,
    required Map<String, dynamic> command,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/iot/devices/$deviceId/command'),
        headers: await _getHeaders(),
        body: json.encode(command),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  // Reports
  Future<List<dynamic>> getReportTemplates() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/reports/templates'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['templates'] as List;
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<List<dynamic>> getReportJobs() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/reports/jobs'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['jobs'] as List;
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/reports/generate'),
        headers: await _getHeaders(),
        body: json.encode({
          'report_type': reportType,
          'parameters': parameters,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 202) {
        return json.decode(response.body);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<Map<String, dynamic>> getReportStatus(String reportId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/reports/jobs/$reportId/status'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Future<Map<String, dynamic>> getReportDownloadUrl(String reportId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/reports/jobs/$reportId/download'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  // Error handling
  Exception _handleApiError(http.Response response) {
    try {
      final data = json.decode(response.body);
      final message = data['message'] ?? 'Unknown error';
      
      if (response.statusCode == 401) {
        return UnauthorizedException(message);
      } else if (response.statusCode == 403) {
        return ForbiddenException(message);
      } else if (response.statusCode == 404) {
        return NotFoundException(message);
      } else if (response.statusCode >= 500) {
        return ServerException(message);
      } else {
        return ApiException(message, response.statusCode);
      }
    } catch (e) {
      return ApiException('Error processing response: ${response.body}', response.statusCode);
    }
  }
  
  Exception _handleException(dynamic exception) {
    if (exception is TimeoutException) {
      return TimeoutException('Request timed out');
    } else if (exception is SocketException) {
      return ConnectivityException('Network connection failed');
    } else {
      return exception is Exception ? exception : Exception(exception.toString());
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException(this.message, this.statusCode);
  
  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}

class UnauthorizedException implements Exception {
  final String message;
  
  UnauthorizedException(this.message);
  
  @override
  String toString() => 'UnauthorizedException: $message';
}

class ForbiddenException implements Exception {
  final String message;
  
  ForbiddenException(this.message);
  
  @override
  String toString() => 'ForbiddenException: $message';
}

class NotFoundException implements Exception {
  final String message;
  
  NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: $message';
}

class ServerException implements Exception {
  final String message;
  
  ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

class ConnectivityException implements Exception {
  final String message;
  
  ConnectivityException(this.message);
  
  @override
  String toString() => 'ConnectivityException: $message';
}