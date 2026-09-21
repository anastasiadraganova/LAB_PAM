import '../../../shared/models/event.dart';
import '../../../shared/models/event_category.dart';

/// Hand written listing used until the repositories arrive.
///
/// The set is deliberately uneven: every category is present, one event has
/// already happened, two are free, one title is long enough to run over two
/// lines, and a couple of them start today.
List<Event> get demoEvents => _demoEvents ??= _buildDemoEvents();

List<Event>? _demoEvents;

/// Looks an event up by identifier; a ticket keeps only the reference.
Event? demoEventById(String id) {
  for (final event in demoEvents) {
    if (event.id == id) return event;
  }
  return null;
}

List<Event> _buildDemoEvents() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  DateTime at(int dayOffset, int hour, [int minute = 0]) =>
      today.add(Duration(days: dayOffset, hours: hour, minutes: minute));

  final events = <Event>[
    Event(
      id: 'e1',
      title: 'Ночь гаражного рока',
      category: EventCategory.concert,
      venue: 'Клуб Fabrika',
      dateTime: at(-3, 21),
      price: 250,
      imageUrl: 'https://picsum.photos/seed/eventhub-garage/600/800',
      description: 'Четыре местные группы, одна сцена и никакого расписания '
          'между сетами. Вход со двора, внутри шумно и тесно, так и задумано.',
    ),
    Event(
      id: 'e2',
      title: 'Стендап-вечер в подвале',
      category: EventCategory.standup,
      venue: 'Tap Lab',
      dateTime: at(0, 20),
      price: 150,
      imageUrl: 'https://picsum.photos/seed/eventhub-standup/600/800',
      description: 'Восемь комиков по семь минут каждый, половина материала '
          'обкатывается впервые. Столики занимают заранее, опоздавшие стоят '
          'у бара.',
    ),
    Event(
      id: 'e3',
      title: 'Танцы до рассвета: только винил',
      category: EventCategory.party,
      venue: 'Летняя сцена',
      dateTime: at(0, 23),
      price: 200,
      imageUrl: 'https://picsum.photos/seed/eventhub-vinyl/600/800',
      description: 'Три диджея, две вертушки и ни одного трека с флешки. Фанк, '
          'диско и эстрада семидесятых до первого троллейбуса.',
    ),
    Event(
      id: 'e4',
      title: 'Выставка городской фотографии',
      category: EventCategory.exhibition,
      venue: 'Галерея на Пушкина',
      dateTime: at(1, 12),
      price: 0,
      imageUrl: 'https://picsum.photos/seed/eventhub-photo/600/800',
      description: 'Сорок снимков одного двора, сделанных с одной точки за '
          'двадцать лет. Вход свободный, экскурсия по выставке в шесть вечера.',
    ),
    Event(
      id: 'e5',
      title: 'Фестиваль независимой музыки и уличного театра на набережной',
      category: EventCategory.concert,
      venue: 'Набережная',
      dateTime: at(1, 17, 30),
      price: 300,
      imageUrl: 'https://picsum.photos/seed/eventhub-festival/600/800',
      description: 'Две сцены вдоль воды, между ними ходят на ходулях. '
          'Программа идёт до полуночи, последний блок акустический.',
    ),
    Event(
      id: 'e6',
      title: 'Хакатон городских сервисов',
      category: EventCategory.hackathon,
      venue: 'Тех-парк',
      dateTime: at(2, 9),
      price: 120,
      imageUrl: 'https://picsum.photos/seed/eventhub-hack/600/800',
      description: 'Сорок восемь часов на прототип, который решает одну '
          'конкретную городскую проблему. Команды до пяти человек, кофе и '
          'розетки на месте.',
    ),
    Event(
      id: 'e7',
      title: 'Открытый микрофон',
      category: EventCategory.standup,
      venue: 'Арт-подвал',
      dateTime: at(3, 19, 30),
      price: 90,
      imageUrl: 'https://picsum.photos/seed/eventhub-openmic/600/800',
      description: 'Пять минут на человека, список собирают за полчаса до '
          'начала. Выступить может любой, освистать тоже любой.',
    ),
    Event(
      id: 'e8',
      title: 'Оркестр играет киномузыку',
      category: EventCategory.concert,
      venue: 'Дом печати',
      dateTime: at(4, 19),
      price: 450,
      imageUrl: 'https://picsum.photos/seed/eventhub-symphony/600/800',
      description: 'Партитуры из фильмов, которые все слышали и почти никто не '
          'слушал живьём. Второе отделение с хором.',
    ),
    Event(
      id: 'e9',
      title: 'Вечеринка кассетного бума',
      category: EventCategory.party,
      venue: 'Клуб Fabrika',
      dateTime: at(5, 22),
      price: 180,
      imageUrl: 'https://picsum.photos/seed/eventhub-tape/600/800',
      description: 'Приносите свою кассету, её поставят. Дресс-код не объявлен, '
          'но спортивные костюмы приветствуются.',
    ),
    Event(
      id: 'e10',
      title: 'Ризография: открытая мастерская',
      category: EventCategory.exhibition,
      venue: 'Малая сцена',
      dateTime: at(6, 14),
      price: 0,
      imageUrl: 'https://picsum.photos/seed/eventhub-riso/600/800',
      description: 'Печатный станок работает весь день, можно принести свой '
          'макет и уйти с оттиском. Бумага и краска за счёт мастерской.',
    ),
    Event(
      id: 'e11',
      title: 'Хакатон по картам города',
      category: EventCategory.hackathon,
      venue: 'Тех-парк',
      dateTime: at(8, 10),
      price: 150,
      imageUrl: 'https://picsum.photos/seed/eventhub-maps/600/800',
      description: 'Открытые данные транспорта и один выходной на то, чтобы '
          'сделать из них что-то полезное. Итоги показывают в воскресенье.',
    ),
    Event(
      id: 'e12',
      title: 'Большой концерт на площади',
      category: EventCategory.concert,
      venue: 'Центральная площадь',
      dateTime: at(10, 18),
      price: 350,
      imageUrl: 'https://picsum.photos/seed/eventhub-square/600/800',
      description: 'Хедлайнер выходит в девять, разогрев начинается сразу после '
          'шести. Площадь перекрывают с полудня.',
    ),
    Event(
      id: 'e13',
      title: 'Стендап: сольный час',
      category: EventCategory.standup,
      venue: 'Дом печати',
      dateTime: at(12, 20),
      price: 400,
      imageUrl: 'https://picsum.photos/seed/eventhub-solo/600/800',
      description: 'Час материала, собранного за два года выступлений на '
          'открытых микрофонах. Без разогрева и без антракта.',
    ),
  ];

  events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return List<Event>.unmodifiable(events);
}
