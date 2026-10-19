/// Paths of the application, so that screens never spell them out by hand.
abstract final class AppRoutes {
  static const String auth = '/auth';
  static const String events = '/events';
  static const String myTickets = '/my-tickets';
  static const String profile = '/profile';

  static String event(String id) => '$events/$id';

  static String purchase(String id, {int? qty}) =>
      Uri(path: '$events/$id/buy', queryParameters: {
        if (qty != null) 'qty': '$qty',
      }).toString();
}
