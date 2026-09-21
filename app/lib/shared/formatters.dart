import 'package:intl/intl.dart';

/// Date, time, price and quantity formatting for the Russian interface.
abstract final class Formatters {
  static const String _locale = 'ru';

  /// Currency suffix used next to every amount.
  static const String currency = 'L';

  /// Day number for the date stamp.
  static String stampDay(DateTime date) => DateFormat('d', _locale).format(date);

  /// Short month for the date stamp: "окт", without the abbreviation dot.
  static String stampMonth(DateTime date) =>
      DateFormat('MMM', _locale).format(date).replaceAll('.', '');

  /// Day separator in the listing: "Пятница, 24 октября".
  static String day(DateTime date) =>
      _capitalize(DateFormat('EEEE, d MMMM', _locale).format(date));

  /// Full date with the time, for the event screen: "24 октября, 20:00".
  static String dateAndTime(DateTime date) =>
      DateFormat('d MMMM, HH:mm', _locale).format(date);

  static String time(DateTime date) => DateFormat('HH:mm', _locale).format(date);

  /// Price of one ticket or an order total. A free event is priced in words.
  static String price(double value) {
    if (value == 0) return 'бесплатно';
    return '${_amount(value)} $currency';
  }

  /// The calculation line on the purchase screen: "3 × 150 L".
  static String calculation(int qty, double unitPrice) =>
      '$qty × ${price(unitPrice)}';

  /// Russian plural for "билет": 1 билет, 3 билета, 11 билетов.
  static String tickets(int qty) {
    final withinHundred = qty % 100;
    final withinTen = qty % 10;
    if (withinHundred >= 11 && withinHundred <= 14) return '$qty билетов';
    if (withinTen == 1) return '$qty билет';
    if (withinTen >= 2 && withinTen <= 4) return '$qty билета';
    return '$qty билетов';
  }

  static String _amount(double value) {
    final rounded = value.roundToDouble();
    final text = value == rounded
        ? rounded.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return text;
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
