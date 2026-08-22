import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takvim/main.dart';

void main() {
  testWidgets('Döngüsel Takvim smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TakvimApp());

    // Verify that the calendar screen is rendered by checking the title.
    expect(find.text('Takvim'), findsOneWidget);

    // Verify that the current year is displayed in the year selector container.
    final currentYear = DateTime.now().year.toString();
    expect(find.text(currentYear), findsAtLeastNWidgets(1));

    // Tap on the year selector forward button and trigger a frame.
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pump();

    // Verify that the year incremented.
    final nextYear = (DateTime.now().year + 1).toString();
    expect(find.text(nextYear), findsAtLeastNWidgets(1));
  });
}
