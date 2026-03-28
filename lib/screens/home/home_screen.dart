import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  HomeScreen({super.key, required this.userName});
  static const Color primaryColor = Color(0xFFA31621);
  static const Color bgColor = Color(0xFFF6F1F1);
  static const Color cardColor = Colors.white;
  static const Color subtitleColor = Color(0xFF7D6666);
  static const Color borderColor = Color(0xFFE7C9C9);
  static const Color softCardColor = Color(0xFFFCFBFB);
  static const Color successBgColor = Color(0xFFDDF5E7);
  static const Color successTextColor = Color(0xFF2E8B57);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
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
                  color: cardColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopSection(context),
                    const SizedBox(height: 22),
                    _buildIntroCard(),
                    const SizedBox(height: 18),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                    const Text(
                      '✶ 내 팀플 목록',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildTeamCard(),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ⭐ 수정된 이미지 영역 (왼쪽 정렬)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white, // 원형 배경색 (필요시 primaryColor로 변경)
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/face.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${userName.isEmpty ? "사용자" : userName}님, 환영합니다!',
                  style: const TextStyle(
                    color: Color(0xFF3A2A2A),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '오늘도 팀플을 시작해볼까요?',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.logout,
            size: 16,
            color: subtitleColor,
          ),
          label: const Text(
            '로그아웃',
            style: TextStyle(
              color: Color(0xFF5F4747),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: borderColor),
            backgroundColor: const Color(0xFFFFFAFA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        color: softCardColor,
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
        '안녕하세요! 저는 AI 팀장 쿠옹이에요.\n팀플을 시작하거나 기존 팀에 참여해보세요!',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF4B3A3A),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.add,
                color: primaryColor,
                size: 20,
              ),
              label: const Text(
                '새 팀 생성하기',
                style: TextStyle(
                  color: Color(0xFF4B3A3A),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFAFA),
                side: const BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.groups_2_outlined,
                color: primaryColor,
                size: 18,
              ),
              label: const Text(
                '팀 코드로 참여하기',
                style: TextStyle(
                  color: Color(0xFF4B3A3A),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFAFA),
                side: const BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: softCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
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
            children: [
              const Expanded(
                child: Text(
                  '캡스톤 디자인 A팀',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A2A2A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: successBgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '협업 진행 중',
                  style: TextStyle(
                    color: successTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '팀 코드 : KHU2024',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(
                Icons.groups_outlined,
                size: 18,
                color: subtitleColor,
              ),
              SizedBox(width: 6),
              Text(
                '4명',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5F4747),
                ),
              ),
              SizedBox(width: 18),
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: subtitleColor,
              ),
              SizedBox(width: 6),
              Text(
                '생성일: 2024-03-15',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5F4747),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}