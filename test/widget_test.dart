import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/main.dart';

void main() {
  testWidgets('HomeScreen renders guest greeting', (tester) async {
    await tester.pumpWidget(
      const RsIslamApp(),
    );

    expect(find.text('Tamu'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Menu Layanan'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Menu Layanan'), findsOneWidget);
  });
}
