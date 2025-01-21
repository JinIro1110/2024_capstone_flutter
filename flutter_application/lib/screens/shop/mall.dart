import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/MallItem.dart';
import 'package:flutter_application_1/screens/shop/filter.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:flutter_application_1/widgets/mall_item_card.dart';
import 'package:url_launcher/url_launcher.dart';

class MallScreen extends StatefulWidget {
  const MallScreen({super.key});

  @override
  _MallScreenState createState() => _MallScreenState();
}

class _MallScreenState extends State<MallScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  List<MallItem> items = []; // 아이템 목록 저장
  bool isLoading = false; // 로딩중
  bool hasMore = true; // 추가 데이터
  final int limit = 20; // 로드 개수
  DocumentSnapshot? lastDocument; // 마지막 문서
  bool _disposed = false;

  // 기본 필터 옵션 설정
  FilterOptions currentFilters = FilterOptions(
    mainCategory: MainCategory.all,
    style: Style.all,
  );

  @override
  void initState() {
    super.initState();
    _loadMoreItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _disposed = true;
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) {
      _loadMoreItems();
    }
  }

  Query _buildQuery() {
    Query query =
        _firestore.collection('items').orderBy('Code', descending: true);

    if (currentFilters.mainCategory != null &&
        currentFilters.mainCategory != MainCategory.all) {
      query = query.where(
        'Category.Main',
        isEqualTo: _getCategoryValue(currentFilters.mainCategory!),
      );
    }

    if (currentFilters.style != null && currentFilters.style != Style.all) {
      query = query.where(
        'Category.Sub',
        isEqualTo: _getStyleValue(currentFilters.style!),
      );
    }

    return query.limit(limit);
  }

// Enum을 Firestore 쿼리용 문자열로 변환
  String _getCategoryValue(MainCategory category) {
    switch (category) {
      case MainCategory.top:
        return "상의"; // Firestore에 저장된 값과 일치해야 합니다.
      case MainCategory.bottom:
        return '하의'; // Firestore에 저장된 값과 일치해야 합니다.
      case MainCategory.all:
      default:
        return ''; // '전체'는 필터링에 사용되지 않으므로 빈 문자열을 반환
    }
  }

  void _handleFilterChange(FilterOptions newFilters) {
    setState(() {
      currentFilters = newFilters;
      items.clear();
      lastDocument = null;
      hasMore = true;
    });
    _loadMoreItems();
  }

  String _getStyleValue(Style style) {
    switch (style) {
      case Style.casual:
        return '캐주얼'; // Firestore의 Category.Sub 값과 동일해야 함
      case Style.sporty:
        return '스포티'; // Firestore의 Category.Sub 값과 동일해야 함
      case Style.street:
        return '스트릿/빈티지'; // Firestore의 Category.Sub 값과 동일해야 함
      case Style.all:
      default:
        return ''; // '전체'는 필터링에 사용되지 않으므로 빈 문자열 반환
    }
  }

  Future<void> _loadMoreItems() async {
    if (isLoading || !hasMore || _disposed) return;

    setState(() {
      isLoading = true;
    });

    try {
      var query = _buildQuery();
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final snapshot = await query.get();

      if (_disposed) return;

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasMore = false;
          isLoading = false;
        });
        return;
      }

      lastDocument = snapshot.docs.last;
      final newItems =
          await Future.wait(snapshot.docs.map((doc) => _createMallItem(doc)));

      if (!_disposed) {
        setState(() {
          items.addAll(newItems);
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error loading items: $error');
      if (!_disposed) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<MallItem> _createMallItem(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    String imageUrl = '';

    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('items/${doc.id}.jpg');
      imageUrl = await storageRef.getDownloadURL();
    } catch (e) {
      print('Error loading image for item ${doc.id}: $e');
    }

    return MallItem(
      code: data['Code']?.toString() ?? '',
      name: data['Name'] ?? '',
      price: data['Price']?.toString() ?? '',
      brand: data['Brand'] ?? '',
      category:
          '${data['Category']?['Main'] ?? ''} > ${data['Category']?['Sub'] ?? ''}',
      mainCategory: data['Category']?['Main'] ?? '',
      subCategory: data['Category']?['Sub'] ?? '',
      imageUrl: imageUrl,
      link: data['Link'] ?? '',
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (!_disposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열 수 없습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 필터 위젯
          AdvancedFilterWidget(
            currentFilters: currentFilters,
            onFilterChanged: _handleFilterChange,
          ),
          // 상품 목록
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  items.clear();
                  lastDocument = null;
                  hasMore = true;
                });
                await _loadMoreItems();
              },
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (items.isEmpty && isLoading) {
      return const _LoadingIndicator();
    }

    if (items.isEmpty && !isLoading) {
      return const _EmptyContent();
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length + (isLoading && hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          return MallItemCard(
            item: items[index],
            onLikePressed: () {
              // 위시리스트 기능 구현 예정
            },
            onBuyPressed: () => _launchURL(items[index].link),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '상품을 불러오는 중입니다...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 48),
          SizedBox(height: 16),
          Text(
            '상품이 없습니다',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
