// filter.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';

// Enum으로 카테고리와 스타일 정의
enum MainCategory { all, top, bottom }
enum Style { all, casual, street, americana, minimal }

class FilterOptions {
  MainCategory? mainCategory;
  Style? style;

  FilterOptions({
    this.mainCategory,
    this.style,
  });

  // 복사 생성자 추가
  FilterOptions copyWith({
    MainCategory? mainCategory,
    Style? style,
  }) {
    return FilterOptions(
      mainCategory: mainCategory ?? this.mainCategory,
      style: style ?? this.style,
    );
  }
}

class AdvancedFilterWidget extends StatefulWidget {
  final FilterOptions currentFilters;
  final ValueChanged<FilterOptions> onFilterChanged;

  const AdvancedFilterWidget({
    super.key,
    required this.currentFilters,
    required this.onFilterChanged,
  });

  @override
  State<AdvancedFilterWidget> createState() => _AdvancedFilterWidgetState();
}

class _AdvancedFilterWidgetState extends State<AdvancedFilterWidget> {
  late FilterOptions _filters;

  // Enum 값들을 한글로 매핑하는 확장 함수
  String _getCategoryLabel(MainCategory category) {
    switch (category) {
      case MainCategory.all: return '전체';
      case MainCategory.top: return '상의';
      case MainCategory.bottom: return '하의';
    }
  }

  String _getStyleLabel(Style style) {
    switch (style) {
      case Style.all: return '전체';
      case Style.casual: return '캐주얼';
      case Style.street: return '스트릿';
      case Style.americana: return '아메카지';
      case Style.minimal: return '미니멀';
    }
  }

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
  }

  Widget _buildFilterSection<T>({
    required List<T> values,
    required T? selectedValue,
    required String Function(T) getLabel,
    required ValueChanged<T?> onSelected,
  }) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: values.map((value) {
          final label = getLabel(value);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: selectedValue == value,
              onSelected: (selected) {
                onSelected(selected ? value : null);
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.navy,
              labelStyle: TextStyle(
                color: selectedValue == value ? Colors.white : Colors.black87,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFilterSection(
          values: MainCategory.values,
          selectedValue: _filters.mainCategory,
          getLabel: _getCategoryLabel,
          onSelected: (category) {
            setState(() {
              _filters = _filters.copyWith(mainCategory: category);
            });
            widget.onFilterChanged(_filters);
          },
        ),
        const SizedBox(height: 12),
        _buildFilterSection(
          values: Style.values,
          selectedValue: _filters.style,
          getLabel: _getStyleLabel,
          onSelected: (style) {
            setState(() {
              _filters = _filters.copyWith(style: style);
            });
            widget.onFilterChanged(_filters);
          },
        ),
      ],
    );
  }
}