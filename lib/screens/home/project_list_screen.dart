import 'package:flutter/material.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  static const Color kWine = Color(0xFF970D34);
  static const Color kCreamBg = Color(0xFFF4EFEC);
  static const Color kCard = Color(0xFFFBFAF8);
  static const Color kText = Color(0xFF1F1A1C);
  static const Color kSubText = Color(0xFF8A8582);

  @override
  Widget build(BuildContext context) {
    final projects = [
      ProjectItem(
        number: '#13',
        title: '세계와 시민',
        subtitle: '무조건 A+',
        progress: 0.3,
        dday: 'D-7',
        memberCount: 4,
        scheduleCount: 3,
      ),
      ProjectItem(
        number: '#12',
        title: '소프트웨어공학',
        subtitle: '프로젝트 완성',
        progress: 0.8,
        dday: 'D-2',
        memberCount: 5,
        scheduleCount: 8,
      ),
      ProjectItem(
        number: '#7',
        title: '데이터베이스',
        subtitle: '팀원과 협력',
        progress: 0.5,
        dday: 'D-5',
        memberCount: 3,
        scheduleCount: 5,
      ),
    ];

    return Scaffold(
      backgroundColor: kCreamBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: kWine,
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    '프로젝트',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    '팀 프로젝트를 효율적으로 관리하세요',
                    style: TextStyle(
                      color: Color(0xFFF1E2E6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                itemCount: projects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return _ProjectCard(
                    project: project,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectDetailScreen(
                            projectNumber: project.number,
                            projectTitle: project.title,
                            projectGoal: project.subtitle,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
          onPressed: () {},
          icon: const Icon(Icons.add, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectItem project;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.onTap,
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
            color: ProjectListScreen.kCard,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        color: ProjectListScreen.kText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    project.dday,
                    style: const TextStyle(
                      color: Color(0xFFD71E45),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                project.subtitle,
                style: const TextStyle(
                  color: ProjectListScreen.kSubText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: project.progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF0EAE6),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF9E1237)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(project.progress * 100).round()}% 진행 중',
                style: const TextStyle(
                  color: ProjectListScreen.kSubText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFF0E8E4), height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.group_outlined,
                      color: ProjectListScreen.kSubText, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    '${project.memberCount}명',
                    style: const TextStyle(
                      color: ProjectListScreen.kSubText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.calendar_today_outlined,
                      color: ProjectListScreen.kSubText, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${project.scheduleCount}개',
                    style: const TextStyle(
                      color: ProjectListScreen.kSubText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
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

class ProjectItem {
  final String number;
  final String title;
  final String subtitle;
  final double progress;
  final String dday;
  final int memberCount;
  final int scheduleCount;

  ProjectItem({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.dday,
    required this.memberCount,
    required this.scheduleCount,
  });
}
