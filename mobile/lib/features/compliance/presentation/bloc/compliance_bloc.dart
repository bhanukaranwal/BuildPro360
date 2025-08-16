import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:buildpro360_mobile/core/services/api_service.dart';
import 'package:buildpro360_mobile/features/compliance/domain/models/inspection.dart';

// Events
abstract class ComplianceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchInspectionsEvent extends ComplianceEvent {
  final int page;
  final int limit;
  final String? status;
  final String? type;
  final int? assetId;
  final int? assignedToId;
  
  FetchInspectionsEvent({
    this.page = 1,
    this.limit = 20,
    this.status,
    this.type,
    this.assetId,
    this.assignedToId,
  });
  
  @override
  List<Object?> get props => [page, limit, status, type, assetId, assignedToId];
}

class FetchInspectionDetailEvent extends ComplianceEvent {
  final int inspectionId;
  
  FetchInspectionDetailEvent({required this.inspectionId});
  
  @override
  List<Object?> get props => [inspectionId];
}

class UpdateInspectionStatusEvent extends ComplianceEvent {
  final int inspectionId;
  final String status;
  
  UpdateInspectionStatusEvent({
    required this.inspectionId,
    required this.status,
  });
  
  @override
  List<Object?> get props => [inspectionId, status];
}

// States
abstract class ComplianceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ComplianceInitialState extends ComplianceState {}

class ComplianceLoadingState extends ComplianceState {}

class InspectionsLoadedState extends ComplianceState {
  final List<Inspection> inspections;
  final bool hasReachedMax;
  final int currentPage;
  
  InspectionsLoadedState({
    required this.inspections, 
    this.hasReachedMax = false,
    this.currentPage = 1,
  });
  
  @override
  List<Object?> get props => [inspections, hasReachedMax, currentPage];
}

class InspectionDetailLoadedState extends ComplianceState {
  final Inspection inspection;
  
  InspectionDetailLoadedState({required this.inspection});
  
  @override
  List<Object?> get props => [inspection];
}

class InspectionUpdatedState extends ComplianceState {
  final Map<String, dynamic> updateResult;
  
  InspectionUpdatedState({required this.updateResult});
  
  @override
  List<Object?> get props => [updateResult];
}

class ComplianceErrorState extends ComplianceState {
  final String message;
  
  ComplianceErrorState({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Bloc
class ComplianceBloc extends Bloc<ComplianceEvent, ComplianceState> {
  final ApiService apiService;
  
  ComplianceBloc({required this.apiService}) : super(ComplianceInitialState()) {
    on<FetchInspectionsEvent>(_onFetchInspections);
    on<FetchInspectionDetailEvent>(_onFetchInspectionDetail);
    on<UpdateInspectionStatusEvent>(_onUpdateInspectionStatus);
  }
  
  Future<void> _onFetchInspections(FetchInspectionsEvent event, Emitter<ComplianceState> emit) async {
    try {
      if (state is InspectionsLoadedState && event.page == 1) {
        // If we're refreshing the first page, show loading
        emit(ComplianceLoadingState());
      }
      
      final currentState = state;
      List<Inspection> oldInspections = [];
      int currentPage = event.page;
      
      if (currentState is InspectionsLoadedState && event.page > 1) {
        oldInspections = currentState.inspections;
        currentPage = currentState.currentPage;
        
        // If we've already reached max and trying to load more, do nothing
        if (currentState.hasReachedMax) {
          return;
        }
      } else {
        emit(ComplianceLoadingState());
      }
      
      final inspections = await apiService.getInspections(
        page: event.page,
        limit: event.limit,
        status: event.status,
        type: event.type,
        assetId: event.assetId,
        assignedToId: event.assignedToId,
      );
      
      if (inspections.isEmpty) {
        emit(InspectionsLoadedState(
          inspections: oldInspections,
          hasReachedMax: true,
          currentPage: currentPage,
        ));
      } else {
        final newInspections = event.page > 1 
            ? [...oldInspections, ...inspections] 
            : inspections;
        
        emit(InspectionsLoadedState(
          inspections: newInspections,
          hasReachedMax: inspections.length < event.limit,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      emit(ComplianceErrorState(message: 'Failed to load inspections: ${e.toString()}'));
    }
  }
  
  Future<void> _onFetchInspectionDetail(FetchInspectionDetailEvent event, Emitter<ComplianceState> emit) async {
    emit(ComplianceLoadingState());
    
    try {
      final inspection = await apiService.getInspectionById(event.inspectionId);
      emit(InspectionDetailLoadedState(inspection: inspection));
    } catch (e) {
      emit(ComplianceErrorState(message: 'Failed to load inspection details: ${e.toString()}'));
    }
  }
  
  Future<void> _onUpdateInspectionStatus(UpdateInspectionStatusEvent event, Emitter<ComplianceState> emit) async {
    try {
      final result = await apiService.updateInspectionStatus(
        inspectionId: event.inspectionId,
        status: event.status,
      );
      
      emit(InspectionUpdatedState(updateResult: result));
      
      // After updating, refresh the detail view
      add(FetchInspectionDetailEvent(inspectionId: event.inspectionId));
    } catch (e) {
      emit(ComplianceErrorState(message: 'Failed to update inspection: ${e.toString()}'));
    }
  }
}