import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/MallItem.dart';
import 'package:flutter_application_1/repository/mall_repository.dart';

class MallControllerState {
  final List<MallItem> items;
  final bool isLoading;
  final String error;
  final bool hasMore;
  final String currentCategory;

  const MallControllerState({
    this.items = const [],
    this.isLoading = false,
    this.error = '',
    this.hasMore = true,
    this.currentCategory = '전체',
  });

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

class MallController {
  final MallRepository repository;
  final int itemsPerPage;
  
  // Callback for state changes
  void Function(MallControllerState)? onStateChanged;

  MallController({
    required this.repository,
    this.itemsPerPage = 20,
    this.onStateChanged,
  });

  DocumentSnapshot? _lastDocument;
  MallControllerState _state = const MallControllerState();

  // Getters
  MallControllerState get state => _state;
  bool get hasMore => _state.hasMore;
  String get currentCategory => _state.currentCategory;
  List<MallItem> get items => _state.items;
  bool get isLoading => _state.isLoading;
  String get error => _state.error;

  void _updateState(MallControllerState newState) {
    _state = newState;
    onStateChanged?.call(_state);
  }

  void resetPagination() {
    _lastDocument = null;
    _updateState(_state.copyWith(
      hasMore: true,
      items: [],
      error: '',
    ));
  }

  Future<void> updateCategory(String category) async {
    if (category == _state.currentCategory) return;

    _updateState(_state.copyWith(currentCategory: category));
    resetPagination();
    await refresh();
  }

  Future<void> refresh() async {
    resetPagination();
    await loadMoreItems();
  }

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

      // Update last document for pagination
      if (items.isNotEmpty) {
        final lastItemAsDoc = items.last as DocumentSnapshot?;
        if (lastItemAsDoc != null) {
          _lastDocument = lastItemAsDoc;
        }
      }

      // Update state with new items
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

  Future<List<MallItem>> searchItems(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      _updateState(_state.copyWith(isLoading: true, error: ''));

      final searchResults = await repository.fetchItems(
        category: _state.currentCategory,
        limit: itemsPerPage,
        lastDocument: null,
      );

      // Filter items based on search query
      final filteredItems = searchResults.where((item) {
        final lowercaseQuery = query.toLowerCase();
        return item.name.toLowerCase().contains(lowercaseQuery) ||
               item.brand.toLowerCase().contains(lowercaseQuery) ||
               item.category.toLowerCase().contains(lowercaseQuery);
      }).toList();

      _updateState(_state.copyWith(
        items: filteredItems,
        isLoading: false,
        hasMore: false,  // Disable pagination for search results
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

  Future<void> dispose() async {
    onStateChanged = null;
  }
}