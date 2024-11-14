import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/MallItem.dart';
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
  final List<String> categories = ['전체', '상의', '하의', '아우터', '스타일1', '스타일2', '스타일3'];
  
  List<MallItem> items = [];
  bool isLoading = false;
  bool hasMore = true;
  String selectedCategory = '전체';
  final int limit = 20;
  DocumentSnapshot? lastDocument;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initializeFirestore();
    _loadMoreItems();
    _scrollController.addListener(_onScroll);
  }

  void _initializeFirestore() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
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
    if (currentScroll >= (maxScroll * 0.7)) {
      _loadMoreItems();
    }
  }

  Query _buildQuery() {
    Query query = _firestore.collection('items').orderBy('Code', descending: true);
    
    if (selectedCategory != '전체') {
      query = query.where('Category.Main', isEqualTo: selectedCategory);
    }
    
    return query.limit(limit);
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
      final newItems = await Future.wait(
        snapshot.docs.map((doc) => _createMallItem(doc))
      );

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
    final storageRef = FirebaseStorage.instance.ref().child('items/${doc.id}.jpg');
    final imageUrl = await storageRef.getDownloadURL();

    return MallItem(
      code: data['Code']?.toString() ?? '',
      name: data['Name'] ?? '',
      price: data['Price']?.toString() ?? '',
      brand: data['Brand'] ?? '',
      category: '${data['Category']?['Main'] ?? ''} > ${data['Category']?['Sub'] ?? ''}',
      mainCategory: data['Category']?['Main'] ?? '',
      subCategory: data['Category']?['Sub'] ?? '',
      imageUrl: imageUrl,
      link: data['Link'] ?? '',
    );
  }

  Future<void> _refreshItems() async {
    setState(() {
      items.clear();
      lastDocument = null;
      hasMore = true;
    });
    await _loadMoreItems();
  }

  Future<void> _handleCategorySelect(String category) async {
    if (category == selectedCategory) return;
    
    setState(() {
      selectedCategory = category;
    });
    await _refreshItems();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            _buildCategoryFilters(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshItems,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: categories.map((category) => _buildFilterChip(category)).toList(),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _handleCategorySelect(label),
        backgroundColor: Colors.white,
        selectedColor: AppColors.navy,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
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
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          return MallItemCard(
            item: items[index],
            onLikePressed: () {
              // TODO: Implement wishlist functionality
            },
            onBuyPressed: () => _launchURL(items[index].link),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.navy,
                ),
              ),
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
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromARGB(224, 165, 147, 224),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '상품을 불러오는 중입니다...',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
            ),
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
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: AppColors.blue,
          ),
          SizedBox(height: 16),
          Text(
            '상품이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/controller/mall_controller.dart';
// import 'package:flutter_application_1/models/MallItem.dart';
// import 'package:flutter_application_1/repository/mall_repository.dart';
// import 'package:flutter_application_1/screens/shop/mall_widgets.dart';
// import 'package:url_launcher/url_launcher.dart';

// class MallScreen extends StatefulWidget {
//   const MallScreen({super.key});

//   @override
//   _MallScreenState createState() => _MallScreenState();
// }

// class _MallScreenState extends State<MallScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final List<String> categories = ['전체', '상의', '하의', '아우터', '악세서리'];
  
//   late final MallController _controller;
//   List<MallItem> items = [];
//   bool isLoading = false;
//   bool _disposed = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = MallController(repository: MallRepository());
//     _loadMoreItems();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (!_scrollController.hasClients) return;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.offset;
//     if (currentScroll >= (maxScroll * 0.7)) {
//       _loadMoreItems();
//     }
//   }

//   Future<void> _loadMoreItems() async {
//     if (isLoading || !_controller.hasMore || _disposed) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final newItems = await _controller.loadMoreItems();
//       if (!_disposed) {
//         setState(() {
//           items.addAll(newItems);
//           isLoading = false;
//         });
//       }
//     } catch (error) {
//       print('Error loading items: $error');
//       if (!_disposed) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _refreshItems() async {
//     setState(() {
//       items.clear();
//       _controller.resetPagination();
//     });
//     await _loadMoreItems();
//   }

//   Future<void> _handleCategorySelect(String category) async {
//     if (category == _controller.currentCategory) return;
    
//     _controller.updateCategory(category);
//     await _refreshItems();
//   }

//   Future<void> _launchURL(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       if (!_disposed) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('링크를 열 수 없습니다')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.teal.shade50, Colors.white],
//           ),
//         ),
//         child: Column(
//           children: [
//             MallWidgets.buildCategoryFilters(
//               categories: categories,
//               selectedCategory: _controller.currentCategory,
//               onCategorySelected: _handleCategorySelect,
//             ),
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: _refreshItems,
//                 child: _buildContent(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     if (items.isEmpty && isLoading) {
//       return const _LoadingIndicator();
//     }

//     if (items.isEmpty && !isLoading) {
//       return const _EmptyContent();
//     }

//     return MallWidgets.buildGridView(
//       items: items,
//       isLoading: isLoading,
//       scrollController: _scrollController,
//       onBuyPressed: _launchURL,
//       onLikePressed: () {}, // TODO: Implement wishlist functionality
//     );
//   }
// }

// class _LoadingIndicator extends StatelessWidget {
//   const _LoadingIndicator({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(224, 165, 147, 224)),
//           ),
//           SizedBox(height: 16),
//           Text(
//             '로딩 중...',
//             style: TextStyle(
//               color: Colors.black54,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _EmptyContent extends StatelessWidget {
//   const _EmptyContent({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.shopping_bag_outlined,
//             size: 64,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             '상품이 없습니다',
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             '다른 카테고리를 선택해보세요',
//             style: TextStyle(
//               color: Colors.grey[500],
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }