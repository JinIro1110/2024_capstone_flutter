import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/MallItem.dart';
import 'package:flutter_application_1/repository/mall_repository.dart';

// MallControllerState 클래스  
// 쇼핑몰 컨트롤러 상태를 관리하는 데이터 클래스  
class MallControllerState {
  final List<MallItem> items;       // 현재 쇼핑몰 아이템 목록  
  final bool isLoading;             // 데이터 로딩 여부  
  final String error;               // 에러 메시지  
  final bool hasMore;               // 추가 아이템 존재 여부  
  final String currentCategory;     // 현재 선택된 카테고리  

  const MallControllerState({
    this.items = const [],
    this.isLoading = false,
    this.error = '',
    this.hasMore = true,
    this.currentCategory = '전체',
  });

  // 상태 복사 및 수정 메서드  
  MallControllerState copyWith({
    List<MallItem>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
    String? currentCategory,
  }) {
    return MallControllerState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }
}

// MallController 클래스  
// 쇼핑몰 컨트롤러, 데이터 로딩 및 상태 관리를 담당  
class MallController {
  final MallRepository repository;  // 데이터 레포지토리 참조  
  final int itemsPerPage;             // 페이지당 아이템 개수  
  void Function(MallControllerState)? onStateChanged;  // 상태 변경 콜백  

  MallController({
    required this.repository,
    this.itemsPerPage = 20,
    this.onStateChanged,
  });

  DocumentSnapshot? _lastDocument;    // 페이징 처리를 위한 마지막 문서 참조  
  MallControllerState _state = const MallControllerState();

  // Getter 메서드  
  MallControllerState get state => _state;
  bool get hasMore => _state.hasMore;
  String get currentCategory => _state.currentCategory;
  List<MallItem> get items => _state.items;
  bool get isLoading => _state.isLoading;
  String get error => _state.error;

  // 상태 업데이트 메서드  
  void _updateState(MallControllerState newState) {
    _state = newState;
    onStateChanged?.call(_state);
  }

  // 페이징 리셋 메서드  
  void resetPagination() {
    _lastDocument = null;
    _updateState(_state.copyWith(
      hasMore: true,
      items: [],
      error: '',
    ));
  }

  // 카테고리 업데이트 메서드  
  Future<void> updateCategory(String category) async {
    if (category == _state.currentCategory) return;

    _updateState(_state.copyWith(currentCategory: category));
    resetPagination();
    await refresh();
  }

  // 데이터 새로고침 메서드  
  Future<void> refresh() async {
    resetPagination();
    await loadMoreItems();
  }

  // 아이템 추가 로딩 메서드  
  Future<List<MallItem>> loadMoreItems() async {
    if (!_state.hasMore || _state.isLoading) return [];

    try {
      _updateState(_state.copyWith(isLoading: true, error: ''));

      final items = await repository.fetchItems(
        category: _state.currentCategory,
        limit: itemsPerPage,
        lastDocument: _lastDocument,
      );

      if (items.isEmpty) {
        _updateState(_state.copyWith(
          hasMore: false,
          isLoading: false,
        ));
        return [];
      }

      if (items.isNotEmpty) {
        final lastItemAsDoc = items.last as DocumentSnapshot?;
        if (lastItemAsDoc != null) {
          _lastDocument = lastItemAsDoc;
        }
      }

      _updateState(_state.copyWith(
        items: [..._state.items, ...items],
        isLoading: false,
        hasMore: items.length >= itemsPerPage,
      ));

      return items;
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        error: 'Failed to load items: ${e.toString()}',
      ));
      return [];
    }
  }

  // 검색 기능 메서드  
  Future<List<MallItem>> searchItems(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      _updateState(_state.copyWith(isLoading: true, error: ''));

      final searchResults = await repository.fetchItems(
        category: _state.currentCategory,
        limit: itemsPerPage,
        lastDocument: null,
      );

      // 검색 쿼리에 맞춰 필터링  
      final filteredItems = searchResults.where((item) {
        final lowercaseQuery = query.toLowerCase();
        return item.name.toLowerCase().contains(lowercaseQuery) ||
               item.brand.toLowerCase().contains(lowercaseQuery) ||
               item.category.toLowerCase().contains(lowercaseQuery);
      }).toList();

      _updateState(_state.copyWith(
        items: filteredItems,
        isLoading: false,
        hasMore: false,  // 검색 결과에서는 페이징 비활성화
      ));

      return filteredItems;
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        error: 'Search failed: ${e.toString()}',
      ));
      return [];
    }
  }

  // 리소스 해제 메서드  
  Future<void> dispose() async {
    onStateChanged = null;
  }
}
