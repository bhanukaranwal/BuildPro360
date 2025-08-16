import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum ConnectivityStatus {
  wifi,
  mobile,
  none,
}

class ConnectivityService {
  // Singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();
  
  factory ConnectivityService() {
    return _instance;
  }
  
  ConnectivityService._internal();
  
  // Stream controller for broadcasting connectivity changes
  final _connectivityStreamController = StreamController<ConnectivityStatus>.broadcast();
  
  // Connectivity instance
  final Connectivity _connectivity = Connectivity();
  
  // Subscription to connectivity changes
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // Current connectivity status
  ConnectivityStatus _currentStatus = ConnectivityStatus.none;
  
  // Initialize the service
  void initialize() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      final status = _getStatusFromResult(result);
      
      // Update the current status
      _currentStatus = status;
      
      // Add the status to the stream
      _connectivityStreamController.add(status);
    });
    
    // Get the initial connectivity status
    _checkConnectivity();
  }
  
  // Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityStreamController.close();
  }
  
  // Get the current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;
  
  // Get the stream of connectivity changes
  Stream<ConnectivityStatus> get onConnectivityChanged => _connectivityStreamController.stream;
  
  // Check the current connectivity
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final status = _getStatusFromResult(result);
      
      // Update the current status
      _currentStatus = status;
      
      // Add the status to the stream
      _connectivityStreamController.add(status);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }
  }
  
  // Convert ConnectivityResult to ConnectivityStatus
  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectivityStatus.wifi;
      case ConnectivityResult.mobile:
        return ConnectivityStatus.mobile;
      case ConnectivityResult.none:
      default:
        return ConnectivityStatus.none;
    }
  }
  
  // Check if the device is currently connected
  bool get isConnected => _currentStatus != ConnectivityStatus.none;
  
  // Check if the device is connected via WiFi
  bool get isWifi => _currentStatus == ConnectivityStatus.wifi;
  
  // Check if the device is connected via mobile data
  bool get isMobile => _currentStatus == ConnectivityStatus.mobile;
}