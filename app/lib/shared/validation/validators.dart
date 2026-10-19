/// Form rules from the specification, kept free of widgets so that they can be
/// reused by any screen and tested on their own.
///
/// Every validator returns `null` when the value is fine and the message to
/// print under the field otherwise.
abstract final class Validators {
  static const int minQty = 1;
  static const int maxQty = 10;

  /// Minimum password length of the course backend template (ASP.NET Identity
  /// default).
  static const int minPasswordLength = 6;

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  /// Number of tickets in one order: a whole number from 1 to 10.
  static String? qty(int? value) {
    if (value == null) return 'Укажите число билетов.';
    if (value < minQty) return 'Нужен хотя бы один билет.';
    if (value > maxQty) return 'Не больше 10 билетов в одном заказе.';
    return null;
  }

  /// Parses a ticket count that arrives as text, for instance from a link.
  /// Anything that is not a whole number in range is rejected.
  static int? parseQty(String? raw) {
    final value = int.tryParse(raw?.trim() ?? '');
    return value != null && qty(value) == null ? value : null;
  }

  static String? name(String value) {
    if (value.trim().isEmpty) return 'Введите имя.';
    return null;
  }

  static String? email(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Введите почту.';
    if (!_email.hasMatch(email)) return 'Проверьте адрес: например, name@mail.ru.';
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return 'Введите пароль.';
    if (value.length < minPasswordLength) {
      return 'Пароль — не короче $minPasswordLength символов.';
    }
    return null;
  }
}
