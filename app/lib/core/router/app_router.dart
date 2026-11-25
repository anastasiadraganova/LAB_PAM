import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/event_details/presentation/event_details_screen.dart';
import '../../features/events/presentation/events_providers.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/events/presentation/new_event_screen.dart';
import '../../features/my_tickets/presentation/my_tickets_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/purchase/presentation/purchase_screen.dart';
import '../../shared/models/event.dart';
import '../../shared/validation/validators.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import 'app_routes.dart';

/// Where the app opens. Tests override it to start on a given screen.
final initialLocationProvider = Provider<String>((ref) => AppRoutes.events);

/// The router lives in the provider tree, so that its redirects can read the
/// session and it is rebuilt nowhere else.
final routerProvider = Provider<GoRouter>((ref) {
  // Every change of the signed in user re-runs the redirects.
  final sessionChanges = ValueNotifier<int>(0);
  ref.listen(currentUserProvider, (_, _) => sessionChanges.value++);

  final router = createAppRouter(
    ref,
    initialLocation: ref.read(initialLocationProvider),
    refreshListenable: sessionChanges,
  );

  ref.onDispose(() {
    router.dispose();
    sessionChanges.dispose();
  });
  return router;
});

/// Route table.
///
/// The three sections live in a shell with the bottom navigation, each on its
/// own stack so that switching sections keeps the scroll position. The event
/// card and the purchase screen cover the whole screen, navigation included —
/// they have their own action bar at the bottom.
///
/// Access follows the session: signed out, every path leads to the sign-in
/// screen; signed in, the sign-in screen leads to the listing.
GoRouter createAppRouter(
  Ref ref, {
  String initialLocation = AppRoutes.events,
  Listenable? refreshListenable,
}) {
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
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
                  // Before ':id', which would otherwise take "new" for an id.
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) => const NewEventScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootKey,
                    redirect: (context, state) async =>
                        await _eventOf(ref, state) == null
                        ? AppRoutes.events
                        : null,
                    builder: (context, state) => EventDetailsScreen(
                      eventId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'buy',
                        parentNavigatorKey: rootKey,
                        // Tickets to a past event are not sold: such a link
                        // lands on the event card, which says why.
                        redirect: (context, state) async {
                          final event = await _eventOf(ref, state);
                          if (event == null) return AppRoutes.events;
                          if (event.isPast()) return AppRoutes.event(event.id);
                          return null;
                        },
                        builder: (context, state) => PurchaseScreen(
                          eventId: state.pathParameters['id']!,
                          initialQty:
                              Validators.parseQty(
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
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/') return AppRoutes.events;

      final isSignedIn = ref.read(currentUserProvider) != null;
      final isAtAuth = path == AppRoutes.auth;
      if (!isSignedIn && !isAtAuth) return AppRoutes.auth;
      if (isSignedIn && isAtAuth) return AppRoutes.events;
      return null;
    },
    // An unknown path leads back to the listing instead of an error page.
    onException: (context, state, router) => router.go(AppRoutes.events),
  );
}

/// The event a path points to, loaded through the same provider the screens
/// use, so the redirect and the screen share one request.
Future<Event?> _eventOf(Ref ref, GoRouterState state) async {
  final id = state.pathParameters['id'];
  return id == null ? null : ref.read(eventByIdProvider(id).future);
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
        onSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
      ),
    );
  }
}
