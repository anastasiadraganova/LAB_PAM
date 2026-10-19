import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eventhub/main.dart';

void main() {
  testWidgets('application boots', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(EventHubApp());

    expect(find.byType(EventHubApp), findsOneWidget);
  });
}
