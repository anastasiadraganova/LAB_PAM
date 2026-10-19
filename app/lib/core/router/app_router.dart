import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/event_details/presentation/event_details_screen.dart';
import '../../features/events/data/demo_events.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/my_tickets/presentation/my_tickets_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/purchase/presentation/purchase_screen.dart';
import '../../shared/models/event.dart';
import '../../shared/validation/validators.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import 'app_routes.dart';

/// Route table.
///
/// The three sections live in a shell with the bottom navigation, each on its
/// own stack so that switching sections keeps the scroll position. The event
/// card and the purchase screen cover the whole screen, navigation included —
/// they have their own action bar at the bottom.
GoRouter createAppRouter({String initialLocation = AppRoutes.auth}) {
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => AuthScreen(
          onSubmit: () => context.go(AppRoutes.events),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Shell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.events,
                builder: (context, state) => const EventsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootKey,
                    redirect: (context, state) =>
                        _eventOf(state) == null ? AppRoutes.events : null,
                    builder: (context, state) =>
                        EventDetailsScreen(event: _eventOf(state)!),
                    routes: [
                      GoRoute(
                        path: 'buy',
                        parentNavigatorKey: rootKey,
                        // Tickets to a past event are not sold: such a link
                        // lands on the event card, which says why.
                        redirect: (context, state) {
                          final event = _eventOf(state);
                          if (event == null) return AppRoutes.events;
                          if (event.isPast()) return AppRoutes.event(event.id);
                          return null;
                        },
                        builder: (context, state) => PurchaseScreen(
                          event: _eventOf(state)!,
                          initialQty: Validators.parseQty(
                                state.uri.queryParameters['qty'],
                              ) ??
                              Validators.minQty,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.myTickets,
                builder: (context, state) => const MyTicketsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => ProfileScreen(
                  onSignOut: () => context.go(AppRoutes.auth),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) =>
        state.uri.path == '/' ? AppRoutes.events : null,
    // An unknown path leads back to the listing instead of an error page.
    onException: (context, state, router) => router.go(AppRoutes.events),
  );
}

Event? _eventOf(GoRouterState state) {
  final id = state.pathParameters['id'];
  return id == null ? null : demoEventById(id);
}

class _Shell extends StatelessWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: shell.currentIndex,
        // A second tap on the current section returns it to its first screen.
        onSelected: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
      ),
    );
  }
}
