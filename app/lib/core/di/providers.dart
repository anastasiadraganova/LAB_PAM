import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/api_auth_repository.dart';
import '../../features/auth/data/mock_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/events/data/api_events_repository.dart';
import '../../features/events/data/cached_events_repository.dart';
import '../../features/events/data/mock_events_repository.dart';
import '../../features/events/domain/events_repository.dart';
import '../../features/my_tickets/data/api_tickets_repository.dart';
import '../../features/my_tickets/data/cached_tickets_repository.dart';
import '../../features/my_tickets/data/mock_tickets_repository.dart';
import '../../features/my_tickets/domain/tickets_repository.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';
import '../network/token_storage.dart';
import '../storage/local_cache.dart';

/// Dependency wiring: the one place that decides which implementation stands
/// behind each repository.
///
/// By default the app talks to the backend. `--dart-define=USE_MOCKS=true`
/// runs it on the in-memory mock repositories instead, with no server at
/// all; tests do the same through [useMocksProvider]. State and screens do
/// not know which one they got.

/// Mock repositories instead of the backend.
final useMocksProvider = Provider<bool>(
  (ref) => const bool.fromEnvironment('USE_MOCKS'),
);

/// Artificial delay of every mock call, so that loading is visible. Tests set
/// it to zero.
final mockLatencyProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 400),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);

/// What survives a restart besides the token: the last listing, the tickets
/// and the account, for opening the app without a network.
final localCacheProvider = Provider<LocalCache>((ref) => PreferencesCache());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    baseUrl: ApiConfig.baseUrl,
    tokens: ref.watch(tokenStorageProvider),
    // The backend no longer accepts the token: back to the sign-in screen.
    onUnauthorized: () => ref.read(authControllerProvider.notifier).signOut(),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ref.watch(useMocksProvider)
      ? MockAuthRepository(latency: ref.watch(mockLatencyProvider))
      : ApiAuthRepository(
          ref.watch(apiClientProvider),
          ref.watch(localCacheProvider),
        ),
);

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => ref.watch(useMocksProvider)
      ? MockEventsRepository(latency: ref.watch(mockLatencyProvider))
      : CachedEventsRepository(
          ApiEventsRepository(ref.watch(apiClientProvider)),
          ref.watch(localCacheProvider),
        ),
);

final ticketsRepositoryProvider = Provider<TicketsRepository>(
  (ref) => ref.watch(useMocksProvider)
      ? MockTicketsRepository(latency: ref.watch(mockLatencyProvider))
      : CachedTicketsRepository(
          ApiTicketsRepository(ref.watch(apiClientProvider)),
          ref.watch(localCacheProvider),
        ),
);
