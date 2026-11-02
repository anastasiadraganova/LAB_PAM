import 'package:eventhub/core/di/providers.dart';
import 'package:eventhub/features/auth/presentation/auth_controller.dart';
import 'package:eventhub/features/events/presentation/events_providers.dart';
import 'package:eventhub/features/my_tickets/domain/tickets_repository.dart';
import 'package:eventhub/features/my_tickets/presentation/tickets_controller.dart';
import 'package:eventhub/features/profile/data/demo_user.dart';
import 'package:eventhub/shared/app_texts.dart';
import 'package:eventhub/shared/models/event_category.dart';
import 'package:eventhub/shared/models/ticket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// State on top of the mock repositories, without any widgets.
/// Demo data: `e1` is in the past, `e13` is a future event at 400 L.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        useMocksProvider.overrideWithValue(true),
        mockLatencyProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> signIn() => container
      .read(authControllerProvider.notifier)
      .signIn(email: demoUser.email, password: demoPassword);

  test('filters narrow the loaded listing', () async {
    container.listen(visibleEventsProvider, (_, _) {});
    final all = await container.read(eventsProvider.future);

    container
        .read(eventFiltersProvider.notifier)
        .setCategory(EventCategory.hackathon);
    final hackathons = container.read(visibleEventsProvider).requireValue;

    expect(hackathons, isNotEmpty);
    expect(hackathons.length, lessThan(all.length));
    expect(
      hackathons.every((e) => e.category == EventCategory.hackathon),
      isTrue,
    );
  });

  test('wrong password leaves the session empty with an error', () async {
    await container
        .read(authControllerProvider.notifier)
        .signIn(email: demoUser.email, password: 'wrong-one');

    expect(container.read(authControllerProvider).hasError, isTrue);
    expect(container.read(currentUserProvider), isNull);
  });

  test('purchase and cancel update the tickets of the user', () async {
    await signIn();
    container.listen(ticketsControllerProvider, (_, _) {});
    final before = await container.read(ticketsControllerProvider.future);

    final event = (await container.read(eventByIdProvider('e13').future))!;
    final tickets = container.read(ticketsControllerProvider.notifier);
    final ticket = await tickets.purchase(event, 2);

    var state = container.read(ticketsControllerProvider).requireValue;
    expect(state.length, before.length + 1);
    expect(state.first.totalPrice, 800);

    await tickets.cancel(ticket.id);
    state = container.read(ticketsControllerProvider).requireValue;
    expect(state.first.status, TicketStatus.cancelled);

    await expectLater(
      tickets.cancel(ticket.id),
      throwsA(isA<TicketException>()),
    );
  });

  test('a past event is not sold and signing out clears tickets', () async {
    await signIn();
    container.listen(ticketsControllerProvider, (_, _) {});
    await container.read(ticketsControllerProvider.future);

    final past = (await container.read(eventByIdProvider('e1').future))!;
    await expectLater(
      container.read(ticketsControllerProvider.notifier).purchase(past, 1),
      throwsA(
        isA<TicketException>().having(
          (e) => e.message,
          'message',
          AppTexts.eventIsPast,
        ),
      ),
    );

    await container.read(authControllerProvider.notifier).signOut();
    expect(await container.read(ticketsControllerProvider.future), isEmpty);
  });
}
