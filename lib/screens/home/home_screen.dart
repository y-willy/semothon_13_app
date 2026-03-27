import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFF7A0019),
        elevation: 0,
        title: const Text(
          '쿠옹',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 👋 인사
            const Text(
              '안녕하세요, 유나님 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// 🐻 쿠옹 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EDEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '오늘 할 일이 있어요!\n회의 시간도 추천했어요 👀',
                      style: TextStyle(fontSize: 14),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📌 팀 리스트 타이틀
            const Text(
              '내 팀',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// 📦 팀 카드 1
            _teamCard(
              title: '세모톤 프로젝트',
              progress: 0.6,
              dDay: 'D-3',
            ),

            const SizedBox(height: 12),

            /// 📦 팀 카드 2
            _teamCard(
              title: '세계와 시민 팀플',
              progress: 0.3,
              dDay: 'D-7',
            ),

          ],
        ),
      ),

      /// ➕ 플로팅 버튼 (팀 생성)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7A0019),
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 🔧 팀 카드 위젯
  Widget _teamCard({
    required String title,
    required double progress,
    required String dDay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dDay,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// 진행률 바
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF7A0019),
            minHeight: 6,
          ),

          const SizedBox(height: 6),

          Text('${(progress * 100).toInt()}% 진행 중'),
        ],
      ),
    );
  }
}