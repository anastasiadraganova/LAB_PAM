import 'dart:convert';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/local_cache.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/ticket.dart';
import '../domain/tickets_repository.dart';
import 'api_tickets_repository.dart';

/// Offline cache in front of [TicketsRepository]: the last list of each
/// user's tickets stays on the device, so "Мои билеты" opens without a
/// network — a ticket is most needed at the door, where the signal is bad.
/// Buying and cancelling still go to the backend.
class CachedTicketsRepository implements TicketsRepository {
  CachedTicketsRepository(this._remote, this._cache);

  static String keyFor(String userId) => 'cache.tickets.$userId';

  final TicketsRepository _remote;
  final LocalCache _cache;

  @override
  Future<List<Ticket>> fetchTickets(String userId) async {
    try {
      final tickets = await _remote.fetchTickets(userId);
      await _cache.write(
        keyFor(userId),
        jsonEncode([
          for (final t in tickets) ApiTicketsRepository.ticketToJson(t),
        ]),
      );
      return tickets;
    } on ApiException catch (error) {
      if (!error.isNetwork) rethrow;
      final raw = await _cache.read(keyFor(userId));
      if (raw == null) rethrow;
      return [
        for (final item in jsonDecode(raw) as List)
          ApiTicketsRepository.ticketFromJson(item as Map<String, dynamic>),
      ];
    }
  }

  @override
  Future<Ticket> purchase({
    required String userId,
    required Event event,
    required int qty,
  }) => _remote.purchase(userId: userId, event: event, qty: qty);

  @override
  Future<Ticket> cancel(String ticketId) => _remote.cancel(ticketId);
}
