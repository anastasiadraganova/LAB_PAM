import 'package:eventhub/core/router/app_routes.dart';
import 'package:eventhub/main.dart';
import 'package:eventhub/shared/app_texts.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

void main() {
  setUpAll(setUpTestEnvironment);

  testWidgets('application boots on the sign-in screen', (tester) async {
    await pumpApp(tester, location: AppRoutes.events, signedIn: false);

    expect(find.byType(EventHubApp), findsOneWidget);
    expect(find.text(AppTexts.titleSignIn), findsOneWidget);
  });
}
