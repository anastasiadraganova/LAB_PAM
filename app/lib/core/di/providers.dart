import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/mock_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/events/data/mock_events_repository.dart';
import '../../features/events/domain/events_repository.dart';
import '../../features/my_tickets/data/mock_tickets_repository.dart';
import '../../features/my_tickets/domain/tickets_repository.dart';

/// Dependency wiring: the one place that decides which implementation stands
/// behind each repository.
///
/// The app runs on mock repositories for now. When the backend is ready, only
/// these three providers change; state and screens stay as they are. Tests
/// replace any of them with `overrideWithValue`.

/// Artificial delay of every mock call, so that loading is visible. Tests set
/// it to zero.
final mockLatencyProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 400),
);

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => MockEventsRepository(latency: ref.watch(mockLatencyProvider)),
);

final ticketsRepositoryProvider = Provider<TicketsRepository>(
  (ref) => MockTicketsRepository(latency: ref.watch(mockLatencyProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(latency: ref.watch(mockLatencyProvider)),
);
