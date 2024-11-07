import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/ClosetItem.dart';

class SelectedItemsScreen extends StatelessWidget {
  final List<ClosetItem> selectedItems;
  final String userId;

  const SelectedItemsScreen({
    Key? key,
    required this.selectedItems,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('선택된 아이템 정보'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('User ID: $userId', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const Text('선택된 아이템:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...selectedItems.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('Document ID: ${item.id}'), // id를 사용할 수 없으므로 여기서 오류 발생
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Style: ${item.style}'),
                      Text('Size: ${item.size}'),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
