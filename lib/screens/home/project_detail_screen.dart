import 'package:flutter/material.dart';

String formatDate(DateTime date) {
  return '${date.month}월 ${date.day}일';
}

String formatTimeOfDay(TimeOfDay time) {
  final period = time.hour < 12 ? '오전' : '오후';
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$period $hour:$minute';
}

class ProjectDetailScreen extends StatefulWidget {
  final String projectNumber;
  final String projectTitle;
  final String projectGoal;

  const ProjectDetailScreen({
    super.key,
    required this.projectNumber,
    required this.projectTitle,
    required this.projectGoal,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  static const Color kWine = Color(0xFF8E1F39);
  static const Color kCream = Color(0xFFF4EFEC);
  static const Color kCard = Color(0xFFFFFCFA);
  static const Color kSoft = Color(0xFFF6F0EC);
  static const Color kText = Color(0xFF1F1A1C);
  static const Color kSub = Color(0xFF8B8480);
  static const Color kPurple = Color(0xFFB65AE1);
  static const Color kOrange = Color(0xFFFF6B2C);
  static const Color kGreen = Color(0xFF2E9E57);
  static const Color kBlue = Color(0xFF375CFF);
  static const Color kRedSoft = Color(0xFFFFECE7);

  int selectedTabIndex = 0;
  int? expandedRoleIndex = 0;

  late String projectTitle;
  final TextEditingController chatController = TextEditingController();

  late List<_MemberItem> members = [
    _MemberItem(name: '김민준', studentId: '2020123456'),
    _MemberItem(name: '이서연', studentId: '2020123457'),
    _MemberItem(name: '박지호', studentId: '2020123458'),
  ];

  late List<_ScheduleItem> schedules = [
    _ScheduleItem(
      title: '중간 점검 회의',
      date: DateTime.now().add(const Duration(days: 1)),
      startTime: const TimeOfDay(hour: 14, minute: 0),
      endTime: const TimeOfDay(hour: 16, minute: 0),
    ),
    _ScheduleItem(
      title: '최종 리허설',
      date: DateTime.now().add(const Duration(days: 4)),
      startTime: const TimeOfDay(hour: 15, minute: 0),
      endTime: const TimeOfDay(hour: 17, minute: 0),
    ),
  ];

  late List<_RoleItem> roles = [
    _RoleItem(
      title: '자료조사',
      assignee: '김민준',
      status: '시작 전',
      tasks: [],
    ),
    _RoleItem(
      title: '발표 자료 제작',
      assignee: '이서연',
      status: '시작 전',
      tasks: [],
    ),
    _RoleItem(
      title: '발표자',
      assignee: '박지호',
      status: '시작 전',
      tasks: [],
    ),
  ];

  late List<_ChatMessage> chatMessages = [
    _ChatMessage(
      sender: 'AI 코치',
      time: '오후 04:25',
      message: '역할별 업무를 아직 만들지 않았어요. 역할 탭에서 수동으로 추가하거나 AI 자동생성을 눌러보세요.',
      isAi: true,
      isFile: false,
      isRead: false,
    ),
  ];

  late List<_AppNotification> notifications = [
    _AppNotification(
      title: '새 채팅 알림',
      body: '새로운 진행 상황 메시지가 있어요.',
      type: 'chat',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    _AppNotification(
      title: '업무 완료',
      body: '김민준님이 참고자료 찾기 업무를 완료했어요.',
      type: 'task',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    projectTitle = widget.projectTitle;
    _refreshAllRoleStatuses();
  }

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  Color statusColor(String status) {
    switch (status) {
      case '완료':
        return kGreen;
      case '지연':
        return kOrange;
      case '마감 임박':
        return kOrange;
      case '시작 전':
        return kSub;
      default:
        return kWine;
    }
  }

  int completedTaskCount(_RoleItem role) {
    return role.tasks.where((task) => task.done).length;
  }

  int totalTaskCount(_RoleItem role) {
    return role.tasks.length;
  }

  bool isDueTomorrow(_TaskItem task) {
    if (task.done) return false;
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final due =
        DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    return due == tomorrow;
  }

  bool isOverdue(_TaskItem task) {
    if (task.done) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due =
        DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    return due.isBefore(today);
  }

  int get urgentTaskCount {
    int count = 0;
    for (final role in roles) {
      for (final task in role.tasks) {
        if (isDueTomorrow(task)) count++;
      }
    }
    return count;
  }

  int get overdueTaskCount {
    int count = 0;
    for (final role in roles) {
      for (final task in role.tasks) {
        if (isOverdue(task)) count++;
      }
    }
    return count;
  }

  List<_UrgentTaskView> get urgentTasks {
    final List<_UrgentTaskView> items = [];
    for (final role in roles) {
      for (final task in role.tasks) {
        if (isDueTomorrow(task) || isOverdue(task)) {
          items.add(
            _UrgentTaskView(
              title: task.title,
              assignee: role.assignee,
              priority: task.priority,
              dueDate: task.dueDate,
              isOverdue: isOverdue(task),
            ),
          );
        }
      }
    }
    return items;
  }

  List<_ChatMessage> get fileMessages {
    return chatMessages
        .where((message) => message.isFile)
        .toList()
        .reversed
        .toList();
  }

  int get unreadChatCount {
    return chatMessages
        .where((message) => message.sender != '나' && !message.isRead)
        .length;
  }

  int get unreadNotificationCount {
    return notifications.where((item) => !item.isRead).length;
  }

  String get summaryStatus {
    if (overdueTaskCount > 0) return '기한 지난 업무 $overdueTaskCount개';
    if (urgentTaskCount > 0) return '마감 임박 업무 $urgentTaskCount개';
    final delayedCount = roles.where((role) => role.status == '지연').length;
    if (delayedCount > 0) return '역할 $delayedCount개 지연';
    return '전체 흐름 안정적';
  }

  void _refreshRoleStatus(int roleIndex) {
    final role = roles[roleIndex];
    final completed = completedTaskCount(role);
    final total = totalTaskCount(role);

    final hasOverdue = role.tasks.any(isOverdue);
    final hasUrgent = role.tasks.any(isDueTomorrow);

    if (hasOverdue) {
      role.status = '지연';
      return;
    }
    if (completed == total && total > 0) {
      role.status = '완료';
      return;
    }
    if (hasUrgent && completed < total) {
      role.status = '마감 임박';
      return;
    }
    if (completed == 0 && total > 0) {
      role.status = '시작 전';
      return;
    }
    if (completed > 0 && completed < total) {
      role.status = '진행 중';
      return;
    }
    role.status = '시작 전';
  }

  void _refreshAllRoleStatuses() {
    for (int i = 0; i < roles.length; i++) {
      _refreshRoleStatus(i);
    }
  }

  void _markAllChatAsRead() {
    for (final message in chatMessages) {
      if (message.sender != '나') {
        message.isRead = true;
      }
    }
  }

  void _markAllNotificationsAsRead() {
    for (final item in notifications) {
      item.isRead = true;
    }
  }

  void toggleTask(int roleIndex, int taskIndex) {
    final role = roles[roleIndex];
    final task = role.tasks[taskIndex];
    final wasDone = task.done;

    setState(() {
      task.done = !task.done;
      _refreshRoleStatus(roleIndex);

      if (!wasDone && task.done) {
        notifications.insert(
          0,
          _AppNotification(
            title: '업무 완료',
            body: '${role.assignee}님이 ${task.title} 업무를 완료했어요.',
            type: 'task',
            createdAt: DateTime.now(),
            isRead: false,
          ),
        );
      }
    });
  }

  void deleteTask(int roleIndex, int taskIndex) {
    final role = roles[roleIndex];
    final removedTaskTitle = role.tasks[taskIndex].title;

    setState(() {
      role.tasks.removeAt(taskIndex);
      _refreshRoleStatus(roleIndex);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$removedTaskTitle 업무를 삭제했어요.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void sendChatMessage() {
    final text = chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      chatMessages.add(
        _ChatMessage(
          sender: '나',
          time: _fakeNowText(),
          message: text,
          roleTag: null,
          isAi: false,
          isFile: false,
          isRead: true,
        ),
      );

      notifications.insert(
        0,
        _AppNotification(
          title: '새 채팅 알림',
          body: '새로운 진행 상황 메시지가 추가되었어요.',
          type: 'chat',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      );

      chatController.clear();
    });
  }

  String _fakeNowText() {
    final now = TimeOfDay.now();
    final period = now.hour < 12 ? '오전' : '오후';
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    return '$period $hour:$minute';
  }

  void _addAttachmentMessage(String message) {
    setState(() {
      chatMessages.add(
        _ChatMessage(
          sender: '나',
          time: _fakeNowText(),
          message: message,
          roleTag: null,
          isAi: false,
          isFile: true,
          isRead: true,
        ),
      );

      notifications.insert(
        0,
        _AppNotification(
          title: '새 채팅 알림',
          body: '새로운 파일이 공유되었어요.',
          type: 'chat',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      );
    });
  }

  String fileTypeLabel(String message) {
    final firstLine = message.split('\n').first.toLowerCase();

    if (firstLine.startsWith('http://') || firstLine.startsWith('https://')) {
      return '링크';
    }

    if (firstLine.endsWith('.jpg') ||
        firstLine.endsWith('.jpeg') ||
        firstLine.endsWith('.png') ||
        firstLine.endsWith('.gif') ||
        firstLine.endsWith('.mp4') ||
        firstLine.endsWith('.mov')) {
      return '사진/동영상';
    }

    return '파일';
  }

  IconData fileTypeIcon(String message) {
    final type = fileTypeLabel(message);
    if (type == '사진/동영상') return Icons.photo_library_rounded;
    if (type == '링크') return Icons.link_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color fileTypeColor(String message) {
    final type = fileTypeLabel(message);
    if (type == '사진/동영상') return const Color(0xFF16A34A);
    if (type == '링크') return const Color(0xFF2F80ED);
    return const Color(0xFF6B7280);
  }

  Future<void> showAddMemberSheet() async {
    final nameController = TextEditingController();
    final studentIdController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '팀원 추가',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _DialogField(
                  controller: nameController,
                  label: '이름',
                  hintText: '팀원 이름을 입력하세요',
                ),
                const SizedBox(height: 14),
                _DialogField(
                  controller: studentIdController,
                  label: '학번',
                  hintText: '학번을 입력하세요',
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          side: const BorderSide(color: Color(0xFFE4D9D4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: kSub,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final studentId = studentIdController.text.trim();
                          if (name.isEmpty || studentId.isEmpty) return;

                          setState(() {
                            members.add(
                              _MemberItem(name: name, studentId: studentId),
                            );
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kWine,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '추가',
                          style: TextStyle(fontWeight: FontWeight.w800),
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

  Future<void> showAddScheduleSheet() async {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay startTime = const TimeOfDay(hour: 14, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 16, minute: 0);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _SheetHandle(),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '일정 추가',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: kText,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _DialogField(
                      controller: titleController,
                      label: '제목',
                      hintText: '예: 중간 점검 회의',
                    ),
                    const SizedBox(height: 14),
                    _DateSelectField(
                      label: '날짜',
                      text: formatDate(selectedDate),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setInnerState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeSelectField(
                            label: '시작 시간',
                            text: formatTimeOfDay(startTime),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: startTime,
                              );
                              if (picked != null) {
                                setInnerState(() {
                                  startTime = picked;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimeSelectField(
                            label: '종료 시간',
                            text: formatTimeOfDay(endTime),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: endTime,
                              );
                              if (picked != null) {
                                setInnerState(() {
                                  endTime = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              side: const BorderSide(color: Color(0xFFE4D9D4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                color: kSub,
                                fontWeight: FontWeight.w800,
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
                                schedules.add(
                                  _ScheduleItem(
                                    title: title,
                                    date: selectedDate,
                                    startTime: startTime,
                                    endTime: endTime,
                                  ),
                                );
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kWine,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              '추가',
                              style: TextStyle(fontWeight: FontWeight.w800),
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
      },
    );
  }

  Future<void> showAddTaskDialog(int roleIndex) async {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '업무 추가',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _DialogField(
                      controller: titleController,
                      label: '업무 내용',
                      hintText: '예: 발표 대본 초안 작성',
                    ),
                    const SizedBox(height: 14),
                    _DateSelectField(
                      label: '마감기한',
                      text: formatDate(selectedDate),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setInnerState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              side: const BorderSide(color: Color(0xFFE4D9D4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                color: kSub,
                                fontWeight: FontWeight.w800,
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
                                roles[roleIndex].tasks.add(
                                      _TaskItem(
                                        title: title,
                                        priority: '보통',
                                        dueDate: selectedDate,
                                        done: false,
                                        source: '수동',
                                      ),
                                    );
                                _refreshRoleStatus(roleIndex);
                              });

                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kWine,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              '추가',
                              style: TextStyle(fontWeight: FontWeight.w800),
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
      },
    );
  }

  Future<void> showEditTaskDeadlineDialog(int roleIndex, int taskIndex) async {
    DateTime selectedDate = roles[roleIndex].tasks[taskIndex].dueDate;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '마감기한 수정',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        roles[roleIndex].tasks[taskIndex].title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kSub,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DateSelectField(
                      label: '마감기한',
                      text: formatDate(selectedDate),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setInnerState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              side: const BorderSide(color: Color(0xFFE4D9D4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                color: kSub,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                roles[roleIndex].tasks[taskIndex].dueDate =
                                    selectedDate;
                                _refreshRoleStatus(roleIndex);
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kWine,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              '저장',
                              style: TextStyle(fontWeight: FontWeight.w800),
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
      },
    );
  }

  void autoGenerateTasks(int roleIndex) {
    final role = roles[roleIndex];
    final generated = _aiRecommendedTasks(role.title);

    setState(() {
      role.tasks = generated;
      _refreshRoleStatus(roleIndex);
    });
  }

  List<_TaskItem> _aiRecommendedTasks(String roleTitle) {
    final now = DateTime.now();

    if (roleTitle.contains('자료')) {
      return [
        _TaskItem(
          title: '참고자료 찾기',
          priority: '높음',
          dueDate: now.add(const Duration(days: 1)),
          done: false,
          source: 'AI',
        ),
        _TaskItem(
          title: '논문 요약',
          priority: '보통',
          dueDate: now.add(const Duration(days: 2)),
          done: false,
          source: 'AI',
        ),
        _TaskItem(
          title: '출처 정리',
          priority: '보통',
          dueDate: now.add(const Duration(days: 3)),
          done: false,
          source: 'AI',
        ),
      ];
    }

    if (roleTitle.contains('발표 자료')) {
      return [
        _TaskItem(
          title: '슬라이드 초안 작성',
          priority: '높음',
          dueDate: now.add(const Duration(days: 1)),
          done: false,
          source: 'AI',
        ),
        _TaskItem(
          title: '디자인 정리',
          priority: '높음',
          dueDate: now.add(const Duration(days: 2)),
          done: false,
          source: 'AI',
        ),
        _TaskItem(
          title: '최종 수정 반영',
          priority: '보통',
          dueDate: now.add(const Duration(days: 3)),
          done: false,
          source: 'AI',
        ),
      ];
    }

    if (roleTitle.contains('발표')) {
      return [
        _TaskItem(
          title: '발표 대본 준비',
          priority: '높음',
          dueDate: now.add(const Duration(days: 1)),
          done: false,
          source: 'AI',
        ),
        _TaskItem(
          title: '1차 리허설',
          priority: '높음',
          dueDate: now.add(const Duration(days: 2)),
          done: false,
          source: 'AI',
        ),
        _TaskItem(
          title: '예상 질문 정리',
          priority: '보통',
          dueDate: now.add(const Duration(days: 3)),
          done: false,
          source: 'AI',
        ),
      ];
    }

    return [
      _TaskItem(
        title: '$roleTitle 관련 초안 작성',
        priority: '보통',
        dueDate: now.add(const Duration(days: 1)),
        done: false,
        source: 'AI',
      ),
      _TaskItem(
        title: '$roleTitle 관련 검토',
        priority: '보통',
        dueDate: now.add(const Duration(days: 2)),
        done: false,
        source: 'AI',
      ),
    ];
  }

  void showAttachmentOptions() {
    showModalBottomSheet(
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
              const _SheetHandle(),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '첨부 방식 선택',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _AttachOptionTile(
                icon: Icons.photo_library_outlined,
                title: '사진 보관함',
                onTap: () {
                  Navigator.pop(context);
                  _addAttachmentMessage('progress_photo.jpg\n사진을 업로드했습니다.');
                },
              ),
              _AttachOptionTile(
                icon: Icons.camera_alt_outlined,
                title: '카메라',
                onTap: () {
                  Navigator.pop(context);
                  _addAttachmentMessage('captured_image.jpg\n사진을 촬영해 업로드했습니다.');
                },
              ),
              _AttachOptionTile(
                icon: Icons.insert_drive_file_outlined,
                title: '파일',
                onTap: () {
                  Navigator.pop(context);
                  _addAttachmentMessage('project_note.pdf\n파일을 업로드했습니다.');
                },
              ),
              _AttachOptionTile(
                icon: Icons.link_outlined,
                title: '링크',
                onTap: () {
                  Navigator.pop(context);
                  _addAttachmentMessage('https://example.com\n링크를 공유했습니다.');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showUrgentTasksSheet() {
    final items = urgentTasks;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const _SheetHandle(),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '마감 임박 업무',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: kText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6EE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD4B2)),
                ),
                child: Text(
                  items.isEmpty
                      ? '현재 마감 임박 또는 지연 업무가 없습니다.'
                      : '확인이 필요한 업무 ${items.length}개가 있습니다.',
                  style: const TextStyle(
                    color: kOrange,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          '표시할 업무가 없습니다.',
                          style: TextStyle(
                            color: kSub,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = items[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: task.isOverdue
                                    ? const Color(0xFFFFB6A1)
                                    : const Color(0xFFFFC49E),
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 4,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: kOrange,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          color: kText,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '담당자: ${task.assignee}',
                                        style: const TextStyle(
                                          color: kSub,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        task.isOverdue ? '기한 지남' : '마감 임박',
                                        style: const TextStyle(
                                          color: kOrange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      task.priority,
                                      style: const TextStyle(
                                        color: kOrange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatDate(task.dueDate),
                                      style: const TextStyle(
                                        color: kSub,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showNotificationSheet() {
    setState(() {
      _markAllNotificationsAsRead();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.62,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const _SheetHandle(),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '알림',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: kText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: notifications.isEmpty
                    ? const Center(
                        child: Text(
                          '표시할 알림이 없어요.',
                          style: TextStyle(
                            color: kSub,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: item.isRead
                                  ? const Color(0xFFF8F3F0)
                                  : const Color(0xFFFFF3EE),
                              borderRadius: BorderRadius.circular(18),
                              border: item.isRead
                                  ? null
                                  : Border.all(
                                      color: const Color(0xFFFFD6C7),
                                    ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  item.type == 'task'
                                      ? Icons.task_alt_rounded
                                      : Icons.chat_bubble_outline_rounded,
                                  color: item.type == 'task' ? kGreen : kWine,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          color: kText,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.body,
                                        style: const TextStyle(
                                          color: kSub,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!item.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showFileOnlySheet() {
    final files = fileMessages;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.68,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const _SheetHandle(),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '공유된 파일',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: kText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: files.isEmpty
                    ? const Center(
                        child: Text(
                          '공유된 파일이 없어요.',
                          style: TextStyle(
                            color: kSub,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: files.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final file = files[index];
                          final firstLine = file.message.split('\n').first;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F3F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: fileTypeColor(file.message)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    fileTypeIcon(file.message),
                                    color: fileTypeColor(file.message),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fileTypeLabel(file.message),
                                        style: TextStyle(
                                          color: fileTypeColor(file.message),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        firstLine,
                                        style: const TextStyle(
                                          color: kText,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        file.time,
                                        style: const TextStyle(
                                          color: kSub,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return _OverviewTab(
          members: members,
          schedules: schedules,
          summaryStatus: summaryStatus,
          urgentTaskCount: urgentTaskCount,
          overdueTaskCount: overdueTaskCount,
          onAddMember: showAddMemberSheet,
          onAddSchedule: showAddScheduleSheet,
        );
      case 1:
        return _RolesTab(
          roles: roles,
          expandedRoleIndex: expandedRoleIndex,
          onRoleTap: (index) {
            setState(() {
              expandedRoleIndex = expandedRoleIndex == index ? null : index;
            });
          },
          onTaskToggle: toggleTask,
          onAddTask: showAddTaskDialog,
          onEditDeadline: showEditTaskDeadlineDialog,
          onAutoGenerate: autoGenerateTasks,
          onDeleteTask: deleteTask,
          statusColor: statusColor,
          completedTaskCount: completedTaskCount,
          totalTaskCount: totalTaskCount,
          isDueTomorrow: isDueTomorrow,
          isOverdue: isOverdue,
        );
      case 2:
        return _ChatTab(
          messages: chatMessages,
          controller: chatController,
          onAttachTap: showAttachmentOptions,
          onSendTap: sendChatMessage,
          onFileOnlyTap: showFileOnlySheet,
        );
      case 3:
        return _StatusTab(
          roles: roles,
          summaryStatus: summaryStatus,
          urgentTaskCount: urgentTaskCount,
          overdueTaskCount: overdueTaskCount,
          statusColor: statusColor,
          completedTaskCount: completedTaskCount,
          totalTaskCount: totalTaskCount,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderSection(
              projectTitle: projectTitle,
              summaryStatus: summaryStatus,
              onBack: () => Navigator.pop(context),
              onBellTap: showNotificationSheet,
              statusColor: statusColor(summaryStatus),
              onStatusTap: showUrgentTasksSheet,
              unreadNotificationCount: unreadNotificationCount,
            ),
            _TopTabBar(
              selectedIndex: selectedTabIndex,
              unreadChatCount: unreadChatCount,
              onChanged: (index) {
                setState(() {
                  selectedTabIndex = index;
                  if (index == 2) {
                    _markAllChatAsRead();
                  }
                });
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                child: buildTabContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final String projectTitle;
  final String summaryStatus;
  final VoidCallback onBack;
  final VoidCallback onBellTap;
  final VoidCallback onStatusTap;
  final Color statusColor;
  final int unreadNotificationCount;

  const _HeaderSection({
    required this.projectTitle,
    required this.summaryStatus,
    required this.onBack,
    required this.onBellTap,
    required this.onStatusTap,
    required this.statusColor,
    required this.unreadNotificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _ProjectDetailScreenState.kWine,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '프로젝트 목록으로',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onBellTap,
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      if (unreadNotificationCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _ProjectDetailScreenState.kWine,
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              unreadNotificationCount > 9
                                  ? '9+'
                                  : '$unreadNotificationCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            projectTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: onStatusTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                summaryStatus,
                style: TextStyle(
                  color: statusColor == _ProjectDetailScreenState.kOrange
                      ? const Color(0xFFFFE1D3)
                      : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTabBar extends StatelessWidget {
  final int selectedIndex;
  final int unreadChatCount;
  final ValueChanged<int> onChanged;

  const _TopTabBar({
    required this.selectedIndex,
    required this.unreadChatCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Icons.info_outline, '개요'),
      (Icons.group_outlined, '역할'),
      (Icons.chat_bubble_outline, '채팅'),
      (Icons.bar_chart_outlined, '현황'),
    ];

    return Container(
      color: Colors.white.withOpacity(0.82),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(tabs.length, (index) {
          final selected = selectedIndex == index;
          final item = tabs[index];
          final isChatTab = index == 2;

          return GestureDetector(
            onTap: () => onChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFF6EFEC) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        item.$1,
                        size: 18,
                        color: selected
                            ? _ProjectDetailScreenState.kText
                            : _ProjectDetailScreenState.kSub,
                      ),
                      if (isChatTab && unreadChatCount > 0)
                        Positioned(
                          right: -10,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              unreadChatCount > 9 ? '9+' : '$unreadChatCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.$2,
                    style: TextStyle(
                      color: selected
                          ? _ProjectDetailScreenState.kText
                          : _ProjectDetailScreenState.kSub,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final List<_MemberItem> members;
  final List<_ScheduleItem> schedules;
  final String summaryStatus;
  final int urgentTaskCount;
  final int overdueTaskCount;
  final VoidCallback onAddMember;
  final VoidCallback onAddSchedule;

  const _OverviewTab({
    required this.members,
    required this.schedules,
    required this.summaryStatus,
    required this.urgentTaskCount,
    required this.overdueTaskCount,
    required this.onAddMember,
    required this.onAddSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AiCoachCard(
          summaryStatus: summaryStatus,
          urgentTaskCount: urgentTaskCount,
          overdueTaskCount: overdueTaskCount,
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '팀원',
          icon: Icons.group_outlined,
          buttonText: '+ 추가',
          onButtonTap: onAddMember,
          child: Column(
            children: members.map((member) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SimpleListTile(
                  title: member.name,
                  subtitle: member.studentId,
                  leadingText: member.name.characters.first,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '일정',
          icon: Icons.calendar_today_outlined,
          buttonText: '+ 추가',
          onButtonTap: onAddSchedule,
          child: Column(
            children: schedules.map((schedule) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SimpleListTile(
                  title: schedule.title,
                  subtitle:
                      '${formatDate(schedule.date)} · ${formatTimeOfDay(schedule.startTime)} - ${formatTimeOfDay(schedule.endTime)}',
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RolesTab extends StatelessWidget {
  final List<_RoleItem> roles;
  final int? expandedRoleIndex;
  final void Function(int) onRoleTap;
  final void Function(int, int) onTaskToggle;
  final Future<void> Function(int) onAddTask;
  final Future<void> Function(int, int) onEditDeadline;
  final void Function(int) onAutoGenerate;
  final void Function(int, int) onDeleteTask;
  final Color Function(String) statusColor;
  final int Function(_RoleItem) completedTaskCount;
  final int Function(_RoleItem) totalTaskCount;
  final bool Function(_TaskItem) isDueTomorrow;
  final bool Function(_TaskItem) isOverdue;

  const _RolesTab({
    required this.roles,
    required this.expandedRoleIndex,
    required this.onRoleTap,
    required this.onTaskToggle,
    required this.onAddTask,
    required this.onEditDeadline,
    required this.onAutoGenerate,
    required this.onDeleteTask,
    required this.statusColor,
    required this.completedTaskCount,
    required this.totalTaskCount,
    required this.isDueTomorrow,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '역할 분담',
          style: TextStyle(
            color: _ProjectDetailScreenState.kText,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '누가 어떤 업무를 맡았는지 한눈에 보고, 업무를 추가하거나 수정할 수 있어요',
          style: TextStyle(
            color: _ProjectDetailScreenState.kSub,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(roles.length, (index) {
          final role = roles[index];
          final expanded = expandedRoleIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _ProjectDetailScreenState.kCard,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => onRoleTap(index),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                role.title,
                                style: const TextStyle(
                                  color: _ProjectDetailScreenState.kText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  role.status == '지연'
                                      ? Icons.error_outline
                                      : Icons.schedule_outlined,
                                  size: 18,
                                  color: statusColor(role.status),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  role.status,
                                  style: TextStyle(
                                    color: statusColor(role.status),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F3F0),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${role.assignee}의 업무',
                              style: const TextStyle(
                                color: _ProjectDetailScreenState.kText,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F1EE),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '업무 ${completedTaskCount(role)}/${totalTaskCount(role)} 완료',
                                style: const TextStyle(
                                  color: _ProjectDetailScreenState.kSub,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: expanded
                                    ? _ProjectDetailScreenState.kWine
                                        .withOpacity(0.10)
                                    : const Color(0xFFF7F1EE),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                expanded ? '업무 접기' : '업무 보기',
                                style: TextStyle(
                                  color: expanded
                                      ? _ProjectDetailScreenState.kWine
                                      : _ProjectDetailScreenState.kSub,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (expanded) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: const Color(0xFFF0E8E4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '${role.assignee}의 업무 리스트',
                          style: const TextStyle(
                            color: _ProjectDetailScreenState.kText,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => onAddTask(index),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            side: const BorderSide(color: Color(0xFFE4D9D4)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '+ 수동 추가',
                            style: TextStyle(
                              color: _ProjectDetailScreenState.kSub,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => onAutoGenerate(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _ProjectDetailScreenState.kWine,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'AI 자동생성',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (role.tasks.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F3F0),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          '${role.assignee}에게 아직 배정된 업무가 없습니다. 수동으로 추가하거나 AI 자동생성을 눌러보세요.',
                          style: const TextStyle(
                            color: _ProjectDetailScreenState.kSub,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      ...List.generate(role.tasks.length, (taskIndex) {
                        final task = role.tasks[taskIndex];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: ValueKey(
                                '${role.title}_${task.title}_$taskIndex'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('업무 삭제'),
                                        content: const Text('이 업무를 삭제할까요?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('취소'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('삭제'),
                                          ),
                                        ],
                                      );
                                    },
                                  ) ??
                                  false;
                            },
                            onDismissed: (_) => onDeleteTask(index, taskIndex),
                            child: _TaskTile(
                              task: task,
                              onTap: () => onTaskToggle(index, taskIndex),
                              onEditDeadline: () =>
                                  onEditDeadline(index, taskIndex),
                              isDueTomorrow: isDueTomorrow(task),
                              isOverdue: isOverdue(task),
                            ),
                          ),
                        );
                      }),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ChatTab extends StatelessWidget {
  final List<_ChatMessage> messages;
  final TextEditingController controller;
  final VoidCallback onAttachTap;
  final VoidCallback onSendTap;
  final VoidCallback onFileOnlyTap;

  const _ChatTab({
    required this.messages,
    required this.controller,
    required this.onAttachTap,
    required this.onSendTap,
    required this.onFileOnlyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '진행상황 공유',
                style: TextStyle(
                  color: _ProjectDetailScreenState.kText,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            InkWell(
              onTap: onFileOnlyTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3ECE8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.folder_open_rounded,
                  color: _ProjectDetailScreenState.kWine,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          '작업 내용과 파일을 공유하세요',
          style: TextStyle(
            color: _ProjectDetailScreenState.kSub,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _ProjectDetailScreenState.kCard,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              ...messages.map((message) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ChatBubble(message: message),
                );
              }),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F3F0),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onAttachTap,
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: _ProjectDetailScreenState.kSub,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: '진행 상황을 공유하세요...',
                          hintStyle: TextStyle(
                            color: _ProjectDetailScreenState.kSub,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onSendTap,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: _ProjectDetailScreenState.kWine,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusTab extends StatelessWidget {
  final List<_RoleItem> roles;
  final String summaryStatus;
  final int urgentTaskCount;
  final int overdueTaskCount;
  final Color Function(String) statusColor;
  final int Function(_RoleItem) completedTaskCount;
  final int Function(_RoleItem) totalTaskCount;

  const _StatusTab({
    required this.roles,
    required this.summaryStatus,
    required this.urgentTaskCount,
    required this.overdueTaskCount,
    required this.statusColor,
    required this.completedTaskCount,
    required this.totalTaskCount,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = roles.where((role) => role.status == '완료').length;
    final delayedCount = roles.where((role) => role.status == '지연').length;
    final workingCount = roles.where((role) => role.status == '진행 중').length;
    final urgentCount = roles.where((role) => role.status == '마감 임박').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AiCoachCard(
          summaryStatus: summaryStatus,
          urgentTaskCount: urgentTaskCount,
          overdueTaskCount: overdueTaskCount,
        ),
        const SizedBox(height: 16),
        const Text(
          '진행 현황',
          style: TextStyle(
            color: _ProjectDetailScreenState.kText,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '각 역할별 진행 상태를 확인하세요',
          style: TextStyle(
            color: _ProjectDetailScreenState.kSub,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _ProjectDetailScreenState.kCard,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _StatusCountRow(title: '진행 중 역할', value: '$workingCount개'),
              const SizedBox(height: 10),
              _StatusCountRow(title: '마감 임박 역할', value: '$urgentCount개'),
              const SizedBox(height: 10),
              _StatusCountRow(title: '지연 역할', value: '$delayedCount개'),
              const SizedBox(height: 10),
              _StatusCountRow(title: '완료 역할', value: '$completedCount개'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...roles.map((role) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _ProjectDetailScreenState.kCard,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role.title,
                          style: const TextStyle(
                            color: _ProjectDetailScreenState.kText,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          role.assignee,
                          style: const TextStyle(
                            color: _ProjectDetailScreenState.kSub,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '업무 ${completedTaskCount(role)}/${totalTaskCount(role)} 완료',
                          style: const TextStyle(
                            color: _ProjectDetailScreenState.kSub,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor(role.status).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      role.status,
                      style: TextStyle(
                        color: statusColor(role.status),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _AiCoachCard extends StatelessWidget {
  final String summaryStatus;
  final int urgentTaskCount;
  final int overdueTaskCount;

  const _AiCoachCard({
    required this.summaryStatus,
    required this.urgentTaskCount,
    required this.overdueTaskCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F1FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _ProjectDetailScreenState.kPurple,
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'AI 코치 분석',
                style: TextStyle(
                  color: Color(0xFF5A2B7A),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AiHintBox(
            backgroundColor: const Color(0xFFEFF4FF),
            textColor: _ProjectDetailScreenState.kBlue,
            text: '현재 상태: $summaryStatus',
          ),
          if (overdueTaskCount > 0) ...[
            const SizedBox(height: 10),
            _AiHintBox(
              backgroundColor: const Color(0xFFFFEDE8),
              textColor: _ProjectDetailScreenState.kOrange,
              text: '기한이 지난 미완료 업무가 $overdueTaskCount개 있어요. 가장 먼저 확인하세요.',
            ),
          ],
          if (urgentTaskCount > 0) ...[
            const SizedBox(height: 10),
            _AiHintBox(
              backgroundColor: _ProjectDetailScreenState.kRedSoft,
              textColor: _ProjectDetailScreenState.kOrange,
              text: '마감 하루 전인데 아직 완료되지 않은 업무가 $urgentTaskCount개 있어요.',
            ),
          ],
          if (urgentTaskCount == 0 && overdueTaskCount == 0) ...[
            const SizedBox(height: 10),
            const _AiHintBox(
              backgroundColor: Color(0xFFEFFAEA),
              textColor: _ProjectDetailScreenState.kGreen,
              text: '현재 급한 마감 경고는 없어요. 지금 흐름을 유지하면 됩니다.',
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String buttonText;
  final VoidCallback onButtonTap;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.buttonText,
    required this.onButtonTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ProjectDetailScreenState.kCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: _ProjectDetailScreenState.kText, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: _ProjectDetailScreenState.kText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onButtonTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: _ProjectDetailScreenState.kSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: _ProjectDetailScreenState.kText,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SimpleListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? leadingText;

  const _SimpleListTile({
    required this.title,
    required this.subtitle,
    this.leadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3F0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          if (leadingText != null)
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF1E8E5),
                shape: BoxShape.circle,
              ),
              child: Text(
                leadingText!,
                style: const TextStyle(
                  color: _ProjectDetailScreenState.kText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          if (leadingText != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ProjectDetailScreenState.kText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _ProjectDetailScreenState.kSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final _TaskItem task;
  final VoidCallback onTap;
  final VoidCallback onEditDeadline;
  final bool isDueTomorrow;
  final bool isOverdue;

  const _TaskTile({
    required this.task,
    required this.onTap,
    required this.onEditDeadline,
    required this.isDueTomorrow,
    required this.isOverdue,
  });

  Color priorityColor(String priority) {
    if (priority == '높음') return _ProjectDetailScreenState.kOrange;
    return _ProjectDetailScreenState.kWine;
  }

  @override
  Widget build(BuildContext context) {
    final hasAlert = isDueTomorrow || isOverdue;

    return Container(
      decoration: BoxDecoration(
        color: hasAlert ? const Color(0xFFFFF1EC) : const Color(0xFFF8F3F0),
        borderRadius: BorderRadius.circular(18),
        border: hasAlert ? Border.all(color: const Color(0xFFFFD2C1)) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                task.done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: task.done
                    ? _ProjectDetailScreenState.kGreen
                    : _ProjectDetailScreenState.kSub,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              color: _ProjectDetailScreenState.kText,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              decoration:
                                  task.done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (task.source == 'AI')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2E6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                color: Color(0xFF7B3CB0),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          task.priority,
                          style: TextStyle(
                            color: priorityColor(task.priority),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        GestureDetector(
                          onTap: onEditDeadline,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatDate(task.dueDate),
                                style: const TextStyle(
                                  color: _ProjectDetailScreenState.kSub,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.edit_calendar_outlined,
                                size: 14,
                                color: _ProjectDetailScreenState.kSub,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isOverdue) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '기한이 지났는데 아직 완료되지 않았어요',
                        style: TextStyle(
                          color: _ProjectDetailScreenState.kOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ] else if (isDueTomorrow) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '마감 하루 전인데 아직 완료되지 않았어요',
                        style: TextStyle(
                          color: _ProjectDetailScreenState.kOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    const Text(
                      '왼쪽으로 밀어서 삭제',
                      style: TextStyle(
                        color: _ProjectDetailScreenState.kSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isAi = message.isAi;

    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isAi ? const Color(0xFFF9F1FF) : const Color(0xFFF8F3F0),
            borderRadius: BorderRadius.circular(18),
            border: !message.isRead && message.sender != '나'
                ? Border.all(color: const Color(0xFFD7B7F5))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    message.sender,
                    style: TextStyle(
                      color: isAi
                          ? const Color(0xFF7B3CB0)
                          : _ProjectDetailScreenState.kText,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (!message.isRead && message.sender != '나') ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              if (message.roleTag != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message.roleTag!,
                    style: const TextStyle(
                      color: _ProjectDetailScreenState.kSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isFile) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: _ProjectDetailScreenState.kText,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      message.message,
                      style: const TextStyle(
                        color: _ProjectDetailScreenState.kText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.time,
                style: const TextStyle(
                  color: _ProjectDetailScreenState.kSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiHintBox extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final String text;

  const _AiHintBox({
    required this.backgroundColor,
    required this.textColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusCountRow extends StatelessWidget {
  final String title;
  final String value;

  const _StatusCountRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ProjectDetailScreenState.kSub,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: _ProjectDetailScreenState.kText,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _ProjectDetailScreenState.kSub,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFFB3AAA6),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: const Color(0xFFFCFAF8),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE8DFDA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: _ProjectDetailScreenState.kWine,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateSelectField extends StatelessWidget {
  final String label;
  final String text;
  final VoidCallback onTap;

  const _DateSelectField({
    required this.label,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _ProjectDetailScreenState.kSub,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8DFDA)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: _ProjectDetailScreenState.kText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: _ProjectDetailScreenState.kSub,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeSelectField extends StatelessWidget {
  final String label;
  final String text;
  final VoidCallback onTap;

  const _TimeSelectField({
    required this.label,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _ProjectDetailScreenState.kSub,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8DFDA)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: _ProjectDetailScreenState.kText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.schedule_outlined,
                  size: 18,
                  color: _ProjectDetailScreenState.kSub,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AttachOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F1EE),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: _ProjectDetailScreenState.kWine),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: _ProjectDetailScreenState.kText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFE5DDD8),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _MemberItem {
  final String name;
  final String studentId;

  _MemberItem({
    required this.name,
    required this.studentId,
  });
}

class _ScheduleItem {
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  _ScheduleItem({
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
  });
}

class _RoleItem {
  String title;
  String assignee;
  String status;
  List<_TaskItem> tasks;

  _RoleItem({
    required this.title,
    required this.assignee,
    required this.status,
    required this.tasks,
  });
}

class _TaskItem {
  String title;
  String priority;
  DateTime dueDate;
  bool done;
  String source;

  _TaskItem({
    required this.title,
    required this.priority,
    required this.dueDate,
    required this.done,
    required this.source,
  });
}

class _ChatMessage {
  final String sender;
  final String time;
  final String message;
  final String? roleTag;
  final bool isAi;
  final bool isFile;
  bool isRead;

  _ChatMessage({
    required this.sender,
    required this.time,
    required this.message,
    this.roleTag,
    required this.isAi,
    required this.isFile,
    required this.isRead,
  });
}

class _UrgentTaskView {
  final String title;
  final String assignee;
  final String priority;
  final DateTime dueDate;
  final bool isOverdue;

  _UrgentTaskView({
    required this.title,
    required this.assignee,
    required this.priority,
    required this.dueDate,
    required this.isOverdue,
  });
}

class _AppNotification {
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  bool isRead;

  _AppNotification({
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });
}
