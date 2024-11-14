import 'package:flutter/material.dart';

class MenuOption {
  final Icon icon;
  final String title;
  final VoidCallback onTap;

  MenuOption({required this.icon, required this.title, required this.onTap});
}

