import 'package:eventhub/core/di/providers.dart';
import 'package:eventhub/core/router/app_router.dart';
import 'package:eventhub/core/router/app_routes.dart';
import 'package:eventhub/features/auth/data/mock_auth_repository.dart';
import 'package:eventhub/features/profile/data/demo_user.dart';
import 'package:eventhub/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Locale and fonts the way `main` sets them, without network access.
Future<void> setUpTestEnvironment() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  Intl.defaultLocale = 'ru';
  await initializeDateFormatting('ru');
}

/// Pumps the whole application on mock repositories with no artificial delay.
///
/// [signedIn] starts the session with the demo user already signed in.
Future<void> pumpApp(
  WidgetTester tester, {
  String location = AppRoutes.events,
  bool signedIn = true,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        useMocksProvider.overrideWithValue(true),
        mockLatencyProvider.overrideWithValue(Duration.zero),
        authRepositoryProvider.overrideWithValue(
          MockAuthRepository(
            latency: Duration.zero,
            signedIn: signedIn ? demoUser : null,
          ),
        ),
        initialLocationProvider.overrideWithValue(location),
      ],
      child: const EventHubApp(),
    ),
  );
  await tester.pumpAndSettle();
}
