import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/models/ClosetItem.dart';
import 'package:provider/provider.dart';

class SelectionManager {
  List<ClosetItem> selectedItems = []; // List to manage selected items

  // Item selection/deselection
  void toggleSelection(ClosetItem item, Function(String) onError) {
    if (selectedItems.contains(item)) {
      selectedItems.remove(item); // Deselect item
    } else {
      if (_isPartAlreadySelected(item, onError)) {
        return; // Prevent multiple selections of the same part
      }
      selectedItems.add(item); // Add item to selection
    }
  }

  // Check if part (top/bottom) is already selected
  bool _isPartAlreadySelected(ClosetItem item, Function(String) onError) {
    if (item.part == '상의' && selectedItems.any((i) => i.part == '상의')) {
      onError('이미 상의가 선택되어 있습니다');
      return true;
    } else if (item.part == '하의' && selectedItems.any((i) => i.part == '하의')) {
      onError('이미 하의가 선택되어 있습니다');
      return true;
    }
    return false;
  }

  // Toggle deletion mode for items
  void toggleDeletion(ClosetItem item) {
    if (selectedItems.contains(item)) {
      selectedItems.remove(item); // Deselect item in deletion mode
    } else {
      selectedItems.add(item); // Add item to selection in deletion mode
    }
  }

  // Delete selected items from Firestore and Firebase Storage
// Delete selected items from Firestore and Firebase Storage
  Future<void> deleteSelectedItems(
      BuildContext context, Function(String) onError) async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    // Use Provider to get LoginAuth instance
    LoginAuth loginAuth = Provider.of<LoginAuth>(context, listen: false);
    String? userId = loginAuth.user?.uid;

    if (userId == null) {
      onError('User is not authenticated');
      return;
    }

    for (var item in selectedItems) {
      try {
        print(item.id);
        print(userId);
        // First, delete the image from Firebase Storage
        final ref = storage.refFromURL(item.imageUrl);
        await ref.delete();

        // Now, delete the Firestore document
        await firestore
            .collection('closet')
            .doc(userId)
            .collection('images')
            .doc(item.id)
            .delete();
        print("Deleted Firestore document for item ${item.style}");
      } catch (e) {
        // Log specific error when deleting Firestore document
        onError('Error deleting Firestore document for ${item.style}: $e');
        print('Firestore deletion error: $e');
      }
    }

    clearSelection();
  }

  // Clear all selected items
  void clearSelection() {
    selectedItems.clear();
  }
}
