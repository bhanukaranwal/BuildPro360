import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:buildpro360_mobile/core/services/api_service.dart';
import 'package:buildpro360_mobile/features/assets/domain/models/asset.dart';

// Events
abstract class AssetsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAssetsEvent extends AssetsEvent {
  final int page;
  final int limit;
  final String? status;
  final String? category;
  
  FetchAssetsEvent({
    this.page = 1,
    this.limit = 20,
    this.status,
    this.category,
  });
  
  @override
  List<Object?> get props => [page, limit, status, category];
}

class FetchAssetDetailEvent extends AssetsEvent {
  final int assetId;
  
  FetchAssetDetailEvent({required this.assetId});
  
  @override
  List<Object?> get props => [assetId];
}

// States
abstract class AssetsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AssetsInitialState extends AssetsState {}

class AssetsLoadingState extends AssetsState {}

class AssetsLoadedState extends AssetsState {
  final List<Asset> assets;
  final bool hasReachedMax;
  final int currentPage;
  
  AssetsLoadedState({
    required this.assets, 
    this.hasReachedMax = false,
    this.currentPage = 1,
  });
  
  @override
  List<Object?> get props => [assets, hasReachedMax, currentPage];
}

class AssetDetailLoadedState extends AssetsState {
  final Asset asset;
  
  AssetDetailLoadedState({required this.asset});
  
  @override
  List<Object?> get props => [asset];
}

class AssetsErrorState extends AssetsState {
  final String message;
  
  AssetsErrorState({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Bloc
class AssetsBloc extends Bloc<AssetsEvent, AssetsState> {
  final ApiService apiService;
  
  AssetsBloc({required this.apiService}) : super(AssetsInitialState()) {
    on<FetchAssetsEvent>(_onFetchAssets);
    on<FetchAssetDetailEvent>(_onFetchAssetDetail);
  }
  
  Future<void> _onFetchAssets(FetchAssetsEvent event, Emitter<AssetsState> emit) async {
    try {
      if (state is AssetsLoadedState && event.page == 1) {
        // If we're refreshing the first page, show loading
        emit(AssetsLoadingState());
      }
      
      final currentState = state;
      List<Asset> oldAssets = [];
      int currentPage = event.page;
      
      if (currentState is AssetsLoadedState && event.page > 1) {
        oldAssets = currentState.assets;
        currentPage = currentState.currentPage;
        
        // If we've already reached max and trying to load more, do nothing
        if (currentState.hasReachedMax) {
          return;
        }
      } else {
        emit(AssetsLoadingState());
      }
      
      final assets = await apiService.getAssets(
        page: event.page,
        limit: event.limit,
        status: event.status,
        category: event.category,
      );
      
      if (assets.isEmpty) {
        emit(AssetsLoadedState(
          assets: oldAssets,
          hasReachedMax: true,
          currentPage: currentPage,
        ));
      } else {
        final newAssets = event.page > 1 
            ? [...oldAssets, ...assets] 
            : assets;
        
        emit(AssetsLoadedState(
          assets: newAssets,
          hasReachedMax: assets.length < event.limit,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      emit(AssetsErrorState(message: 'Failed to load assets: ${e.toString()}'));
    }
  }
  
  Future<void> _onFetchAssetDetail(FetchAssetDetailEvent event, Emitter<AssetsState> emit) async {
    emit(AssetsLoadingState());
    
    try {
      final asset = await apiService.getAssetById(event.assetId);
      emit(AssetDetailLoadedState(asset: asset));
    } catch (e) {
      emit(AssetsErrorState(message: 'Failed to load asset details: ${e.toString()}'));
    }
  }
}