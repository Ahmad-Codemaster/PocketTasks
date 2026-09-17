/// Represents a productivity tip fetched from a REST API.
class ProductivityTip {
  final int id;
  final String title;
  final String content;
  final String category;

  const ProductivityTip({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'Focus & Organization',
  });

  /// Factory constructor to map API JSON response (e.g. JSONPlaceholder posts / quotes)
  /// into a structured ProductivityTip.
  factory ProductivityTip.fromJson(Map<String, dynamic> json) {
    return ProductivityTip(
      id: json['id'] as int? ?? 1,
      title: json['title'] as String? ?? 'Daily Productivity Habit',
      content: json['body'] as String? ?? (json['content'] as String? ?? ''),
      category: 'Tip #${json['id'] ?? 1}',
    );
  }
}
