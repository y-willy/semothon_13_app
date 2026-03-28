import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/project_detail_model.dart';

class ProjectService {
  final String baseUrl;
  final http.Client client;

  ProjectService({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  // =========================
  // 🔥 프로젝트 상세 조회
  // =========================
  Future<ProjectDetailModel> fetchProjectDetail(String projectNumber) async {
    final response = await client.get(
      Uri.parse('$baseUrl/projects/$projectNumber'),
      headers: _headers,
    );

    _throwIfFailed(response, '프로젝트 조회 실패');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ProjectDetailModel.fromJson(data);
  }

  // =========================
  // 👥 팀원
  // =========================

  Future<void> createMember({
    required String projectNumber,
    required String name,
    required String studentId,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/projects/$projectNumber/members'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'studentId': studentId,
      }),
    );

    _throwIfFailed(response, '팀원 추가 실패', allow201: true);
  }

  Future<void> updateMember({
    required String projectNumber,
    required int memberId,
    required String name,
    required String studentId,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/projects/$projectNumber/members/$memberId'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'studentId': studentId,
      }),
    );

    _throwIfFailed(response, '팀원 수정 실패');
  }

  Future<void> deleteMember({
    required String projectNumber,
    required int memberId,
  }) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/projects/$projectNumber/members/$memberId'),
      headers: _headers,
    );

    _throwIfFailed(response, '팀원 삭제 실패', allow204: true);
  }

  // =========================
  // 📅 일정
  // =========================

  Future<void> createSchedule({
    required String projectNumber,
    required String title,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/projects/$projectNumber/schedules'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'date': _dateOnly(date),
        'startTime': _timeToString(startTime),
        'endTime': _timeToString(endTime),
      }),
    );

    _throwIfFailed(response, '일정 추가 실패', allow201: true);
  }

  Future<void> updateSchedule({
    required String projectNumber,
    required int scheduleId,
    required String title,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/projects/$projectNumber/schedules/$scheduleId'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'date': _dateOnly(date),
        'startTime': _timeToString(startTime),
        'endTime': _timeToString(endTime),
      }),
    );

    _throwIfFailed(response, '일정 수정 실패');
  }

  Future<void> deleteSchedule({
    required String projectNumber,
    required int scheduleId,
  }) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/projects/$projectNumber/schedules/$scheduleId'),
      headers: _headers,
    );

    _throwIfFailed(response, '일정 삭제 실패', allow204: true);
  }

  // =========================
  // 🧠 역할 / 업무
  // =========================

  Future<void> createTask({
    required String projectNumber,
    required int roleId,
    required String title,
    required DateTime dueDate,
    required String priority,
    required String source,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/projects/$projectNumber/roles/$roleId/tasks'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority,
        'source': source,
      }),
    );

    _throwIfFailed(response, '업무 추가 실패', allow201: true);
  }

  Future<void> updateTask({
    required String projectNumber,
    required int roleId,
    required int taskId,
    required DateTime dueDate,
    required bool done,
  }) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/projects/$projectNumber/roles/$roleId/tasks/$taskId'),
      headers: _headers,
      body: jsonEncode({
        'dueDate': dueDate.toIso8601String(),
        'done': done,
      }),
    );

    _throwIfFailed(response, '업무 수정 실패');
  }

  Future<void> deleteTask({
    required String projectNumber,
    required int roleId,
    required int taskId,
  }) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/projects/$projectNumber/roles/$roleId/tasks/$taskId'),
      headers: _headers,
    );

    _throwIfFailed(response, '업무 삭제 실패', allow204: true);
  }

  // =========================
  // 💬 채팅
  // =========================

  Future<void> sendChat({
    required String projectNumber,
    required String message,
    required bool isFile,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/projects/$projectNumber/chat-messages'),
      headers: _headers,
      body: jsonEncode({
        'message': message,
        'isFile': isFile,
      }),
    );

    _throwIfFailed(response, '채팅 전송 실패', allow201: true);
  }

  // =========================
  // 🔔 읽음 처리
  // =========================

  Future<void> readAllNotifications(String projectNumber) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/projects/$projectNumber/notifications/read-all'),
      headers: _headers,
    );

    _throwIfFailed(response, '알림 읽음 실패');
  }

  Future<void> readAllChat(String projectNumber) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/projects/$projectNumber/chat-messages/read-all'),
      headers: _headers,
    );

    _throwIfFailed(response, '채팅 읽음 실패');
  }

  // =========================
  // 🔥 공통 에러 처리
  // =========================

  void _throwIfFailed(
    http.Response response,
    String message, {
    bool allow201 = false,
    bool allow204 = false,
  }) {
    final valid = <int>{200};
    if (allow201) valid.add(201);
    if (allow204) valid.add(204);

    if (!valid.contains(response.statusCode)) {
      throw Exception('$message (${response.statusCode})');
    }
  }

  // =========================
  // 🛠 유틸
  // =========================

  static String _dateOnly(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  static String _timeToString(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
  }
}
