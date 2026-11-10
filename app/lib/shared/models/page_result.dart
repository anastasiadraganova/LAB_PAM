/// One page of a list, in the shape every list endpoint of the backend uses:
/// `{items, page, limit, total}`.
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    this.fromCache = false,
  });

  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) parse,
  ) => PageResult(
    items: [
      for (final item in json['items'] as List? ?? const [])
        parse(item as Map<String, dynamic>),
    ],
    page: json['page'] as int? ?? 1,
    limit: json['limit'] as int? ?? 20,
    total: json['total'] as int? ?? 0,
  );

  final List<T> items;
  final int page;
  final int limit;

  /// Size of the whole list, all pages together.
  final int total;

  /// Served from the device because the backend could not be reached.
  final bool fromCache;

  bool get hasMore => page * limit < total;
}
