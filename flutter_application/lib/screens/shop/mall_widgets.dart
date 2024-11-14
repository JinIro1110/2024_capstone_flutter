import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/MallItem.dart';
import 'package:flutter_application_1/widgets/mall_item_card.dart';

class MallWidgets {
  static Widget buildCategoryFilters({
    required List<String> categories,
    required String selectedCategory,
    required Function(String) onCategorySelected,
  }) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: categories.map((category) => 
          _buildFilterChip(
            label: category,
            isSelected: selectedCategory == category,
            onSelected: onCategorySelected,
          )
        ).toList(),
      ),
    );
  }

  static Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(String) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(label),
        backgroundColor: Colors.white,
        selectedColor: const Color.fromARGB(224, 165, 147, 224),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  static Widget buildGridView({
    required List<MallItem> items,
    required bool isLoading,
    required ScrollController scrollController,
    required Function(String) onBuyPressed,
    required VoidCallback onLikePressed,
  }) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => MallItemCard(
                item: items[index],
                onLikePressed: onLikePressed,
                onBuyPressed: () => onBuyPressed(items[index].link),
              ),
              childCount: items.length,
            ),
          ),
        ),
        if (isLoading)
          const SliverToBoxAdapter(
            child: _LoadingIndicator(),
          ),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(224, 165, 147, 224)),
          ),
          SizedBox(height: 16),
          Text(
            '로딩 중...',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}