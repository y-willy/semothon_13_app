import 'package:flutter/material.dart';

import '../models/app_notification_model.dart';
import '../models/chat_message_model.dart';
import '../models/member_model.dart';
import '../models/project_detail_model.dart';
import '../models/role_model.dart';
import '../models/schedule_model.dart';
import '../models/task_model.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  static const Color kWine = Color(0xFFA31621);
  static const Color kCream = Color(0xFFF6F1F1);
  static const Color kCard = Colors.white;
  static const Color kText = Color(0xFF3A2A2A);
  static const Color kSub = Color(0xFF7D6666);
  static const Color kBorder = Color(0xFFE7C9C9);
  static const Color kSoftCard = Color(0xFFFCFBFB);
  static const Color kInputFill = Color(0xFFF9F1F1);

  late List<ProjectDetailModel> projects = [
    _sampleProject(
      projectNumber: '13',
      title: '세계와 시민',
      memberCount: 4,
      roleCount: 3,
      scheduleCount: 2,
      statusSeed: '진행 중',
    ),
    _sampleProject(
      projectNumber: '12',
      title: '소프트웨어공학',
      memberCount: 5,
      roleCount: 3,
      scheduleCount: 2,
      statusSeed: '마감 임박 업무 2개',
    ),
    _sampleProject(
      projectNumber: '7',
      title: '데이터베이스',
      memberCount: 3,
      roleCount: 2,
      scheduleCount: 1,
      statusSeed: '기한 지난 업무 1개',
    ),
  ];

  static ProjectDetailModel _sampleProject({
    required String projectNumber,
    required String title,
    required int memberCount,
    required int roleCount,
    required int scheduleCount,
    required String statusSeed,
  }) {
    final now = DateTime.now();

    final members = List.generate(
      memberCount,
      (index) => MemberModel(
        id: index + 1,
        name: '팀원 ${index + 1}',
        studentId: '2020${(1000 + index).toString()}',
      ),
    );

    final schedules = List.generate(
      scheduleCount,
      (index) => ScheduleModel(
        id: index + 1,
        title: '일정 ${index + 1}',
        date: now.add(Duration(days: index + 1)),
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 16, minute: 0),
      ),
    );

    List<RoleModel> roles;
    if (statusSeed.contains('기한 지난')) {
      roles = List.generate(
        roleCount,
        (index) => RoleModel(
          id: index + 1,
          title: '역할 ${index + 1}',
          assignee: members[index % members.length].name,
          status: index == 0 ? '지연' : '진행 중',
          tasks: [
            TaskModel(
              id: (index + 1) * 100 + 1,
              title: '업무 ${index + 1}-1',
              priority: '높음',
              dueDate: now.subtract(const Duration(days: 1)),
              done: false,
              source: '수동',
            ),
          ],
        ),
      );
    } else if (statusSeed.contains('마감 임박')) {
      roles = List.generate(
        roleCount,
        (index) => RoleModel(
          id: index + 1,
          title: '역할 ${index + 1}',
          assignee: members[index % members.length].name,
          status: index == 0 ? '마감 임박' : '진행 중',
          tasks: [
            TaskModel(
              id: (index + 1) * 100 + 1,
              title: '업무 ${index + 1}-1',
              priority: '높음',
              dueDate: now.add(const Duration(days: 1)),
              done: false,
              source: '수동',
            ),
          ],
        ),
      );
    } else if (statusSeed.contains('완료')) {
      roles = List.generate(
        roleCount,
        (index) => RoleModel(
          id: index + 1,
          title: '역할 ${index + 1}',
          assignee: members[index % members.length].name,
          status: '완료',
          tasks: [
            TaskModel(
              id: (index + 1) * 100 + 1,
              title: '업무 ${index + 1}-1',
              priority: '보통',
              dueDate: now.subtract(const Duration(days: 2)),
              done: true,
              source: '수동',
            ),
          ],
        ),
      );
    } else if (statusSeed.contains('준비')) {
      roles = List.generate(
        roleCount,
        (index) => RoleModel(
          id: index + 1,
          title: '역할 ${index + 1}',
          assignee: members[index % members.length].name,
          status: '시작 전',
          tasks: const [],
        ),
      );
    } else {
      roles = List.generate(
        roleCount,
        (index) => RoleModel(
          id: index + 1,
          title: '역할 ${index + 1}',
          assignee: members[index % members.length].name,
          status: '진행 중',
          tasks: [
            TaskModel(
              id: (index + 1) * 100 + 1,
              title: '업무 ${index + 1}-1',
              priority: '보통',
              dueDate: now.add(Duration(days: index + 2)),
              done: index == 0,
              source: '수동',
            ),
          ],
        ),
      );
    }

    return ProjectDetailModel(
      projectNumber: projectNumber,
      projectTitle: title,
      projectGoal: '',
      members: members,
      schedules: schedules,
      roles: roles,
      chatMessages: [
        ChatMessageModel(
          id: 1,
          sender: 'AI 코치',
          time: '오후 04:25',
          message: '프로젝트를 시작해보세요. 역할을 정하고 업무를 배분하면 더 편하게 관리할 수 있어요.',
          roleTag: null,
          isAi: true,
          isFile: false,
          isRead: false,
        ),
      ],
      notifications: [
        AppNotificationModel(
          id: 1,
          title: '프로젝트 생성',
          body: '$title 프로젝트가 준비되어 있어요.',
          type: 'project',
          createdAt: now,
          isRead: false,
        ),
      ],
    );
  }

  String _summaryStatus(ProjectDetailModel project) {
    int overdueTaskCount = 0;
    int urgentTaskCount = 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    for (final role in project.roles) {
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

    final delayedCount =
        project.roles.where((role) => role.status == '지연').length;
    if (delayedCount > 0) return '역할 $delayedCount개 지연';

    final completedCount = project.roles.isNotEmpty &&
            project.roles.every((role) => role.status == '완료')
        ? true
        : false;

    if (completedCount) return '완료';
    if (project.roles.every((role) => role.tasks.isEmpty)) return '준비 중';

    return '진행 중';
  }

  Color _statusColor(String status) {
    if (status.contains('기한 지난')) return const Color(0xFFFF6B2C);
    if (status.contains('마감 임박')) return const Color(0xFFFF8A3D);
    if (status.contains('지연')) return const Color(0xFFFF6B2C);
    if (status.contains('완료')) return const Color(0xFF2E9E57);
    if (status.contains('준비')) return const Color(0xFF8B8480);
    return kWine;
  }

  String _updatedText(ProjectDetailModel project) {
    if (project.notifications.isEmpty) return '최근 업데이트 없음';

    final latest = project.notifications.first.createdAt;
    final diff = DateTime.now().difference(latest);

    if (diff.inMinutes < 1) return '최근 업데이트 방금';
    if (diff.inHours < 1) return '최근 업데이트 ${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '최근 업데이트 ${diff.inHours}시간 전';
    if (diff.inDays == 1) return '최근 업데이트 어제';
    return '최근 업데이트 ${diff.inDays}일 전';
  }

  void _showAddProjectDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '새 프로젝트 추가',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _DialogField(
                  controller: titleController,
                  label: '프로젝트 이름',
                  hintText: '예: 운영체제 팀플',
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(color: kBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: kSub,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;

                          setState(() {
                            final nextNumber = '${projects.length + 1}';
                            projects.insert(
                              0,
                              ProjectDetailModel(
                                projectNumber: nextNumber,
                                projectTitle: title,
                                projectGoal: '',
                                members: [
                                  MemberModel(
                                    id: 1,
                                    name: '나',
                                    studentId: '2024000000',
                                  ),
                                ],
                                schedules: const [],
                                roles: const [],
                                chatMessages: [
                                  ChatMessageModel(
                                    id: 1,
                                    sender: 'AI 코치',
                                    time: '오후 04:25',
                                    message:
                                        '프로젝트가 생성되었어요. 이제 팀원, 일정, 역할을 추가해보세요.',
                                    roleTag: null,
                                    isAi: true,
                                    isFile: false,
                                    isRead: false,
                                  ),
                                ],
                                notifications: [
                                  AppNotificationModel(
                                    id: 1,
                                    title: '프로젝트 생성',
                                    body: '$title 프로젝트가 생성되었어요.',
                                    type: 'project',
                                    createdAt: DateTime.now(),
                                    isRead: false,
                                  ),
                                ],
                              ),
                            );
                          });

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kWine,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '추가',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProjectDialog(int index) {
    final controller = TextEditingController(
      text: projects[index].projectTitle,
    );

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '프로젝트 이름 수정',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _DialogField(
                  controller: controller,
                  label: '프로젝트 이름',
                  hintText: '프로젝트 이름을 입력하세요',
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(color: kBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: kSub,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final newTitle = controller.text.trim();
                          if (newTitle.isEmpty) return;

                          setState(() {
                            projects[index] = projects[index].copyWith(
                              projectTitle: newTitle,
                              notifications: [
                                AppNotificationModel(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  title: '프로젝트 수정',
                                  body: '프로젝트 이름이 수정되었어요.',
                                  type: 'project',
                                  createdAt: DateTime.now(),
                                  isRead: false,
                                ),
                                ...projects[index].notifications,
                              ],
                            );
                          });

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kWine,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '저장',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '프로젝트 삭제',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\'${projects[index].projectTitle}\' 프로젝트를 삭제할까요?',
                    style: const TextStyle(
                      fontSize: 15,
                      color: kSub,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(color: kBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: kSub,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            projects.removeAt(index);
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD94A3A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '삭제',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProjectMenu(BuildContext context, int index) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5DDD8),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              _MenuTile(
                icon: Icons.edit_outlined,
                title: '이름 수정',
                onTap: () => Navigator.pop(context, 'edit_name'),
              ),
              _MenuTile(
                icon: Icons.delete_outline,
                title: '삭제',
                textColor: const Color(0xFFD94A3A),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
            ],
          ),
        );
      },
    );

    if (action == 'edit_name') {
      _showEditProjectDialog(index);
    } else if (action == 'delete') {
      _showDeleteDialog(index);
    }
  }

  Widget _buildTopSection(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: kSub,
                ),
                SizedBox(width: 4),
                Text(
                  '홈으로',
                  style: TextStyle(
                    color: kSub,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Text(
          '프로젝트',
          style: TextStyle(
            color: kText,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: kSoftCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAE1E1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        '현재 진행 중인 프로젝트와 상태를 한눈에 확인하고, 필요하면 이름을 바로 수정해보세요.',
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF4B3A3A),
          height: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopSection(context),
                    const SizedBox(height: 18),
                    _buildIntroCard(),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _showAddProjectDialog,
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          '새 프로젝트 추가',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: kWine,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      '✶ 내 프로젝트',
                      style: TextStyle(
                        color: kWine,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    projects.isEmpty
                        ? const _EmptyProjectView()
                        : ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: projects.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final project = projects[index];
                              final summaryStatus = _summaryStatus(project);

                              return _ProjectCard(
                                number: '#${project.projectNumber}',
                                title: project.projectTitle,
                                status: summaryStatus,
                                statusColor: _statusColor(summaryStatus),
                                memberCount: project.members.length,
                                roleCount: project.roles.length,
                                scheduleCount: project.schedules.length,
                                updatedText: _updatedText(project),
                                onTap: () async {
                                  final result =
                                      await Navigator.push<ProjectDetailModel>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProjectDetailScreen(
                                        project: project,
                                      ),
                                    ),
                                  );

                                  if (result != null) {
                                    setState(() {
                                      projects[index] = result;
                                    });
                                  }
                                },
                                onMoreTap: () =>
                                    _showProjectMenu(context, index),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String number;
  final String title;
  final String status;
  final Color statusColor;
  final int memberCount;
  final int roleCount;
  final int scheduleCount;
  final String updatedText;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _ProjectCard({
    required this.number,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.memberCount,
    required this.roleCount,
    required this.scheduleCount,
    required this.updatedText,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _ProjectListScreenState.kSoftCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _ProjectListScreenState.kBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: _ProjectListScreenState.kText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: onMoreTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7EFEF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        size: 18,
                        color: _ProjectListScreenState.kSub,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                number,
                style: const TextStyle(
                  color: _ProjectListScreenState.kSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                updatedText,
                style: const TextStyle(
                  color: _ProjectListScreenState.kSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFF0E8E4), height: 1),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.group_outlined,
                    text: '$memberCount명',
                  ),
                  _InfoChip(
                    icon: Icons.work_outline,
                    text: '역할 $roleCount개',
                  ),
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    text: '일정 $scheduleCount개',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1EE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: _ProjectListScreenState.kSub,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _ProjectListScreenState.kSub,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _ProjectListScreenState.kSub,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFFA58787),
              fontSize: 14,
            ),
            filled: true,
            fillColor: _ProjectListScreenState.kInputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: _ProjectListScreenState.kBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: _ProjectListScreenState.kWine,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? _ProjectListScreenState.kText;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F1EE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyProjectView extends StatelessWidget {
  const _EmptyProjectView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: _ProjectListScreenState.kSoftCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ProjectListScreenState.kBorder),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 50,
            color: _ProjectListScreenState.kSub,
          ),
          SizedBox(height: 14),
          Text(
            '아직 프로젝트가 없습니다',
            style: TextStyle(
              color: _ProjectListScreenState.kText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '상단의 새 프로젝트 버튼으로 시작해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ProjectListScreenState.kSub,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
