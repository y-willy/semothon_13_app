import 'package:flutter/material.dart';

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
  static const Color kWine = Color(0xFF970D34);
  static const Color kCreamBg = Color(0xFFF4EFEC);
  static const Color kCard = Color(0xFFFBFAF8);
  static const Color kSoftChip = Color(0xFFF3ECE8);
  static const Color kText = Color(0xFF1F1A1C);
  static const Color kSubText = Color(0xFF8A8582);
  static const Color kEmptyIconBg = Color(0xFFF2ECE8);

  late String projectNumber;
  late String projectTitle;
  late String projectGoal;

  final List<TeamMember> members = [];
  final List<ScheduleCandidate> schedules = [];

  @override
  void initState() {
    super.initState();
    projectNumber = widget.projectNumber;
    projectTitle = widget.projectTitle;
    projectGoal = widget.projectGoal;
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    final studentIdController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.28),
      builder: (_) {
        return _AppDialog(
          title: '팀원 추가',
          child: Column(
            children: [
              _DialogTextField(
                controller: nameController,
                label: '이름',
                hintText: '예: 홍길동',
              ),
              const SizedBox(height: 14),
              _DialogTextField(
                controller: studentIdController,
                label: '학번',
                hintText: '예: 2024123456',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          cancelText: '취소',
          confirmText: '추가',
          onConfirm: () {
            if (nameController.text.trim().isEmpty ||
                studentIdController.text.trim().isEmpty) {
              return;
            }

            setState(() {
              members.add(
                TeamMember(
                  name: nameController.text.trim(),
                  studentId: studentIdController.text.trim(),
                ),
              );
            });

            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showAddScheduleDialog() {
    final dateController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.28),
      builder: (_) {
        return _AppDialog(
          title: '일정 추가',
          child: Column(
            children: [
              _DialogTextField(
                controller: dateController,
                label: '날짜',
                hintText: '예: 2026-03-28',
              ),
              const SizedBox(height: 14),
              _DialogTextField(
                controller: startController,
                label: '시작 시간',
                hintText: '예: 13:00',
              ),
              const SizedBox(height: 14),
              _DialogTextField(
                controller: endController,
                label: '종료 시간',
                hintText: '예: 15:00',
              ),
            ],
          ),
          cancelText: '취소',
          confirmText: '추가',
          onConfirm: () {
            if (dateController.text.trim().isEmpty ||
                startController.text.trim().isEmpty ||
                endController.text.trim().isEmpty) {
              return;
            }

            setState(() {
              schedules.add(
                ScheduleCandidate(
                  date: dateController.text.trim(),
                  startTime: startController.text.trim(),
                  endTime: endController.text.trim(),
                ),
              );
            });

            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showCreateProjectDialog() {
    final numberController =
        TextEditingController(text: projectNumber.replaceAll('#', ''));
    final titleController = TextEditingController(text: projectTitle);
    final goalController = TextEditingController(text: projectGoal);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.28),
      builder: (_) {
        return _AppDialog(
          title: '프로젝트 수정',
          child: Column(
            children: [
              _DialogTextField(
                controller: numberController,
                label: '프로젝트 번호',
                hintText: '예: 12',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _DialogTextField(
                controller: titleController,
                label: '프로젝트명',
                hintText: '예: 소프트웨어공학',
              ),
              const SizedBox(height: 14),
              _DialogTextField(
                controller: goalController,
                label: '한 줄 설명',
                hintText: '예: 프로젝트 완성',
              ),
            ],
          ),
          cancelText: '취소',
          confirmText: '저장',
          onConfirm: () {
            if (titleController.text.trim().isEmpty) return;

            setState(() {
              final number = numberController.text.trim();
              projectNumber = number.isEmpty ? '#12' : '#$number';
              projectTitle = titleController.text.trim();
              projectGoal = goalController.text.trim().isEmpty
                  ? '프로젝트 진행 중'
                  : goalController.text.trim();
            });

            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamBg,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;

            final headerHeight = height * 0.22;
            final horizontal = width * 0.06;
            final gap = height * 0.02;
            final cardHeight = (height - headerHeight - gap * 3) / 2;

            return Column(
              children: [
                _HeaderSection(
                  height: headerHeight,
                  projectNumber: projectNumber,
                  projectTitle: projectTitle,
                  projectGoal: projectGoal,
                  onBack: () => Navigator.pop(context),
                ),
                SizedBox(height: gap),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: Column(
                    children: [
                      _ManagementCard(
                        height: cardHeight.clamp(220.0, 320.0),
                        icon: Icons.group_outlined,
                        title: '팀원 관리',
                        buttonText: '+ 팀원 추가',
                        onButtonTap: _showAddMemberDialog,
                        content: members.isEmpty
                            ? const _EmptyContent(
                                icon: Icons.person_add_alt_1_outlined,
                                title: '아직 팀원이 없습니다',
                                subtitle: '팀원을 추가해보세요',
                              )
                            : _MemberListView(members: members),
                      ),
                      SizedBox(height: gap),
                      _ManagementCard(
                        height: cardHeight.clamp(220.0, 320.0),
                        icon: Icons.calendar_month_outlined,
                        title: '일정 후보',
                        buttonText: '+ 일정 추가',
                        onButtonTap: _showAddScheduleDialog,
                        content: schedules.isEmpty
                            ? const _EmptyContent(
                                icon: Icons.calendar_today_outlined,
                                title: '아직 일정 후보가 없습니다',
                                subtitle: '일정을 추가해보세요',
                              )
                            : _ScheduleListView(schedules: schedules),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: kWine,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: IconButton(
          onPressed: _showCreateProjectDialog,
          icon: const Icon(
            Icons.edit_outlined,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final double height;
  final String projectNumber;
  final String projectTitle;
  final String projectGoal;
  final VoidCallback onBack;

  const _HeaderSection({
    required this.height,
    required this.projectNumber,
    required this.projectTitle,
    required this.projectGoal,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: _ProjectDetailScreenState.kWine,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
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
          Text(
            '프로젝트 $projectNumber',
            style: const TextStyle(
              color: Color(0xFFF2DDE3),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            projectTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            projectGoal,
            style: const TextStyle(
              color: Color(0xFFF3E4E8),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final double height;
  final IconData icon;
  final String title;
  final String buttonText;
  final VoidCallback onButtonTap;
  final Widget content;

  const _ManagementCard({
    required this.height,
    required this.icon,
    required this.title,
    required this.buttonText,
    required this.onButtonTap,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _ProjectDetailScreenState.kCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: _ProjectDetailScreenState.kWine,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _ProjectDetailScreenState.kText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onButtonTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _ProjectDetailScreenState.kSoftChip,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: _ProjectDetailScreenState.kWine,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFF7F0EC),
                ),
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyContent({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: _ProjectDetailScreenState.kEmptyIconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 42,
                color: _ProjectDetailScreenState.kSubText,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ProjectDetailScreenState.kSubText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ProjectDetailScreenState.kSubText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberListView extends StatelessWidget {
  final List<TeamMember> members;

  const _MemberListView({required this.members});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length > 3 ? 3 : members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final member = members[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F4F2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1E8E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: _ProjectDetailScreenState.kWine,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _ProjectDetailScreenState.kText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.studentId,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _ProjectDetailScreenState.kSubText,
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
    );
  }
}

class _ScheduleListView extends StatelessWidget {
  final List<ScheduleCandidate> schedules;

  const _ScheduleListView({required this.schedules});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: schedules.length > 3 ? 3 : schedules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F4F2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1E8E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _ProjectDetailScreenState.kWine,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.date,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _ProjectDetailScreenState.kText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${schedule.startTime} ~ ${schedule.endTime}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _ProjectDetailScreenState.kSubText,
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
    );
  }
}

class _AppDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final String cancelText;
  final String confirmText;
  final VoidCallback onConfirm;

  const _AppDialog({
    required this.title,
    required this.child,
    required this.cancelText,
    required this.confirmText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: _ProjectDetailScreenState.kText,
                ),
              ),
            ),
            const SizedBox(height: 18),
            child,
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
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        color: _ProjectDetailScreenState.kSubText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _ProjectDetailScreenState.kWine,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
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
            color: _ProjectDetailScreenState.kSubText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFFB3AAA6),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: const Color(0xFFFCFAF8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
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

class TeamMember {
  final String name;
  final String studentId;

  TeamMember({
    required this.name,
    required this.studentId,
  });
}

class ScheduleCandidate {
  final String date;
  final String startTime;
  final String endTime;

  ScheduleCandidate({
    required this.date,
    required this.startTime,
    required this.endTime,
  });
}
