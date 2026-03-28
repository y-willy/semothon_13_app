import 'app_notification_model.dart';
import 'chat_message_model.dart';
import 'member_model.dart';
import 'role_model.dart';
import 'schedule_model.dart';

class ProjectDetailModel {
  final String projectNumber;
  final String projectTitle;
  final String projectGoal;
  final List<MemberModel> members;
  final List<ScheduleModel> schedules;
  final List<RoleModel> roles;
  final List<ChatMessageModel> chatMessages;
  final List<AppNotificationModel> notifications;

  const ProjectDetailModel({
    required this.projectNumber,
    required this.projectTitle,
    required this.projectGoal,
    required this.members,
    required this.schedules,
    required this.roles,
    required this.chatMessages,
    required this.notifications,
  });

  // =========================
  // 🔥 Getter (핵심 추가 부분)
  // =========================

  /// 팀원 수
  int get memberCount => members.length;

  /// 역할 수
  int get roleCount => roles.length;

  /// 일정 수
  int get scheduleCount => schedules.length;

  /// 안읽은 알림 개수
  int get unreadNotificationCount =>
      notifications.where((e) => !e.isRead).length;

  /// 안읽은 채팅 개수 (내가 아닌 메시지 기준)
  int get unreadChatCount =>
      chatMessages.where((e) => !e.isRead && !e.isAi).length;

  /// 프로젝트 상태 요약 (🔥 중요)
  String get summaryStatus {
    int overdueTaskCount = 0;
    int urgentTaskCount = 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    for (final role in roles) {
      for (final task in role.tasks) {
        if (task.done) continue;

        final due = DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
        );

        if (due.isBefore(today)) {
          overdueTaskCount++;
        } else if (due == tomorrow) {
          urgentTaskCount++;
        }
      }
    }

    if (overdueTaskCount > 0) return '기한 지난 업무 $overdueTaskCount개';
    if (urgentTaskCount > 0) return '마감 임박 업무 $urgentTaskCount개';

    final delayedCount = roles.where((role) => role.status == '지연').length;

    if (delayedCount > 0) return '역할 $delayedCount개 지연';

    if (roles.isNotEmpty && roles.every((role) => role.status == '완료')) {
      return '완료';
    }

    if (roles.every((role) => role.tasks.isEmpty)) {
      return '준비 중';
    }

    return '진행 중';
  }

  /// 최근 업데이트 텍스트
  String get updatedText {
    if (notifications.isEmpty) return '최근 업데이트 없음';

    final latest = notifications.first.createdAt;
    final diff = DateTime.now().difference(latest);

    if (diff.inMinutes < 1) return '최근 업데이트 방금';
    if (diff.inHours < 1) return '최근 업데이트 ${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '최근 업데이트 ${diff.inHours}시간 전';
    if (diff.inDays == 1) return '최근 업데이트 어제';

    return '최근 업데이트 ${diff.inDays}일 전';
  }

  // =========================
  // JSON
  // =========================

  factory ProjectDetailModel.fromJson(Map<String, dynamic> json) {
    return ProjectDetailModel(
      projectNumber: json['projectNumber'].toString(),
      projectTitle: json['projectTitle'] as String,
      projectGoal: json['projectGoal'] as String? ?? '',
      members: (json['members'] as List<dynamic>? ?? [])
          .map((e) => MemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      chatMessages: (json['chatMessages'] as List<dynamic>? ?? [])
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      notifications: (json['notifications'] as List<dynamic>? ?? [])
          .map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectNumber': projectNumber,
      'projectTitle': projectTitle,
      'projectGoal': projectGoal,
      'members': members.map((e) => e.toJson()).toList(),
      'schedules': schedules.map((e) => e.toJson()).toList(),
      'roles': roles.map((e) => e.toJson()).toList(),
      'chatMessages': chatMessages.map((e) => e.toJson()).toList(),
      'notifications': notifications.map((e) => e.toJson()).toList(),
    };
  }

  // =========================
  // copyWith
  // =========================

  ProjectDetailModel copyWith({
    String? projectNumber,
    String? projectTitle,
    String? projectGoal,
    List<MemberModel>? members,
    List<ScheduleModel>? schedules,
    List<RoleModel>? roles,
    List<ChatMessageModel>? chatMessages,
    List<AppNotificationModel>? notifications,
  }) {
    return ProjectDetailModel(
      projectNumber: projectNumber ?? this.projectNumber,
      projectTitle: projectTitle ?? this.projectTitle,
      projectGoal: projectGoal ?? this.projectGoal,
      members: members ?? this.members,
      schedules: schedules ?? this.schedules,
      roles: roles ?? this.roles,
      chatMessages: chatMessages ?? this.chatMessages,
      notifications: notifications ?? this.notifications,
    );
  }
}
