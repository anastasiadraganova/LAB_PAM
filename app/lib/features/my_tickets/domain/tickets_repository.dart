import '../../../shared/models/event.dart';
import '../../../shared/models/ticket.dart';

/// A ticket operation refused by the rules; [message] is ready to be shown.
class TicketException implements Exception {
  const TicketException(this.message);

  final String message;

  @override
  String toString() => 'TicketException: $message';
}

/// Tickets of a user: reading, buying and cancelling.
abstract interface class TicketsRepository {
  /// All tickets of [userId], the newest order first. Cancelled ones included.
  Future<List<Ticket>> fetchTickets(String userId);

  /// Buys [qty] tickets for [event]. The total is fixed here, at the price the
  /// event has right now.
  ///
  /// Throws [TicketException] when the quantity is out of range or the event
  /// has already started.
  Future<Ticket> purchase({
    required String userId,
    required Event event,
    required int qty,
  });

  /// Cancels an active ticket and returns it with the new status.
  ///
  /// Throws [TicketException] when there is no such ticket or it is no longer
  /// active.
  Future<Ticket> cancel(String ticketId);
}
