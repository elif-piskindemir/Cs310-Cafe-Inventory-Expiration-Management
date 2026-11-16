import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cafestock/main.dart';

void main() {
  testWidgets('Login screen displays fields and validates empty input',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CafeStockApp());

        expect(find.text('Welcome back to CafeStock'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));

        await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
        await tester.pump();

        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
      });
}