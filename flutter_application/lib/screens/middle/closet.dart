import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:flutter_application_1/models/ClosetItem.dart';
import 'package:flutter_application_1/models/ClosetMetadata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    items = widget.initialItems;
    lastDocument = widget.initialLastDocument;
    isLoading = widget.isInitialLoading;

    // 초기 데이터가 없는 경우에만 로드
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

      // Show dialog for metadata input
      final metadata = await showDialog<ClothingMetadata>(
        context: context,
        builder: (context) => MetadataInputDialog(),
      );

      if (metadata == null) return;

      // Upload image and metadata
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref('closet/${user.uid}/images/$fileName');

      await ref.putFile(File(photo.path));
      final downloadUrl = await ref.getDownloadURL();

      // Save metadata to Firestore
      await firestore.collection('closet/${user.uid}/images').add({
        'imageUrl': downloadUrl,
        'style': metadata.style,
        'size': metadata.size,
        'part': metadata.part,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Reload data
      loadInitialData();
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Camera button
            Center(
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 32),
                onPressed: takePicture,
              ),
            ),
            // Grid view of clothes
            Expanded(
              child: isLoading && items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Loading your closet...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wb_cloudy_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your closet is empty',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Take a picture to add clothes',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
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
                                return ClothingItemCard(item: items[index]);
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

class MetadataInputDialog extends StatefulWidget {
  const MetadataInputDialog({super.key});

  @override
  _MetadataInputDialogState createState() => _MetadataInputDialogState();
}

class _MetadataInputDialogState extends State<MetadataInputDialog> {
  String selectedStyle = '캐쥬얼';
  int selectedSize = 90;
  String selectedPart = "상의";

  final List<String> styles = ['캐쥬얼', '포멀', '스포츠', '스트릿', '비즈니스'];
  final List<int> sizes = List.generate(9, (index) => 80 + (index * 5));
  final List<String> parts = ['상의', '하의'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Clothing Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedStyle,
            decoration: const InputDecoration(labelText: '스타일'),
            items: styles.map((style) {
              return DropdownMenuItem(
                value: style,
                child: Text(style),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedStyle = value!);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: selectedSize,
            decoration: const InputDecoration(labelText: '사이즈'),
            items: sizes.map((size) {
              return DropdownMenuItem(
                value: size,
                child: Text(size.toString()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedSize = value!);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedPart, // 올바른 값으로 변경
            decoration: const InputDecoration(labelText: '상하의'),
            items: parts.map((part) {
              return DropdownMenuItem(
                value: part,
                child: Text(part),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedPart = value!); // selectedPart에 올바르게 할당
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              ClothingMetadata(
                  style: selectedStyle, size: selectedSize, part: selectedPart),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class ClothingItemCard extends StatelessWidget {
  final ClosetItem item;

  const ClothingItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Style: ${item.style}'),
                Text('Size: ${item.size}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
