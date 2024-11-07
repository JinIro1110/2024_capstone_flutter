import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:flutter_application_1/models/ClosetItem.dart';
import 'package:flutter_application_1/models/Metadata.dart';
import 'package:flutter_application_1/screens/closet/selected_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ClosetScreen extends StatefulWidget {
  final List<ClosetItem> initialItems;
  final DocumentSnapshot? initialLastDocument;
  final bool isInitialLoading;

  const ClosetScreen({
    Key? key,
    this.initialItems = const [],
    this.initialLastDocument,
    this.isInitialLoading = false,
  }) : super(key: key);

  @override
  _ClosetScreenState createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final ImagePicker _picker = ImagePicker();
  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;
  final _dataService = ClosetDataService();

  List<ClosetItem> items = [];
  bool isLoading = false;
  DocumentSnapshot? lastDocument;
  static const int pageSize = 10;

  bool isSelectionMode = false; // Selection mode toggle
  List<ClosetItem> selectedItems = []; // Selected items list
  ClosetItem? selectedTop; // Selected top item
  ClosetItem? selectedBottom; // Selected bottom item

  @override
  void initState() {
    super.initState();
    items = widget.initialItems;
    lastDocument = widget.initialLastDocument;
    isLoading = widget.isInitialLoading;

    if (items.isEmpty && !isLoading) {
      loadInitialData();
    }
  }

  Future<void> loadInitialData() async {
    if (!mounted) return;

    final user = Provider.of<LoginAuth>(context, listen: false).user;
    if (user == null) return;

    setState(() => isLoading = true);

    final result = await _dataService.loadInitialClosetData(user.uid);

    if (!mounted) return;

    if (result['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
    } else {
      setState(() {
        items = result['items'];
        lastDocument = result['lastDocument'];
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> loadMoreData() async {
    if (isLoading || lastDocument == null) return;
    final user = Provider.of<LoginAuth>(context, listen: false).user;
    if (user == null) return;

    setState(() => isLoading = true);

    final result =
        await _dataService.loadMoreClosetData(user.uid, lastDocument!);

    if (result['error'] != null) {
      print(result['error']);
    } else {
      setState(() {
        items.addAll(result['items']);
        lastDocument = result['lastDocument'];
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> takePicture() async {
    final user = Provider.of<LoginAuth>(context, listen: false).user;
    if (user == null) return;

    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;

      final metadata = await showDialog<ClothingMetadata>(
        context: context,
        builder: (context) => const MetadataInputDialog(),
      );

      if (metadata == null) return;

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref('closet/${user.uid}/images/$fileName');

      await ref.putFile(File(photo.path));
      final downloadUrl = await ref.getDownloadURL();

      final result = await _dataService.saveClosetItem(
        userId: user.uid,
        imageUrl: downloadUrl,
        style: metadata.style,
        size: metadata.size,
        part: metadata.part, // 선택된 part 저장
      );

      if (result['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      } else {
        loadInitialData();
      }
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save image')),
      );
    }
  }

  void toggleSelection(ClosetItem item) {
    setState(() {
      if (item.part == '상의') {
        if (selectedTop == item) {
          selectedTop = null; // 같은 상의를 다시 클릭하면 선택 해제
        } else if (selectedTop != null) {
          // 다른 상의가 이미 선택되어 있을 때
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미 상의가 선택되어 있습니다')),
          );
          return;
        } else {
          selectedTop = item; // 새로운 상의 선택
        }
      } else if (item.part == '하의') {
        if (selectedBottom == item) {
          selectedBottom = null; // 같은 하의를 다시 클릭하면 선택 해제
        } else if (selectedBottom != null) {
          // 다른 하의가 이미 선택되어 있을 때
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미 하의가 선택되어 있습니다')),
          );
          return;
        } else {
          selectedBottom = item; // 새로운 하의 선택
        }
      }

      // 선택된 아이템 리스트 업데이트
      selectedItems = [];
      if (selectedTop != null) {
        selectedItems.add(selectedTop!);
      }
      if (selectedBottom != null) {
        selectedItems.add(selectedBottom!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginAuth>(context, listen: false).user;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, size: 32),
                  onPressed: takePicture,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    isSelectionMode
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      isSelectionMode = !isSelectionMode;
                      selectedItems.clear();
                    });
                  },
                ),
                if (isSelectionMode) ...[
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('선택된 아이템이 없습니다')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectedItemsScreen(
                            selectedItems: selectedItems,
                            userId: user?.uid ?? '',
                          ),
                        ),
                      );
                    },
                    child: const Text('완료'),
                  ),
                ],
              ],
            ),
            Expanded(
              child: isLoading && items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const Center(child: Text('Your closet is empty'))
                      : RefreshIndicator(
                          onRefresh: loadInitialData,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (!isLoading &&
                                  scrollInfo.metrics.pixels >=
                                      scrollInfo.metrics.maxScrollExtent -
                                          200) {
                                loadMoreData();
                              }
                              return true;
                            },
                            child: GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: items.length + (isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == items.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return ClothingItemCard(
                                  item: items[index],
                                  isSelectionMode: isSelectionMode,
                                  isSelected:
                                      selectedItems.contains(items[index]),
                                  onToggleSelection: () {
                                    if (isSelectionMode) {
                                      toggleSelection(items[index]);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
