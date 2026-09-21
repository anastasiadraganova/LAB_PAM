import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/events/presentation/events_screen.dart';
import 'features/my_tickets/presentation/my_tickets_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'shared/widgets/app_bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'ru';
  await initializeDateFormatting('ru');
  runApp(const EventHubApp());
}

/// Application root. Routing and state arrive in the next stages; for now the
/// screens are wired together by hand so that they can be walked through.
class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const _Entry(),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry();

  @override
  Widget build(BuildContext context) {
    return AuthScreen(
      onSubmit: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (context) => const _Shell()),
      ),
    );
  }
}

/// The three sections behind the bottom navigation. This becomes a `ShellRoute`
/// once the router is in place.
class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const EventsScreen(),
          const MyTicketsScreen(),
          ProfileScreen(onSignOut: () => Navigator.of(context).pop()),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onSelected: (index) => setState(() => _index = index),
      ),
    );
  }
}
