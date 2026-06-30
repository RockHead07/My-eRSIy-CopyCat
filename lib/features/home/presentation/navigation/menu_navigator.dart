import 'package:flutter/material.dart';
import 'package:rs_islam_app/features/home/data/models/menu_item_model.dart';
import 'package:rs_islam_app/features/home/presentation/screens/webview_screen.dart';

abstract final class MenuNavigator {
  static Future<void> handle(BuildContext context, MenuItemModel item) {
    switch (item.actionType) {
      case MenuActionType.webview:
        final url = item.webUrl;
        if (url == null || url.isEmpty) {
          return _showSnack(context, 'URL belum dikonfigurasi.');
        }
        return Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => WebViewScreen(
              url: url,
              title: item.webTitle ?? item.label,
            ),
          ),
        );
      case MenuActionType.native:
        final route = item.routeName;
        if (route == null || route.isEmpty) {
          return _showSnack(context, 'Route belum dikonfigurasi.');
        }
        return Navigator.of(context).pushNamed(route);
      case MenuActionType.comingSoon:
        return _showSnack(context, '${item.label} segera hadir.');
    }
  }

  static Future<void> _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    return Future<void>.value();
  }
}
