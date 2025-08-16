import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:buildpro360_mobile/core/services/api_service.dart';
import 'package:buildpro360_mobile/features/dashboard/domain/models/dashboard_data.dart';

// Events
abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchDashboardDataEvent extends DashboardEvent {}

class RefreshDashboardDataEvent extends DashboardEvent {}

// States
abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitialState extends DashboardState {}

class DashboardLoadingState extends DashboardState {}

class DashboardLoadedState extends DashboardState {
  final DashboardData data;
  
  DashboardLoadedState({required this.data});
  
  @override
  List<Object?> get props => [data];
}

class DashboardErrorState extends DashboardState {
  final String message;
  
  DashboardErrorState({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ApiService apiService;
  
  DashboardBloc({required this.apiService}) : super(DashboardInitialState()) {
    on<FetchDashboardDataEvent>(_onFetchDashboardData);
    on<RefreshDashboardDataEvent>(_onRefreshDashboardData);
  }
  
  Future<void> _onFetchDashboardData(FetchDashboardDataEvent event, Emitter<DashboardState> emit) async {
    if (state is! DashboardLoadedState) {
      emit(DashboardLoadingState());
    }
    
    try {
      final dashboardData = await apiService.getDashboardData();
      emit(DashboardLoadedState(data: dashboardData));
    } catch (e) {
      emit(DashboardErrorState(message: e.toString()));
    }
  }
  
  Future<void> _onRefreshDashboardData(RefreshDashboardDataEvent event, Emitter<DashboardState> emit) async {
    // Always show loading indicator on refresh
    emit(DashboardLoadingState());
    
    try {
      final dashboardData = await apiService.getDashboardData();
      emit(DashboardLoadedState(data: dashboardData));
    } catch (e) {
      emit(DashboardErrorState(message: e.toString()));
    }
  }
}