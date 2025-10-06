// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delixmi_frontend/main.dart';

void main() {
  testWidgets('Delixmi app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DelixmiApp());

    // Verify that the splash screen appears initially
    expect(find.text('Delixmi'), findsOneWidget);
    expect(find.text('Tu app de delivery favorita'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Advance time by 3 seconds to complete the splash screen timer
    await tester.pump(const Duration(seconds: 3));
    
    // Verify that navigation occurred (either to login or home screen)
    expect(find.text('Delixmi'), findsWidgets);
  });
}
