// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:peopleconnect/main.dart';

void main() {
  testWidgets('People Connect home screen renders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PeopleConnectApp());

    expect(find.text('தமிழ்நாடு மக்கள் குரல்'), findsOneWidget);
    expect(find.text('புகாரைப் பதிவு செய்யுங்கள்'), findsOneWidget);
  });
}
