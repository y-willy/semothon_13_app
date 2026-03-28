import 'package:flutter/material.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  static const Color kWine = Color(0xFF8E1F39);
  static const Color kCream = Color(0xFFF4EFEC);
  static const Color kCard = Color(0xFFFFFCFA);
  static const Color kText = Color(0xFF1F1A1C);
  static const Color kSub = Color(0xFF8B8480);

  late List<_ProjectCardData> projects = [
    _ProjectCardData(
      number: '#13',
      title: '세계와 시민',
      status: '진행 중',
      memberCount: 4,
      roleCount: 3,
      scheduleCount: 2,
      updatedText: '최근 업데이트 오늘',
    ),
    _ProjectCardData(
      number: '#12',
      title: '소프트웨어공학',
      status: '마감 임박 업무 2개',
      memberCount: 5,
      roleCount: 3,
      scheduleCount: 2,
      updatedText: '최근 업데이트 2시간 전',
    ),
    _ProjectCardData(
      number: '#7',
      title: '데이터베이스',
      status: '기한 지난 업무 1개',
      memberCount: 3,
      roleCount: 2,
      scheduleCount: 1,
      updatedText: '최근 업데이트 어제',
    ),
  ];

  Color _statusColor(String status) {
    if (status.contains('기한 지난')) return const Color(0xFFFF6B2C);
    if (status.contains('마감 임박')) return const Color(0xFFFF8A3D);
    if (status.contains('지연')) return const Color(0xFFFF6B2C);
    if (status.contains('완료')) return const Color(0xFF2E9E57);
    if (status.contains('준비')) return const Color(0xFF8B8480);
    return kWine;
  }

  void _showAddProjectDialog() {
    final titleController = TextEditingController();
    String selectedStatus = '준비 중';

    showDialog(
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
                        '새 프로젝트 추가',
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
                      label: '프로젝트 이름',
                      hintText: '예: 운영체제 팀플',
                    ),
                    const SizedBox(height: 14),
                    _StatusDropdownField(
                      label: '상태',
                      value: selectedStatus,
                      items: const [
                        '준비 중',
                        '진행 중',
                        '마감 임박 업무 1개',
                        '기한 지난 업무 1개',
                        '완료',
                      ],
                      onChanged: (value) {
                        setInnerState(() {
                          selectedStatus = value;
                        });
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
                                final nextNumber = '#${projects.length + 1}';
                                projects.insert(
                                  0,
                                  _ProjectCardData(
                                    number: nextNumber,
                                    title: title,
                                    status: selectedStatus,
                                    memberCount: 1,
                                    roleCount: 0,
                                    scheduleCount: 0,
                                    updatedText: '방금 생성됨',
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

  void _showEditProjectDialog(int index) {
    final controller = TextEditingController(text: projects[index].title);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
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
                    '프로젝트 이름 수정',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
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
                          final newTitle = controller.text.trim();
                          if (newTitle.isEmpty) return;

                          setState(() {
                            projects[index].title = newTitle;
                            projects[index].updatedText = '방금 이름 수정';
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
  }

  void _showEditStatusDialog(int index) {
    String selectedStatus = projects[index].status;

    showDialog(
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
                        '상태 수정',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _StatusDropdownField(
                      label: '상태',
                      value: selectedStatus,
                      items: const [
                        '준비 중',
                        '진행 중',
                        '마감 임박 업무 1개',
                        '마감 임박 업무 2개',
                        '기한 지난 업무 1개',
                        '역할 1개 지연',
                        '완료',
                      ],
                      onChanged: (value) {
                        setInnerState(() {
                          selectedStatus = value;
                        });
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
                                projects[index].status = selectedStatus;
                                projects[index].updatedText = '방금 상태 수정';
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

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
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
                    '프로젝트 삭제',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\'${projects[index].title}\' 프로젝트를 삭제할까요?',
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
                            projects.removeAt(index);
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD94A3A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '삭제',
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
                icon: Icons.flag_outlined,
                title: '상태 수정',
                onTap: () => Navigator.pop(context, 'edit_status'),
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
    } else if (action == 'edit_status') {
      _showEditStatusDialog(index);
    } else if (action == 'delete') {
      _showDeleteDialog(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: kWine,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '프로젝트',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '팀 프로젝트를 효율적으로 관리하세요',
                          style: TextStyle(
                            color: Color(0xFFF2E3E7),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _showAddProjectDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.14),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '+ 새 프로젝트',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: projects.isEmpty
                  ? const _EmptyProjectView()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                      itemCount: projects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = projects[index];
                        return _ProjectCard(
                          item: item,
                          statusColor: _statusColor(item.status),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProjectDetailScreen(
                                  projectNumber: item.number,
                                  projectTitle: item.title,
                                  projectGoal: '',
                                ),
                              ),
                            );
                          },
                          onMoreTap: () => _showProjectMenu(context, index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final _ProjectCardData item;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _ProjectCard({
    required this.item,
    required this.statusColor,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _ProjectListScreenState.kCard,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 6),
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
                      item.title,
                      style: const TextStyle(
                        color: _ProjectListScreenState.kText,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: onMoreTap,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F1EE),
                        borderRadius: BorderRadius.circular(14),
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
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                item.updatedText,
                style: const TextStyle(
                  color: _ProjectListScreenState.kSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFF0E8E4), height: 1),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InfoChip(
                    icon: Icons.group_outlined,
                    text: '${item.memberCount}명',
                  ),
                  _InfoChip(
                    icon: Icons.work_outline,
                    text: '역할 ${item.roleCount}개',
                  ),
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    text: '일정 ${item.scheduleCount}개',
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: _ProjectListScreenState.kSub,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: _ProjectListScreenState.kSub,
              fontSize: 13,
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _ProjectListScreenState.kSub,
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

class _StatusDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _StatusDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
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
            color: _ProjectListScreenState.kSub,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFAF8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8DFDA)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (changed) {
                if (changed != null) {
                  onChanged(changed);
                }
              },
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
          borderRadius: BorderRadius.circular(14),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 54,
              color: _ProjectListScreenState.kSub,
            ),
            SizedBox(height: 14),
            Text(
              '아직 프로젝트가 없습니다',
              style: TextStyle(
                color: _ProjectListScreenState.kText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '상단의 새 프로젝트 버튼으로 시작해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ProjectListScreenState.kSub,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCardData {
  final String number;
  String title;
  String status;
  int memberCount;
  int roleCount;
  int scheduleCount;
  String updatedText;

  _ProjectCardData({
    required this.number,
    required this.title,
    required this.status,
    required this.memberCount,
    required this.roleCount,
    required this.scheduleCount,
    required this.updatedText,
  });
}
