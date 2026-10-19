import 'package:eventhub/core/router/app_routes.dart';
import 'package:eventhub/main.dart';
import 'package:eventhub/shared/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Demo events used below: `e1` is in the past, `e13` is a paid future event.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    Intl.defaultLocale = 'ru';
    await initializeDateFormatting('ru');
  });

  Future<void> pumpAt(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(EventHubApp(initialLocation: location));
    await tester.pumpAndSettle();
  }

  testWidgets('sign-in form does not let empty fields through', (tester) async {
    await pumpAt(tester, AppRoutes.auth);

    await tester.tap(find.text(AppTexts.signIn).last);
    await tester.pumpAndSettle();

    expect(find.text('Введите почту.'), findsOneWidget);
    expect(find.text('Введите пароль.'), findsOneWidget);
    expect(find.text(AppTexts.titleListing), findsNothing);

    await tester.enterText(find.byType(TextField).at(0), 'anna@mail.ru');
    await tester.enterText(find.byType(TextField).at(1), 'secret1');
    await tester.tap(find.text(AppTexts.signIn).last);
    await tester.pumpAndSettle();

    expect(find.text(AppTexts.titleListing), findsWidgets);
  });

  testWidgets('a past event offers no purchase', (tester) async {
    await pumpAt(tester, AppRoutes.event('e1'));

    expect(find.text(AppTexts.eventIsPast), findsOneWidget);
    expect(find.textContaining('Купить'), findsNothing);
  });

  testWidgets('a purchase link to a past event lands on its card',
      (tester) async {
    await pumpAt(tester, AppRoutes.purchase('e1'));

    expect(find.text(AppTexts.eventIsPast), findsOneWidget);
  });

  testWidgets('an out-of-range quantity in a link falls back to one',
      (tester) async {
    await pumpAt(tester, AppRoutes.purchase('e13', qty: 42));

    expect(find.text(AppTexts.buyTickets(1)), findsOneWidget);
  });

  testWidgets('counter stops at 10 and the purchase reaches my tickets',
      (tester) async {
    await pumpAt(tester, AppRoutes.purchase('e13'));

    final plus = find.byIcon(Icons.add);
    for (var i = 0; i < 15; i++) {
      await tester.tap(plus);
      await tester.pump();
    }
    expect(find.text('10'), findsOneWidget);
    expect(find.text(AppTexts.quantityLimit), findsOneWidget);
    expect(find.text('4 000 L'), findsNothing);

    await tester.tap(find.text(AppTexts.buyTickets(10)));
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.checkOrder), findsOneWidget);

    await tester.tap(find.text(AppTexts.buyTickets(10)).last);
    await tester.pumpAndSettle();

    expect(find.text(AppTexts.titleMyTickets), findsOneWidget);
    expect(find.text(AppTexts.ticketBought), findsOneWidget);
  });
}
