/// Event categories from SPEC.md.
///
/// [value] is what the backend stores and what the card meta line shows;
/// [title] is the label of the filter chip.
enum EventCategory {
  concert('концерт', 'Концерты'),
  standup('стендап', 'Стендап'),
  exhibition('выставка', 'Выставки'),
  hackathon('хакатон', 'Хакатоны'),
  party('вечеринка', 'Вечеринки');

  const EventCategory(this.value, this.title);

  final String value;
  final String title;

  static EventCategory? byValue(String value) {
    for (final category in EventCategory.values) {
      if (category.value == value) return category;
    }
    return null;
  }
}
