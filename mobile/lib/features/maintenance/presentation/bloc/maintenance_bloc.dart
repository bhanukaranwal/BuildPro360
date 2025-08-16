import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:buildpro360_mobile/core/services/api_service.dart';
import 'package:buildpro360_mobile/features/maintenance/domain/models/work_order.dart';

// Events
abstract class MaintenanceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchWorkOrdersEvent extends MaintenanceEvent {
  final int page;
  final int limit;
  final String? status;
  final String? priority;
  final int? assetId;
  final int? assignedToId;
  
  FetchWorkOrdersEvent({
    this.page = 1,
    this.limit = 20,
    this.status,
    this.priority,
    this.assetId,
    this.assignedToId,
  });
  
  @override
  List<Object?> get props => [page, limit, status, priority, assetId, assignedToId];
}

class FetchWorkOrderDetailEvent extends MaintenanceEvent {
  final int workOrderId;
  
  FetchWorkOrderDetailEvent({required this.workOrderId});
  
  @override
  List<Object?> get props => [workOrderId];
}

class UpdateWorkOrderStatusEvent extends MaintenanceEvent {
  final int workOrderId;
  final String status;
  final String? notes;
  
  UpdateWorkOrderStatusEvent({
    required this.workOrderId,
    required this.status,
    this.notes,
  });
  
  @override
  List<Object?> get props => [workOrderId, status, notes];
}

// States
abstract class MaintenanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MaintenanceInitialState extends MaintenanceState {}

class MaintenanceLoadingState extends MaintenanceState {}

class WorkOrdersLoadedState extends MaintenanceState {
  final List<WorkOrder> workOrders;
  final bool hasReachedMax;
  final int currentPage;
  
  WorkOrdersLoadedState({
    required this.workOrders, 
    this.hasReachedMax = false,
    this.currentPage = 1,
  });
  
  @override
  List<Object?> get props => [workOrders, hasReachedMax, currentPage];
}

class WorkOrderDetailLoadedState extends MaintenanceState {
  final WorkOrder workOrder;
  
  WorkOrderDetailLoadedState({required this.workOrder});
  
  @override
  List<Object?> get props => [workOrder];
}

class WorkOrderUpdatedState extends MaintenanceState {
  final WorkOrder workOrder;
  
  WorkOrderUpdatedState({required this.workOrder});
  
  @override
  List<Object?> get props => [workOrder];
}

class MaintenanceErrorState extends MaintenanceState {
  final String message;
  
  MaintenanceErrorState({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Bloc
class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  final ApiService apiService;
  
  MaintenanceBloc({required this.apiService}) : super(MaintenanceInitialState()) {
    on<FetchWorkOrdersEvent>(_onFetchWorkOrders);
    on<FetchWorkOrderDetailEvent>(_onFetchWorkOrderDetail);
    on<UpdateWorkOrderStatusEvent>(_onUpdateWorkOrderStatus);
  }
  
  Future<void> _onFetchWorkOrders(FetchWorkOrdersEvent event, Emitter<MaintenanceState> emit) async {
    try {
      if (state is WorkOrdersLoadedState && event.page == 1) {
        // If we're refreshing the first page, show loading
        emit(MaintenanceLoadingState());
      }
      
      final currentState = state;
      List<WorkOrder> oldWorkOrders = [];
      int currentPage = event.page;
      
      if (currentState is WorkOrdersLoadedState && event.page > 1) {
        oldWorkOrders = currentState.workOrders;
        currentPage = currentState.currentPage;
        
        // If we've already reached max and trying to load more, do nothing
        if (currentState.hasReachedMax) {
          return;
        }
      } else {
        emit(MaintenanceLoadingState());
      }
      
      final workOrders = await apiService.getWorkOrders(
        page: event.page,
        limit: event.limit,
        status: event.status,
        priority: event.priority,
        assetId: event.assetId,
        assignedToId: event.assignedToId,
      );
      
      if (workOrders.isEmpty) {
        emit(WorkOrdersLoadedState(
          workOrders: oldWorkOrders,
          hasReachedMax: true,
          currentPage: currentPage,
        ));
      } else {
        final newWorkOrders = event.page > 1 
            ? [...oldWorkOrders, ...workOrders] 
            : workOrders;
        
        emit(WorkOrdersLoadedState(
          workOrders: newWorkOrders,
          hasReachedMax: workOrders.length < event.limit,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      emit(MaintenanceErrorState(message: 'Failed to load work orders: ${e.toString()}'));
    }
  }
  
  Future<void> _onFetchWorkOrderDetail(FetchWorkOrderDetailEvent event, Emitter<MaintenanceState> emit) async {
    emit(MaintenanceLoadingState());
    
    try {
      final workOrder = await apiService.getWorkOrderById(event.workOrderId);
      emit(WorkOrderDetailLoadedState(workOrder: workOrder));
    } catch (e) {
      emit(MaintenanceErrorState(message: 'Failed to load work order details: ${e.toString()}'));
    }
  }
  
  Future<void> _onUpdateWorkOrderStatus(UpdateWorkOrderStatusEvent event, Emitter<MaintenanceState> emit) async {
    try {
      final workOrder = await apiService.updateWorkOrderStatus(
        workOrderId: event.workOrderId,
        status: event.status,
        notes: event.notes,
      );
      
      emit(WorkOrderUpdatedState(workOrder: workOrder));
      
      // After updating, refresh the detail view
      add(FetchWorkOrderDetailEvent(workOrderId: event.workOrderId));
    } catch (e) {
      emit(MaintenanceErrorState(message: 'Failed to update work order: ${e.toString()}'));
    }
  }
}