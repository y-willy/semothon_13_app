import 'package:flutter/material.dart';
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
                            projects[index].title = newTitle;
                            projects[index].updatedText = '방금 이름 수정';
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

  void _showEditStatusDialog(int index) {
    String selectedStatus = projects[index].status;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
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
                        '상태 수정',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
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
                                projects[index].status = selectedStatus;
                                projects[index].updatedText = '방금 상태 수정';
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
Widget _buildTopSection(BuildContext context) {
  return Stack(
    alignment: Alignment.center,
    children: [
      // 왼쪽: 홈으로 버튼
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

      // 가운데: 제목
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
        '현재 진행 중인 프로젝트와 상태를 한눈에 확인하고, 필요하면 이름이나 상태를 바로 수정해보세요.',
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF4B3A3A),
          height: 1.5,
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
                      item.title,
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
                item.number,
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
                  item.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.updatedText,
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _ProjectListScreenState.kSub,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _ProjectListScreenState.kInputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _ProjectListScreenState.kBorder),
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