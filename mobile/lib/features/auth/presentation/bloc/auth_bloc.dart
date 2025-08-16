import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:buildpro360_mobile/core/services/api_service.dart';
import 'package:buildpro360_mobile/core/services/local_storage_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;
  
  LoginEvent({required this.username, required this.password});
  
  @override
  List<Object?> get props => [username, password];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class BiometricAuthEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final String username;
  
  AuthenticatedState({required this.username});
  
  @override
  List<Object?> get props => [username];
}

class UnauthenticatedState extends AuthState {}

class LoginSuccessState extends AuthState {
  final String username;
  
  LoginSuccessState({required this.username});
  
  @override
  List<Object?> get props => [username];
}

class LogoutSuccessState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
  
  AuthErrorState({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  final LocalStorageService localStorageService;
  
  AuthBloc({
    required this.apiService,
    required this.localStorageService,
  }) : super(AuthInitialState()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<BiometricAuthEvent>(_onBiometricAuth);
  }
  
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    
    try {
      final response = await apiService.login(event.username, event.password);
      
      // Save user data
      await localStorageService.saveUserData(
        userId: response['user']['id'].toString(),
        username: response['user']['username'],
        email: response['user']['email'],
        role: response['user']['role'],
      );
      
      emit(LoginSuccessState(username: event.username));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }
  
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    
    try {
      await apiService.logout();
      await localStorageService.clearAuthToken();
      await localStorageService.clearUserData();
      
      emit(LogoutSuccessState());
    } catch (e) {
      // Even if API logout fails, we clear local data
      await localStorageService.clearAuthToken();
      await localStorageService.clearUserData();
      
      emit(LogoutSuccessState());
    }
  }
  
  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    
    try {
      final token = await localStorageService.getAuthToken();
      
      if (token != null) {
        final username = await localStorageService.getUsername();
        
        if (username != null) {
          emit(AuthenticatedState(username: username));
        } else {
          // Token exists but no username found, consider as unauthenticated
          await localStorageService.clearAuthToken();
          emit(UnauthenticatedState());
        }
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }
  
  Future<void> _onBiometricAuth(BiometricAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    
    try {
      // In a real app, we would verify biometric authentication here
      // For demo purposes, we'll simulate a successful authentication
      
      final username = await localStorageService.getUsername();
      
      if (username != null) {
        emit(LoginSuccessState(username: username));
      } else {
        emit(AuthErrorState(message: 'User data not found'));
      }
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }
}