class SuggestedTask {
  final String name;
  final String description;
  final String priority;
  final int durationMinutes;

  const SuggestedTask({
    required this.name,
    required this.description,
    required this.priority,
    required this.durationMinutes,
  });

  factory SuggestedTask.fromJson(Map<String, dynamic> json) {
    return SuggestedTask(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'medium',
      durationMinutes: json['duration_minutes'] ?? 60,
    );
  }

  @override
  String toString() {
    return 'SuggestedTask(name: $name, description: $description, priority: $priority, durationMinutes: $durationMinutes)';
  }
}
