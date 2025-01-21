import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/screens/closet/selection_manager.dart';
import 'package:flutter_application_1/services/closet_data.dart';
import 'package:flutter_application_1/models/ClosetItem.dart';
import 'package:flutter_application_1/services/firebase_data.dart';
import 'package:flutter_application_1/utils/constants.dart';
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
  final _closetDataService = ClosetDataService();
  final _selectionManager = SelectionManager();
  final _dataService = ImageUploadService();

  List<ClosetItem> items = []; // 유저 의상
  bool isLoading = false; // 로딩 상태
  DocumentSnapshot? lastDocument; // 마지막 문서
  static const int pageSize = 10; // 한 페이지에 10개

  bool isSelectionMode = false; // 선택모드
  bool isDeleteMode = false; // 삭제 모드

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

    try {
      final result = await _closetDataService.loadInitialClosetData(user.uid);

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 중 오류 발생: $e')),
        );
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> loadMoreData() async {
    if (isLoading || lastDocument == null) return;

    final user = Provider.of<LoginAuth>(context, listen: false).user;
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      final result =
          await _closetDataService.loadMoreClosetData(user.uid, lastDocument!);

      if (!mounted) return;

      if (result['error'] != null) {
        print(result['error']);
      } else {
        setState(() {
          items.addAll(result['items']);
          lastDocument = result['lastDocument'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 추가 로드 중 오류 발생: $e')),
        );
      }
    }

    setState(() => isLoading = false);
  }

// 사진 촬영
  Future<void> takePicture() async {
    final user = Provider.of<LoginAuth>(context, listen: false).user;
    if (user == null) return;

    final result = await _dataService.uploadImageFromCamera(
      userId: user.uid,
      context: context,
      onUploadSuccess: (metadata, downloadUrl) async {
        final saveResult = await _closetDataService.saveClosetItem(
          userId: user.uid,
          imageUrl: downloadUrl,
          style: metadata.style,
          size: metadata.size,
          part: metadata.part,
        );

        if (saveResult['error'] != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(saveResult['error'])),
          );
        } else {
          loadInitialData();
        }
      },
    );

    if (result['error'] != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
    }
  }

  void toggleSelection(ClosetItem item) {
    setState(() {
      _selectionManager.toggleSelection(item, (errorMessage) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      });
    });
  }

// 선택 모드 관리
  Future<void> completeSelectionMode() async {
    final user = Provider.of<LoginAuth>(context, listen: false).user;
    if (user == null) return;

    if (_selectionManager.selectedItems.length == 2) {
      // 서버로 데이터 전송
      final result =
          await _selectionManager.sendTopBottomToServer(user.uid, context);
      setState(() {
        _selectionManager.clearSelection();
        isSelectionMode = false;
      });
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('상하의를 선택해주세요.'),
        ),
      );
    }
  }

// 삭제 모드 관리
  Future<void> completeDeleteMode() async {
    if (_selectionManager.selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제할 아이템을 선택해주세요.')),
      );
      return;
    }

    // 확인 메시지
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Text(
            '삭제 확인',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          content: Text(
            '${_selectionManager.selectedItems.length}개의 아이템을 삭제하시겠습니까?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              child: Text(
                '예',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              child: Text(
                '아니오',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        setState(() => isLoading = true); // 로딩 상태 시작

        // 삭제 작업 수행
        await _selectionManager.deleteSelectedItems(context, (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          }
        });

        // 약간의 지연을 주어 Firebase 작업이 완료되도록 함
        await Future.delayed(const Duration(milliseconds: 500));

        // 데이터 새로고침
        if (mounted) {
          await loadInitialData();
        }

        // 삭제 후 UI 업데이트
        if (mounted) {
          setState(() {
            isDeleteMode = false; // 삭제 모드 종료
            isLoading = false; // 로딩 상태 종료
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
          );
          setState(() => isLoading = false); // 로딩 상태 종료
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                if (!isSelectionMode && !isDeleteMode) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.check_box_outline_blank,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        isSelectionMode = true;
                        isDeleteMode = false;
                        _selectionManager.clearSelection();
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        isDeleteMode = true;
                        isSelectionMode = false;
                        _selectionManager.clearSelection();
                      });
                    },
                  ),
                ] else if (isSelectionMode) ...[
                  IconButton(
                    icon: Icon(Icons.check, color: AppColors.navy, size: 32),
                    onPressed: completeSelectionMode,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.navy, size: 32),
                    onPressed: () {
                      setState(() {
                        isSelectionMode = false;
                        _selectionManager.clearSelection();
                      });
                    },
                  ),
                ] else if (isDeleteMode) ...[
                  IconButton(
                    icon: Icon(Icons.check, color: AppColors.navy, size: 32),
                    onPressed: completeDeleteMode,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.navy, size: 32),
                    onPressed: () {
                      setState(() {
                        isDeleteMode = false;
                        _selectionManager.clearSelection();
                      });
                    },
                  ),
                ],
              ],
            ),
            Expanded(
              child: isLoading && items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: loadInitialData,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (!isLoading &&
                              scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200) {
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
                            childAspectRatio: 0.7,
                          ),
                          // 여기서 항상 최소 1개 아이템(카메라 버튼)이 있도록 설정
                          itemCount: items.isEmpty ? 1 : items.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // 카메라 버튼
                              return GestureDetector(
                                onTap: takePicture,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: AppColors.white,
                                  ),
                                ),
                              );
                            }

                            final item = items[index - 1];
                            return ClothingItemCard(
                              item: item,
                              isSelected: _selectionManager.selectedItems
                                  .contains(item),
                              onToggleSelection: () {
                                setState(() {
                                  if (isSelectionMode) {
                                    toggleSelection(item);
                                  } else if (isDeleteMode) {
                                    _selectionManager.toggleDeletion(item);
                                  }
                                });
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
