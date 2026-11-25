import '../../../shared/app_texts.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/ticket.dart';
import '../../../shared/validation/validators.dart';
import '../domain/tickets_repository.dart';
import 'demo_tickets.dart';

/// [TicketsRepository] that keeps the tickets in memory.
///
/// It starts from the demo tickets and applies the same rules the backend
/// will: 1 to 10 tickets per order, no sales once the event has started, only
/// an active ticket can be cancelled. Changes live until the app is closed.
class MockTicketsRepository implements TicketsRepository {
  MockTicketsRepository({
    this.latency = const Duration(milliseconds: 400),
    List<Ticket>? tickets,
  }) : _tickets = [...(tickets ?? demoTickets)];

  final Duration latency;

  /// Newest order first.
  final List<Ticket> _tickets;

  int _lastId = 0;

  @override
  Future<List<Ticket>> fetchTickets(String userId) async {
    await _wait();
    return List<Ticket>.unmodifiable(
      _tickets.where((ticket) => ticket.userId == userId),
    );
  }

  @override
  Future<Ticket> purchase({
    required String userId,
    required Event event,
    required int qty,
  }) async {
    await _wait();

    final qtyError = Validators.qty(qty);
    if (qtyError != null) throw TicketException(qtyError);
    if (event.isPast()) throw const TicketException(AppTexts.eventIsPast);

    final ticket = Ticket(
      id: _nextId(),
      eventId: event.id,
      userId: userId,
      qty: qty,
      totalPrice: event.price * qty,
      status: TicketStatus.active,
    );
    _tickets.insert(0, ticket);
    return ticket;
  }

  @override
  Future<Ticket> cancel(String ticketId) async {
    await _wait();

    final index = _tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index == -1) throw const TicketException(AppTexts.ticketNotFound);

    final ticket = _tickets[index];
    if (!ticket.isActive) {
      throw const TicketException(AppTexts.ticketNotActive);
    }

    final cancelled = ticket.copyWith(status: TicketStatus.cancelled);
    _tickets[index] = cancelled;
    return cancelled;
  }

  /// Identifiers continue after the demo ones: t5, t6 and so on.
  String _nextId() {
    String id;
    do {
      _lastId++;
      id = 't$_lastId';
    } while (_tickets.any((ticket) => ticket.id == id));
    return id;
  }

  Future<void> _wait() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }
}
