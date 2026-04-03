import 'package:flutter/material.dart';

class IcebreakingStageScreen extends StatefulWidget {
  const IcebreakingStageScreen({super.key});

  @override
  State<IcebreakingStageScreen> createState() => _IcebreakingStageScreenState();
}

class _IcebreakingStageScreenState extends State<IcebreakingStageScreen> {
  static const Color kCream = Color(0xFFFCFAF7);
  static const Color kCard = Colors.white;
  static const Color kBorder = Color(0xFFEBE2DE);
  static const Color kText = Color(0xFF231A1C);
  static const Color kSub = Color(0xFF8C7E7F);
  static const Color kWine = Color(0xFFA31621);

  bool hasStarted = false;
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;

  final List<Map<String, dynamic>> participants = [
    {'name': '현정', 'ready': true},
    {'name': '서연', 'ready': true},
    {'name': '유나', 'ready': true},
    {'name': '민지', 'ready': true},
  ];

  final List<Map<String, dynamic>> questions = [
    {
      'question': '팀플 시작할 때 나는 보통 어떤 편인가요?',
      'options': [
        '먼저 말 걸고 분위기를 푼다',
        '일단 팀 분위기를 살핀다',
        '역할부터 빨리 정하고 싶다',
        '흐름 따라가며 천천히 적응한다',
      ],
    },
    {
      'question': '회의할 때 내가 가장 편한 분위기는?',
      'options': [
        '짧고 핵심만 빠르게',
        '자유롭게 아이디어 많이',
        '미리 정리한 뒤 차분하게',
        '필요한 말만 정확하게',
      ],
    },
    {
      'question': '새로운 주제를 정할 때 나는?',
      'options': [
        '재밌는 아이디어를 많이 던진다',
        '현실성부터 먼저 따진다',
        '자료조사를 먼저 해본다',
        '의견을 듣고 정리하는 편이다',
      ],
    },
    {
      'question': '팀플 단톡에서 나는 보통?',
      'options': [
        '확인하면 바로 답하는 편',
        '늦어도 꼭 답은 하는 편',
        '중요한 말 위주로 짧게 답한다',
        '생각 정리 후 답하는 편이다',
      ],
    },
    {
      'question': '마감이 다가오면 나는?',
      'options': [
        '미리미리 끝내는 편',
        '중간부터 속도를 올린다',
        '막판 집중력이 좋은 편',
        '상황 따라 유동적으로 한다',
      ],
    },
  ];

  final List<int> selectedAnswers = [];

  bool get isAllReady => participants.every((member) => member['ready'] == true);

  double get progress => (currentQuestionIndex + 1) / questions.length;

  void _startSession() {
    if (!isAllReady) return;

    setState(() {
      hasStarted = true;
      currentQuestionIndex = 0;
      selectedOptionIndex = null;
      selectedAnswers.clear();
    });
  }

  void _selectOption(int index) {
    setState(() {
      selectedOptionIndex = index;
    });
  }

  void _goNext() {
    if (selectedOptionIndex == null) return;

    selectedAnswers.add(selectedOptionIndex!);

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOptionIndex = null;
      });
    } else {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _restartSession() {
    setState(() {
      hasStarted = false;
      currentQuestionIndex = 0;
      selectedOptionIndex = null;
      selectedAnswers.clear();
    });
  }

  String _getTeamSummaryTitle() {
    final counts = [0, 0, 0, 0];
    for (final answer in selectedAnswers) {
      counts[answer]++;
    }

    final maxValue = counts.reduce((a, b) => a > b ? a : b);
    final topIndex = counts.indexOf(maxValue);

    switch (topIndex) {
      case 0:
        return '우리 팀은 주도형 성향이 강해요';
      case 1:
        return '우리 팀은 균형형 성향이 강해요';
      case 2:
        return '우리 팀은 신중형 성향이 강해요';
      case 3:
      default:
        return '우리 팀은 적응형 성향이 강해요';
    }
  }

  String _getTeamSummaryDescription() {
    final counts = [0, 0, 0, 0];
    for (final answer in selectedAnswers) {
      counts[answer]++;
    }

    final maxValue = counts.reduce((a, b) => a > b ? a : b);
    final topIndex = counts.indexOf(maxValue);

    switch (topIndex) {
      case 0:
        return '의견 제시와 추진력이 좋은 팀이에요. 초반 방향 설정과 실행 속도가 강점이 될 수 있어요.';
      case 1:
        return '서로 의견을 조율하며 무난하게 협업할 가능성이 커요. 팀 분위기를 안정적으로 이끌 수 있어요.';
      case 2:
        return '생각을 정리하고 현실성을 검토하는 데 강한 팀이에요. 역할 분배와 일정 설계에서 장점이 커요.';
      case 3:
      default:
        return '상황에 맞춰 유연하게 움직일 수 있는 팀이에요. 변수 대응과 분위기 적응에 강점이 있어요.';
    }
  }

  Widget _buildWaitingScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '아이스브레이킹',
                  style: TextStyle(
                    color: kText,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '팀원들이 모두 방에 모이면 시작할 수 있어요.\n가벼운 질문으로 서로를 알아가면서 협업 스타일도 함께 탐색해보세요.',
                  style: TextStyle(
                    color: kSub,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFF0D9D9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        color: kWine,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '참여 인원 ${participants.length}명 · 모두 입장 완료',
                          style: const TextStyle(
                            color: kText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '참여 중인 팀원',
                  style: TextStyle(
                    color: kText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ...participants.map(
                  (member) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFAFA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEBE2DE)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3E7E4),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                member['name'].toString().substring(0, 1),
                                style: const TextStyle(
                                  color: kWine,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              member['name'],
                              style: const TextStyle(
                                color: kText,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF8F1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              '입장 완료',
                              style: TextStyle(
                                color: Color(0xFF1D8F49),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isAllReady ? _startSession : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kWine,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '시작하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final currentQuestion = questions[currentQuestionIndex];
    final List<String> options = List<String>.from(currentQuestion['options']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '질문 ${currentQuestionIndex + 1} / ${questions.length}',
                  style: const TextStyle(
                    color: kWine,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: progress,
                    backgroundColor: const Color(0xFFF2ECE8),
                    valueColor: const AlwaysStoppedAnimation(kWine),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: kBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF1D9D9)),
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    color: kWine,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  currentQuestion['question'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kText,
                    fontSize: 23,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            itemCount: options.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 12,
              childAspectRatio: 3.7,
            ),
            itemBuilder: (context, index) {
              final bool isSelected = selectedOptionIndex == index;

              final List<Color> cardColors = [
                const Color(0xFFFFF4F4),
                const Color(0xFFFDF7F2),
                const Color(0xFFF8F6FF),
                const Color(0xFFF4FAF6),
              ];

              return InkWell(
                onTap: () => _selectOption(index),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardColors[index],
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? kWine : kBorder,
                      width: isSelected ? 2 : 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isSelected ? kWine : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? kWine : const Color(0xFFE3D8D4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              color: isSelected ? Colors.white : kText,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          options[index],
                          style: const TextStyle(
                            color: kText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.groups_2_outlined,
                  color: kWine,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '응답 현황 4 / 4',
                  style: TextStyle(
                    color: kText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: selectedOptionIndex == null ? null : _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: kWine,
                foregroundColor: Colors.white,
                elevation: 0,
                disabledBackgroundColor: const Color(0xFFE7DEDA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                currentQuestionIndex == questions.length - 1 ? '결과 보기' : '다음 질문',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF1D9D9)),
                  ),
                  child: const Icon(
                    Icons.celebration_outlined,
                    color: kWine,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '아이스브레이킹 완료',
                  style: TextStyle(
                    color: kText,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _getTeamSummaryTitle(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kWine,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getTeamSummaryDescription(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kSub,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '쿠옹 코치 한줄 브리핑',
                  style: TextStyle(
                    color: kText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '우리 팀은 분위기 적응과 의견 조율에 대한 감각이 좋아요. 다음 단계에서는 주제선정 전에 회의 방식과 역할 기준을 먼저 합의하면 더 안정적으로 협업할 수 있어요.',
                  style: TextStyle(
                    color: kSub,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _restartSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: kWine,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '다시 시작하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFinished = hasStarted && currentQuestionIndex >= questions.length;

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: kText,
        title: const Text(
          '아이스브레이킹',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: !hasStarted
          ? _buildWaitingScreen()
          : isFinished
              ? _buildResultScreen()
              : _buildQuestionScreen(),
    );
  }
}