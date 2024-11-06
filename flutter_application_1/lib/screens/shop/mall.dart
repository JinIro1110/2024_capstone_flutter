import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class MallScreen extends StatefulWidget {
  const MallScreen({super.key});

  @override
  _MallScreenState createState() => _MallScreenState();
}

class _MallScreenState extends State<MallScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  List<MallItem> items = [];
  bool isLoading = false;
  bool hasMore = true;
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

  Future<void> _loadMoreItems() async {
    if (isLoading || !hasMore || _disposed) return;

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot snapshot;
      Query query = _firestore
          .collection('items')
          .orderBy('Code', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      snapshot = await query.get();

      if (_disposed) return;

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;

        final newItems = await Future.wait(snapshot.docs.map((doc) async {
          final data = doc.data() as Map<String, dynamic>;

          // 문서 ID를 사용하여 이미지 URL 생성
          final storageRef =
              FirebaseStorage.instance.ref().child('items/${doc.id}.jpg');
          final imageUrl = await storageRef.getDownloadURL();

          return MallItem(
            code: data['Code']?.toString() ?? '',
            name: data['Name'] ?? '',
            price: data['Price']?.toString() ?? '',
            brand: data['Brand'] ?? '',
            category:
                '${data['Category']?['Main'] ?? ''} > ${data['Category']?['Sub'] ?? ''}',
            mainCategory: data['Category']?['Main'] ?? '',
            subCategory: data['Category']?['Sub'] ?? '',
            imageUrl: imageUrl, // 문서 ID 기반 이미지 URL
            link: data['Link'] ?? '',
          );
        }));

        if (!_disposed) {
          setState(() {
            items.addAll(newItems);
            isLoading = false;
          });
        }
      } else {
        if (!_disposed) {
          setState(() {
            hasMore = false;
            isLoading = false;
          });
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Mall',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(224, 165, 147, 224),
        elevation: 0,
      ),
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
              child: items.isEmpty && !isLoading
                  ? const Center(child: Text('No items available'))
                  : _buildGridView(),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('전체'),
          _buildFilterChip('상의'),
          _buildFilterChip('하의'),
          _buildFilterChip('아우터'),
          _buildFilterChip('악세서리'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (bool selected) {
          // TODO: Implement filter logic
        },
        backgroundColor: Colors.white,
        selectedColor: const Color.fromARGB(224, 165, 147, 224),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12.0), // 패딩 줄임
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75, // 비율 조정
        crossAxisSpacing: 12, // 간격 줄임
        mainAxisSpacing: 12, // 간격 줄임
      ),
      itemCount: items.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          return _buildItemCard(items[index]);
        } else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(224, 165, 147, 224),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildItemCard(MallItem item) {
    final formattedPrice = '${int.parse(item.price).toLocaleString()}원';

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 컨테이너
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.grey[100],
                child: Stack(
                  children: [
                    // 이미지를 중앙에 배치하고 비율 유지
                    Center(
                      child: AspectRatio(
                        aspectRatio: 0.9, // 비율을 약간 세로로 길게 수정
                        child: Padding(
                          padding: const EdgeInsets.all(4), // 패딩을 줄여서 이미지 크기 확보
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(224, 165, 147, 224),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.error,
                                  color: Colors.red, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 좋아요 버튼
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 16,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            // TODO: Implement wishlist functionality
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 상품 정보 컨테이너
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // 수직 패딩 줄임
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.brand,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2), // 간격 줄임
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2), // 간격 줄임
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      color: Color.fromARGB(224, 165, 147, 224),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6), // 간격 줄임
                  // 구매하기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => _launchURL(item.link),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(224, 165, 147, 224),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '구매하기',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewDetailsButton(String url) {
    return ElevatedButton(
      onPressed: () => _launchURL(url),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(224, 165, 147, 224),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size(double.infinity, 36),
      ),
      child: Text('구매하기'),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다')),
      );
    }
  }
}

class MallItem {
  final String code;
  final String name;
  final String price;
  final String brand;
  final String category;
  final String mainCategory;
  final String subCategory;
  final String imageUrl;
  final String link;

  MallItem({
    required this.code,
    required this.name,
    required this.price,
    required this.brand,
    required this.category,
    required this.mainCategory,
    required this.subCategory,
    required this.imageUrl,
    required this.link,
  });
}

extension NumberFormat on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
