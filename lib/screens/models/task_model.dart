class TaskModel {
  final int id;
  final String title;
  final String priority;
  final DateTime dueDate;
  final bool done;
  final String source;

  const TaskModel({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    required this.done,
    required this.source,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      priority: json['priority'] as String? ?? '보통',
      dueDate:
          DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      done: json['done'] as bool? ?? false,
      source: json['source'] as String? ?? '수동',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'done': done,
      'source': source,
    };
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? priority,
    DateTime? dueDate,
    bool? done,
    String? source,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      done: done ?? this.done,
      source: source ?? this.source,
    );
  }
}
