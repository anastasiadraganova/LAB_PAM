import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/ticket.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/tickets_repository.dart';

/// Tickets of the signed in user, newest order first.
///
/// The list follows the session: it is empty while nobody is signed in and is
/// loaded again for each new user. Buying and cancelling go through the
/// repository first and update the list only once it has agreed.
final ticketsControllerProvider =
    AsyncNotifierProvider<TicketsController, List<Ticket>>(
      TicketsController.new,
    );

class TicketsController extends AsyncNotifier<List<Ticket>> {
  TicketsRepository get _repository => ref.read(ticketsRepositoryProvider);

  @override
  Future<List<Ticket>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const [];
    return ref.watch(ticketsRepositoryProvider).fetchTickets(user.id);
  }

  /// Buys [qty] tickets for [event] and puts the new ticket on top.
  ///
  /// Throws [TicketException] when the order is refused.
  Future<Ticket> purchase(Event event, int qty) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw const TicketException(AppTexts.signInRequired);

    final ticket = await _repository.purchase(
      userId: user.id,
      event: event,
      qty: qty,
    );
    _apply((tickets) => [ticket, ...tickets]);
    return ticket;
  }

  /// Cancels an active ticket; it stays in the list with the new status.
  ///
  /// Throws [TicketException] when the ticket can no longer be cancelled.
  Future<void> cancel(String ticketId) async {
    final cancelled = await _repository.cancel(ticketId);
    _apply(
      (tickets) => [
        for (final ticket in tickets)
          ticket.id == cancelled.id ? cancelled : ticket,
      ],
    );
  }

  /// Changes the loaded list in place. If the list has not been loaded yet,
  /// it is loaded again instead, and the repository already has the change.
  void _apply(List<Ticket> Function(List<Ticket> tickets) change) {
    if (!ref.mounted) return;
    final tickets = state.value;
    if (tickets == null || state.isLoading) {
      ref.invalidateSelf();
    } else {
      state = AsyncData(change(tickets));
    }
  }
}
