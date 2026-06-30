import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/features/home/data/models/menu_item_model.dart';

void main() {
  test('MenuActionType covers all navigation paths', () {
    expect(MenuActionType.values.length, 3);
    expect(MenuActionType.webview.name, 'webview');
  });
}
