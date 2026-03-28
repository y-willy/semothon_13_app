import 'package:flutter/material.dart';
import '../models/role_model.dart';
import '../models/chat_model.dart';
import '../models/member_model.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService service;

  ProjectProvider(this.service);

  List<Role> roles = [];
  List<Member> members = [];
  List<ChatMessage> chats = [];

  bool isLoading = false;

  Future<void> loadProject(String projectId) async {
    isLoading = true;
    notifyListeners();

    final data = await service.fetchProjectDetail(projectId);

    roles = data.roles;
    members = data.members;
    chats = data.chatMessages;

    isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String projectId, String text) async {
    await service.createChatMessage(
      projectNumber: projectId,
      message: text,
      isFile: false,
    );

    chats.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      message: text,
      time: "지금",
      isFile: false,
      read: true,
    ));

    notifyListeners();
  }

  Future<void> toggleTask(
      String projectId, int roleId, int taskId, bool done) async {
    await service.toggleTaskDone(
      projectNumber: projectId,
      roleId: roleId,
      taskId: taskId,
      done: done,
    );

    final role = roles.firstWhere((r) => r.id == roleId);
    final task = role.tasks.firstWhere((t) => t.id == taskId);
    task.done = done;

    notifyListeners();
  }
}
