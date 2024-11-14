import 'package:flutter_application_1/models/MallItem.dart';

List<MallItem> filterItems(List<MallItem> items, String category) {
  if (category == '전체') {
    return items;
  }
  return items.where((item) => item.mainCategory == category).toList();
}
