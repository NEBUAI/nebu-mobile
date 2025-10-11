// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    // Build a simple app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));

    // Verify that the app starts
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
