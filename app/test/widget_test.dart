import 'package:flutter_test/flutter_test.dart';

import 'package:eventhub/main.dart';

void main() {
  testWidgets('application boots', (WidgetTester tester) async {
    await tester.pumpWidget(const EventHubApp());

    expect(find.byType(EventHubApp), findsOneWidget);
  });
}
