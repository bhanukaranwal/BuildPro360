import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:buildpro360_mobile/core/services/api_service.dart';
import 'package:buildpro360_mobile/features/projects/domain/models/project.dart';

// Events
abstract class ProjectsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProjectsEvent extends ProjectsEvent {
  final int page;
  final int limit;
  final String? status;
  
  FetchProjectsEvent({
    this.page = 1,
    this.limit = 20,
    this.status,
  });
  
  @override
  List<Object?> get props => [page, limit, status];
}

class FetchProjectDetailEvent extends ProjectsEvent {
  final int projectId;
  
  FetchProjectDetailEvent({required this.projectId});
  
  @override
  List<Object?> get props => [projectId];
}

// States
abstract class ProjectsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectsInitialState extends ProjectsState {}

class ProjectsLoadingState extends ProjectsState {}

class ProjectsLoadedState extends ProjectsState {
  final List<Project> projects;
  final bool hasReachedMax;
  final int currentPage;
  
  ProjectsLoadedState({
    required this.projects, 
    this.hasReachedMax = false,
    this.currentPage = 1,
  });
  
  @override
  List<Object?> get props => [projects, hasReachedMax, currentPage];
}

class ProjectDetailLoadedState extends ProjectsState {
  final Project project;
  
  ProjectDetailLoadedState({required this.project});
  
  @override
  List<Object?> get props => [project];
}

class ProjectsErrorState extends ProjectsState {
  final String message;
  
  ProjectsErrorState({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Bloc
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ApiService apiService;
  
  ProjectsBloc({required this.apiService}) : super(ProjectsInitialState()) {
    on<FetchProjectsEvent>(_onFetchProjects);
    on<FetchProjectDetailEvent>(_onFetchProjectDetail);
  }
  
  Future<void> _onFetchProjects(FetchProjectsEvent event, Emitter<ProjectsState> emit) async {
    try {
      if (state is ProjectsLoadedState && event.page == 1) {
        // If we're refreshing the first page, show loading
        emit(ProjectsLoadingState());
      }
      
      final currentState = state;
      List<Project> oldProjects = [];
      int currentPage = event.page;
      
      if (currentState is ProjectsLoadedState && event.page > 1) {
        oldProjects = currentState.projects;
        currentPage = currentState.currentPage;
        
        // If we've already reached max and trying to load more, do nothing
        if (currentState.hasReachedMax) {
          return;
        }
      } else {
        emit(ProjectsLoadingState());
      }
      
      final projects = await apiService.getProjects(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );
      
      if (projects.isEmpty) {
        emit(ProjectsLoadedState(
          projects: oldProjects,
          hasReachedMax: true,
          currentPage: currentPage,
        ));
      } else {
        final newProjects = event.page > 1 
            ? [...oldProjects, ...projects] 
            : projects;
        
        emit(ProjectsLoadedState(
          projects: newProjects,
          hasReachedMax: projects.length < event.limit,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      emit(ProjectsErrorState(message: 'Failed to load projects: ${e.toString()}'));
    }
  }
  
  Future<void> _onFetchProjectDetail(FetchProjectDetailEvent event, Emitter<ProjectsState> emit) async {
    emit(ProjectsLoadingState());
    
    try {
      final project = await apiService.getProjectById(event.projectId);
      emit(ProjectDetailLoadedState(project: project));
    } catch (e) {
      emit(ProjectsErrorState(message: 'Failed to load project details: ${e.toString()}'));
    }
  }
}