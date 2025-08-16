import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:buildpro360_mobile/core/services/api_service.dart';

// Events
abstract class ReportsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchReportTemplatesEvent extends ReportsEvent {}

class FetchReportJobsEvent extends ReportsEvent {}

class GenerateReportEvent extends ReportsEvent {
  final String reportType;
  final Map<String, dynamic> parameters;
  
  GenerateReportEvent({
    required this.reportType,
    required this.parameters,
  });
  
  @override
  List<Object?> get props => [reportType, parameters];
}

class GetReportStatusEvent extends ReportsEvent {
  final String reportId;
  
  GetReportStatusEvent({required this.reportId});
  
  @override
  List<Object?> get props => [reportId];
}

class GetReportDownloadUrlEvent extends ReportsEvent {
  final String reportId;
  
  GetReportDownloadUrlEvent({required this.reportId});
  
  @override
  List<Object?> get props => [reportId];
}

// States
abstract class ReportsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportsInitialState extends ReportsState {}

class ReportsLoadingState extends ReportsState {}

class ReportJobsLoadingState extends ReportsState {}

class ReportTemplatesLoadedState extends ReportsState {
  final List<dynamic> templates;
  
  ReportTemplatesLoadedState({required this.templates});
  
  @override
  List<Object?> get props => [templates];
}

class ReportJobsLoadedState extends ReportsState {
  final List<dynamic> jobs;
  
  ReportJobsLoadedState({required this.jobs});
  
  @override
  List<Object?> get props => [jobs];
}

class ReportGeneratedState extends ReportsState {
  final String reportId;
  
  ReportGeneratedState({required this.reportId});
  
  @override
  List<Object?> get props => [reportId];
}

class ReportStatusLoadedState extends ReportsState {
  final Map<String, dynamic> status;
  
  ReportStatusLoadedState({required this.status});
  
  @override
  List<Object?> get props => [status];
}

class ReportDownloadUrlLoadedState extends ReportsState {
  final String downloadUrl;
  
  ReportDownloadUrlLoadedState({required this.downloadUrl});
  
  @override
  List<Object?> get props => [downloadUrl];
}

class ReportsErrorState extends ReportsState {
  final String message;
  
  ReportsErrorState({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ApiService apiService;
  
  ReportsBloc({required this.apiService}) : super(ReportsInitialState()) {
    on<FetchReportTemplatesEvent>(_onFetchReportTemplates);
    on<FetchReportJobsEvent>(_onFetchReportJobs);
    on<GenerateReportEvent>(_onGenerateReport);
    on<GetReportStatusEvent>(_onGetReportStatus);
    on<GetReportDownloadUrlEvent>(_onGetReportDownloadUrl);
  }
  
  Future<void> _onFetchReportTemplates(FetchReportTemplatesEvent event, Emitter<ReportsState> emit) async {
    emit(ReportsLoadingState());
    
    try {
      final templates = await apiService.getReportTemplates();
      emit(ReportTemplatesLoadedState(templates: templates));
    } catch (e) {
      emit(ReportsErrorState(message: 'Failed to load report templates: ${e.toString()}'));
    }
  }
  
  Future<void> _onFetchReportJobs(FetchReportJobsEvent event, Emitter<ReportsState> emit) async {
    emit(ReportJobsLoadingState());
    
    try {
      final jobs = await apiService.getReportJobs();
      emit(ReportJobsLoadedState(jobs: jobs));
    } catch (e) {
      emit(ReportsErrorState(message: 'Failed to load report jobs: ${e.toString()}'));
    }
  }
  
  Future<void> _onGenerateReport(GenerateReportEvent event, Emitter<ReportsState> emit) async {
    emit(ReportsLoadingState());
    
    try {
      final result = await apiService.generateReport(
        reportType: event.reportType,
        parameters: event.parameters,
      );
      
      emit(ReportGeneratedState(reportId: result['report_id']));
    } catch (e) {
      emit(ReportsErrorState(message: 'Failed to generate report: ${e.toString()}'));
    }
  }
  
  Future<void> _onGetReportStatus(GetReportStatusEvent event, Emitter<ReportsState> emit) async {
    try {
      final status = await apiService.getReportStatus(event.reportId);
      emit(ReportStatusLoadedState(status: status));
      
      // If the report is completed or failed, refresh the job list
      if (status['status'] == 'completed' || status['status'] == 'failed') {
        add(FetchReportJobsEvent());
      }
    } catch (e) {
      emit(ReportsErrorState(message: 'Failed to get report status: ${e.toString()}'));
    }
  }
  
  Future<void> _onGetReportDownloadUrl(GetReportDownloadUrlEvent event, Emitter<ReportsState> emit) async {
    try {
      final result = await apiService.getReportDownloadUrl(event.reportId);
      emit(ReportDownloadUrlLoadedState(downloadUrl: result['download_url']));
    } catch (e) {
      emit(ReportsErrorState(message: 'Failed to get download URL: ${e.toString()}'));
    }
  }
}