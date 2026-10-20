import 'package:eventhub/core/router/app_routes.dart';
import 'package:eventhub/features/profile/data/demo_user.dart';
import 'package:eventhub/shared/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_app.dart';

/// Demo events used below: `e1` is in the past, `e13` is a paid future event.
void main() {
  setUpAll(setUpTestEnvironment);

  testWidgets('wrong password is refused, the right one signs in', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.auth, signedIn: false);

    await tester.enterText(find.byType(TextField).at(0), demoUser.email);
    await tester.enterText(find.byType(TextField).at(1), 'not-the-one');
    await tester.tap(find.text(AppTexts.signIn).last);
    await tester.pumpAndSettle();

    expect(find.text(AppTexts.wrongCredentials), findsOneWidget);
    expect(find.text(AppTexts.titleListing), findsNothing);

    await tester.enterText(find.byType(TextField).at(1), demoPassword);
    await tester.pump();
    expect(find.text(AppTexts.wrongCredentials), findsNothing);
    await tester.tap(find.text(AppTexts.signIn).last);
    await tester.pumpAndSettle();

    expect(find.text(AppTexts.titleListing), findsWidgets);
  });

  testWidgets('a signed out user is sent to sign in from any link', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.event('e13'), signedIn: false);

    expect(find.text(AppTexts.titleSignIn), findsOneWidget);
  });

  testWidgets('a past event offers no purchase', (tester) async {
    await pumpApp(tester, location: AppRoutes.event('e1'));

    expect(find.text(AppTexts.eventIsPast), findsOneWidget);
    expect(find.textContaining('Купить'), findsNothing);
  });

  testWidgets('counter stops at 10 and the purchase reaches my tickets', (
    tester,
  ) async {
    await pumpApp(tester, location: AppRoutes.purchase('e13'));

    final plus = find.byIcon(Icons.add);
    for (var i = 0; i < 15; i++) {
      await tester.tap(plus);
      await tester.pump();
    }
    expect(find.text('10'), findsOneWidget);
    expect(find.text(AppTexts.quantityLimit), findsOneWidget);

    await tester.tap(find.text(AppTexts.buyTickets(10)));
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.checkOrder), findsOneWidget);

    await tester.tap(find.text(AppTexts.buyTickets(10)).last);
    await tester.pumpAndSettle();

    expect(find.text(AppTexts.titleMyTickets), findsOneWidget);
    expect(find.text(AppTexts.ticketBought), findsOneWidget);
  });
}
