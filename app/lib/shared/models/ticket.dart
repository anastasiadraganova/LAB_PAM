/// Lifecycle of a ticket. A cancelled ticket keeps its record and only changes
/// status, so it stays visible in the list.
enum TicketStatus { active, used, cancelled }

/// A purchase of one or more tickets for a single event.
class Ticket {
  const Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.qty,
    required this.totalPrice,
    required this.status,
  });

  final String id;
  final String eventId;
  final String userId;

  /// Number of tickets in the order, from 1 to 10.
  final int qty;

  /// Fixed at the moment of purchase: the event price may change later, the
  /// ticket keeps the terms it was bought on.
  final double totalPrice;

  final TicketStatus status;

  bool get isActive => status == TicketStatus.active;

  /// A ticket never changes anything but its status: the order itself is fixed
  /// at the moment of purchase.
  Ticket copyWith({TicketStatus? status}) => Ticket(
        id: id,
        eventId: eventId,
        userId: userId,
        qty: qty,
        totalPrice: totalPrice,
        status: status ?? this.status,
      );
}
