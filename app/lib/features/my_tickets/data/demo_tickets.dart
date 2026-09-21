import '../../../shared/models/ticket.dart';

/// Owner of the demo tickets.
const String demoUserId = 'u1';

/// Hand written tickets covering all three statuses, with one order of several
/// seats so that the quantity line on the card has something to show.
const List<Ticket> demoTickets = <Ticket>[
  Ticket(
    id: 't1',
    eventId: 'e2',
    userId: demoUserId,
    qty: 1,
    totalPrice: 150,
    status: TicketStatus.active,
  ),
  Ticket(
    id: 't2',
    eventId: 'e8',
    userId: demoUserId,
    qty: 3,
    totalPrice: 1350,
    status: TicketStatus.active,
  ),
  Ticket(
    id: 't3',
    eventId: 'e1',
    userId: demoUserId,
    qty: 2,
    totalPrice: 500,
    status: TicketStatus.used,
  ),
  Ticket(
    id: 't4',
    eventId: 'e9',
    userId: demoUserId,
    qty: 1,
    totalPrice: 180,
    status: TicketStatus.cancelled,
  ),
];
