import 'task_model.dart';

class RoleModel {
  final int id;
  final String title;
  final String assignee;
  final String status;
  final List<TaskModel> tasks;

  const RoleModel({
    required this.id,
    required this.title,
    required this.assignee,
    required this.status,
    required this.tasks,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      assignee: json['assignee'] as String? ?? '',
      status: json['status'] as String? ?? '시작 전',
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'assignee': assignee,
      'status': status,
      'tasks': tasks.map((e) => e.toJson()).toList(),
    };
  }

  RoleModel copyWith({
    int? id,
    String? title,
    String? assignee,
    String? status,
    List<TaskModel>? tasks,
  }) {
    return RoleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      assignee: assignee ?? this.assignee,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
    );
  }
}
