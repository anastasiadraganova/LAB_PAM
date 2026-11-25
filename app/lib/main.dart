import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'ru';
  await initializeDateFormatting('ru');

  // All application state lives in this container: repositories, the
  // session, the listing with its filters and the tickets.
  final container = ProviderContainer();

  // The saved session is checked before the first frame, so the router knows
  // at once whether to show the sign-in screen. A backend that does not
  // answer quickly only means signing in again.
  await container
      .read(authRepositoryProvider)
      .restoreSession()
      .timeout(const Duration(seconds: 5), onTimeout: () {});

  runApp(
    UncontrolledProviderScope(container: container, child: const EventHubApp()),
  );
}

/// Application root. It needs a [ProviderScope] above it.
class EventHubApp extends ConsumerWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'EventHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
