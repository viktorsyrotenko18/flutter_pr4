class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  String category;
  String priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.category,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "isCompleted": isCompleted,
      "createdAt": createdAt.toIso8601String(),
      "category": category,
      "priority": priority,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      isCompleted: json["isCompleted"],
      createdAt: DateTime.parse(json["createdAt"]),
      category: json["category"],
      priority: json["priority"],
    );
  }
}
