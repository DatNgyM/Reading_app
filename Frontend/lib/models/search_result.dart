import 'package:flutter/material.dart';

class SearchResult {
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });
}
