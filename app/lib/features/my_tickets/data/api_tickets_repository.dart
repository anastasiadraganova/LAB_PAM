import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/page_result.dart';
import '../../../shared/models/ticket.dart';
import '../domain/tickets_repository.dart';

/// [TicketsRepository] over the backend: `GET /tickets`, `POST /tickets` and
/// `POST /tickets/{id}/cancel`. The backend knows the user from the token;
/// it also decides the "used" status once the event has started.
class ApiTicketsRepository implements TicketsRepository {
  ApiTicketsRepository(this._api);

  /// A user has a handful of orders: one page holds them all.
  static const int _limit = 100;

  final ApiClient _api;

  @override
  Future<List<Ticket>> fetchTickets(String userId) async {
    final page = PageResult.fromJson(
      await _api.get('/tickets', query: {'page': 1, 'limit': _limit}),
      ticketFromJson,
    );
    return page.items;
  }

  @override
  Future<Ticket> purchase({
    required String userId,
    required Event event,
    required int qty,
  }) => _guard(
    () async => ticketFromJson(
      await _api.post('/tickets', {'eventId': int.parse(event.id), 'qty': qty}),
    ),
  );

  @override
  Future<Ticket> cancel(String ticketId) => _guard(
    () async => ticketFromJson(await _api.post('/tickets/$ticketId/cancel')),
  );

  /// The backend's refusals, in the words the screens already use.
  Future<Ticket> _guard(Future<Ticket> Function() request) async {
    try {
      return await request();
    } on ApiException catch (error) {
      throw TicketException(switch (error) {
        ApiException(isNetwork: true) => AppTexts.networkError,
        ApiException(code: ApiException.notFound) => AppTexts.ticketNotFound,
        ApiException(code: ApiException.validation, :final message)
            when message.contains('started') =>
          AppTexts.eventIsPast,
        ApiException(code: ApiException.validation, :final message)
            when message.contains('active') =>
          AppTexts.ticketNotActive,
        ApiException(code: ApiException.validation, :final message)
            when message.contains('qty') =>
          AppTexts.quantityLimit,
        _ => AppTexts.somethingWrong,
      });
    }
  }

  static Ticket ticketFromJson(Map<String, dynamic> json) => Ticket(
    id: '${json['id']}',
    eventId: '${json['eventId']}',
    userId: '${json['userId']}',
    qty: json['qty'] as int,
    totalPrice: (json['totalPrice'] as num).toDouble(),
    status: switch (json['status']) {
      'used' => TicketStatus.used,
      'cancelled' => TicketStatus.cancelled,
      _ => TicketStatus.active,
    },
  );
}
