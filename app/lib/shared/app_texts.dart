import 'formatters.dart';

/// Interface wording, kept in one place so that it stays exactly as the design
/// document spells it out.
///
/// The name of an action does not change along the way: "Купить билет" leads to
/// "Билет куплен", never to anything more ceremonious.
abstract final class AppTexts {
  static String buyTickets(int qty) =>
      qty == 1 ? 'Купить билет' : 'Купить ${Formatters.tickets(qty)}';

  static String getTickets(int qty) =>
      qty == 1 ? 'Получить билет' : 'Получить ${Formatters.tickets(qty)}';

  /// Purchase action for an event, free events included.
  static String purchaseAction({required bool isFree, required int qty}) =>
      isFree ? getTickets(qty) : buyTickets(qty);

  static const String ticketBought = 'Билет куплен';
  static const String ticketReceived = 'Билет получен';

  static String purchaseResult({required bool isFree}) =>
      isFree ? ticketReceived : ticketBought;

  static const String emptyListing =
      'По этим фильтрам событий нет. Сбросьте фильтры или выберите другую дату.';

  static const String emptyTickets =
      'У вас пока нет билетов. Загляните в афишу — там есть что выбрать.';

  static const String offline =
      'Нет соединения. Показана последняя загруженная афиша.';

  static const String listingError =
      'Не удалось загрузить афишу. Проверьте соединение и повторите.';

  static const String quantityLimit = 'Не больше 10 билетов в одном заказе.';

  /// Persistent hint under the ticket counter.
  static const String quantityHint = 'не больше 10 билетов';

  static const String cancelTicket =
      'Отменить билет? Вернуть его потом не получится.';

  /// Heading of the order summary shown before the purchase goes through.
  static const String checkOrder = 'Проверьте заказ';
  static const String changeQty = 'Изменить количество';

  static const String eventIsPast = 'Событие уже прошло.';

  static const String today = 'сегодня';

  static const String statusActive = 'Активен';
  static const String statusUsed = 'Погашен';
  static const String statusCancelled = 'Отменён';

  static const String sectionListing = 'Афиша';
  static const String sectionTickets = 'Билеты';
  static const String sectionProfile = 'Профиль';

  static const String titleListing = 'Афиша';
  static const String titleMyTickets = 'Мои билеты';
  static const String titleProfile = 'Профиль';
  static const String titlePurchase = 'Покупка';
  static const String titleSignIn = 'Вход';
  static const String titleSignUp = 'Регистрация';

  static const String filterAll = 'Все';
  static const String searchHint = 'Поиск по названию';

  static const String fieldName = 'Имя';
  static const String fieldEmail = 'Почта';
  static const String fieldPassword = 'Пароль';

  static const String signIn = 'Войти';
  static const String signUp = 'Создать аккаунт';
  static const String goToSignUp = 'Создать аккаунт';
  static const String goToSignIn = 'Войти';
  static const String noAccount = 'Нет аккаунта?';
  static const String hasAccount = 'Уже есть аккаунт?';

  static const String signOut = 'Выйти из аккаунта';
  static const String signOutNote = 'Придётся войти заново.';
}
