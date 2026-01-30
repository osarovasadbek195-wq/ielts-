// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ielts_sat_prep_app/main.dart';

void main() {
  testWidgets('App loads HomeScreen with tabs', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the main tabs render correctly
    expect(find.text('IELTS'), findsWidgets);
    expect(find.text('SAT'), findsWidgets);

    // Ensure that the Fun Zone tab exists
    expect(find.text('Fun Zone'), findsOneWidget);

    // Ensure no uncaught exceptions by pumping a frame
    await tester.pump(const Duration(milliseconds: 100));
  });
}
