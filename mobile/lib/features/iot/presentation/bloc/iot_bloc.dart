      } else {
        emit(IoTLoadingState());
      }
      
      final devices = await apiService.getIoTDevices(
        page: event.page,
        limit: event.limit,
        status: event.status,
        deviceType: event.deviceType,
      );
      
      if (devices.isEmpty) {
        emit(DevicesLoadedState(
          devices: oldDevices,
          hasReachedMax: true,
          currentPage: currentPage,
        ));
      } else {
        final newDevices = event.page > 1 
            ? [...oldDevices, ...devices] 
            : devices;
        
        emit(DevicesLoadedState(
          devices: newDevices,
          hasReachedMax: devices.length < event.limit,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      emit(IoTErrorState(message: 'Failed to load devices: ${e.toString()}'));
    }
  }
  
  Future<void> _onFetchDeviceDetail(FetchDeviceDetailEvent event, Emitter<IoTState> emit) async {
    emit(IoTLoadingState());
    
    try {
      final device = await apiService.getIoTDeviceById(event.deviceId);
      emit(DeviceDetailLoadedState(device: device));
    } catch (e) {
      emit(IoTErrorState(message: 'Failed to load device details: ${e.toString()}'));
    }
  }
  
  Future<void> _onFetchDeviceTelemetry(FetchDeviceTelemetryEvent event, Emitter<IoTState> emit) async {
    emit(IoTLoadingState());
    
    try {
      final telemetry = await apiService.getDeviceTelemetry(
        deviceId: event.deviceId.toString(),
        sensorName: event.sensorName,
        hours: event.hours,
      );
      
      emit(DeviceTelemetryLoadedState(telemetry: telemetry));
    } catch (e) {
      emit(IoTErrorState(message: 'Failed to load telemetry data: ${e.toString()}'));
    }
  }
  
  Future<void> _onFetchAlerts(FetchAlertsEvent event, Emitter<IoTState> emit) async {
    try {
      if (state is AlertsLoadedState && event.page == 1) {
        // If we're refreshing the first page, show loading
        emit(IoTLoadingState());
      }
      
      final currentState = state;
      List<dynamic> oldAlerts = [];
      int currentPage = event.page;
      
      if (currentState is AlertsLoadedState && event.page > 1) {
        oldAlerts = currentState.alerts;
        currentPage = currentState.currentPage;
        
        // If we've already reached max and trying to load more, do nothing
        if (currentState.hasReachedMax) {
          return;
        }
      } else {
        emit(IoTLoadingState());
      }
      
      final alerts = await apiService.getDeviceAlerts(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );
      
      if (alerts.isEmpty) {
        emit(AlertsLoadedState(
          alerts: oldAlerts,
          hasReachedMax: true,
          currentPage: currentPage,
        ));
      } else {
        final newAlerts = event.page > 1 
            ? [...oldAlerts, ...alerts] 
            : alerts;
        
        emit(AlertsLoadedState(
          alerts: newAlerts,
          hasReachedMax: alerts.length < event.limit,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      emit(IoTErrorState(message: 'Failed to load alerts: ${e.toString()}'));
    }
  }
  
  Future<void> _onAcknowledgeAlert(AcknowledgeAlertEvent event, Emitter<IoTState> emit) async {
    try {
      final result = await apiService.acknowledgeAlert(
        alertId: event.alertId,
        username: event.username,
      );
      
      emit(AlertAcknowledgedState(alertId: event.alertId));
      
      // Refresh alerts after acknowledgement
      add(FetchAlertsEvent());
    } catch (e) {
      emit(IoTErrorState(message: 'Failed to acknowledge alert: ${e.toString()}'));
    }
  }
  
  Future<void> _onResolveAlert(ResolveAlertEvent event, Emitter<IoTState> emit) async {
    try {
      final result = await apiService.resolveAlert(
        alertId: event.alertId,
        username: event.username,
        notes: event.notes,
      );
      
      emit(AlertResolvedState(alertId: event.alertId));
      
      // Refresh alerts after resolution
      add(FetchAlertsEvent());
    } catch (e) {
      emit(IoTErrorState(message: 'Failed to resolve alert: ${e.toString()}'));
    }
  }
  
  Future<void> _onConnectToDevice(ConnectToDeviceEvent event, Emitter<IoTState> emit) async {
    try {
      // In a real app, this would establish a websocket connection to the device
      // For demo purposes, we'll simulate a successful connection
      await Future.delayed(const Duration(seconds: 1));
      
      emit(DeviceConnectedState(deviceId: event.deviceId));
      
      // Simulate receiving live data (in a real app, this would come from the websocket)
      Future.delayed(const Duration(seconds: 2), () {
        if (state is DeviceConnectedState) {
          add(FetchDeviceDetailEvent(deviceId: event.deviceId));
        }
      });
    } catch (e) {
      emit(IoTErrorState(message: 'Failed to connect to device: ${e.toString()}'));
    }
  }
  
  Future<void> _onDisconnectFromDevice(DisconnectFromDeviceEvent event, Emitter<IoTState> emit) async {
    try {
      // In a real app, this would close the websocket connection
      // For demo purposes, we'll simulate a successful disconnection
      await Future.delayed(const Duration(seconds: 1));
      
      emit(DeviceDisconnectedState());
    } catch (e) {
      emit(IoTErrorState(message: 'Failed to disconnect from device: ${e.toString()}'));
    }
  }
  
  Future<void> _onSendDeviceCommand(SendDeviceCommandEvent event, Emitter<IoTState> emit) async {
    try {
      final result = await apiService.sendDeviceCommand(
        deviceId: event.deviceId,
        command: event.command,
      );
      
      emit(CommandSentState(result: result));
      
      // Refresh device details after command is sent
      Future.delayed(const Duration(seconds: 1), () {
        add(FetchDeviceDetailEvent(deviceId: int.parse(event.deviceId)));
      });
    } catch (e) {
      emit(IoTErrorState(message: 'Failed to send command: ${e.toString()}'));
    }
  }
}