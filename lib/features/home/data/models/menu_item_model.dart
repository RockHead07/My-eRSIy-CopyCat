import 'package:flutter/material.dart';

enum MenuActionType { native, webview, comingSoon }

class MenuItemModel {
  const MenuItemModel({
    required this.id,
    required this.label,
    required this.iconAsset,
    required this.actionType,
    this.routeName,
    this.webUrl,
    this.webTitle,
    this.fallbackIcon,
  });

  final String id;
  final String label;
  final String iconAsset;
  final MenuActionType actionType;
  final String? routeName;
  final String? webUrl;
  final String? webTitle;
  final IconData? fallbackIcon;
}
