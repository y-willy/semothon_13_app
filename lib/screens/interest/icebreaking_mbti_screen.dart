import 'package:flutter/material.dart';

class IcebreakingMbtiScreen extends StatefulWidget {
  final String userName;

  const IcebreakingMbtiScreen({super.key, required this.userName});

  @override
  State<IcebreakingMbtiScreen> createState() => _IcebreakingMbtiScreenState();
}

class _IcebreakingMbtiScreenState extends State<IcebreakingMbtiScreen> {
  // 색상 - 기존 앱 테마에 맞춤
  static const Color primaryColor = Color(0xFFA31621);
  static const Color primaryLight = Color(0xFFE8A0A7);
  static const Color bgColor = Color(0xFFF6F1F1);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF7D6666);
  static const Color cardBorder = Color(0xFFE0D6D6);

  // 현재 질문 인덱스
  int currentQuestion = 0;

  // 각 질문별 선택된 답변
  List<String?> selectedAnswers = [null, null, null, null];

  // MBTI 질문 데이터
  final List<Map<String, dynamic>> questions = [
    {
      'question': '새로운 팀원들을 만났을 때 나는?',
      'face': '^_^',
      'options': [
        '먼저 말을 걸고 분위기를 띄워요 (E)',
        '상대가 먼저 말해주면 좋겠어요 (I)',
      ],
    },
    {
      'question': '팀 프로젝트 주제를 정할 때 나는?',
      'face': '^_^',
      'options': [
        '현실적으로 가능한 주제를 선호해요 (S)',
        '새롭고 창의적인 아이디어가 좋아요 (N)',
      ],
    },
    {
      'question': '팀원 간 의견이 충돌할 때 나는?',
      'face': '*_*',
      'options': [
        '논리적으로 최선의 방안을 찾아요 (T)',
        '팀원들 감정을 먼저 살펴요 (F)',
      ],
    },
    {
      'question': '프로젝트 마감이 다가올 때 나는?',
      'face': '^_^',
      'options': [
        '계획대로 미리미리 끝내놨어요 (J)',
        '마감 직전에 집중력이 폭발해요 (P)',
      ],
    },
  ];

  void selectAnswer(String answer) {
    setState(() {
      selectedAnswers[currentQuestion] = answer;
    });

    // 잠시 후 다음 질문으로 이동
    Future.delayed(const Duration(milliseconds: 500), () {
      if (currentQuestion < questions.length - 1) {
        setState(() {
          currentQuestion++;
        });
      } else {
        // 모든 질문 완료 → 결과 처리
        _showResult();
      }
    });
  }

  void _showResult() {
    // MBTI 결과 계산
    String mbti = '';
    mbti += (selectedAnswers[0]?.contains('(E)') ?? false) ? 'E' : 'I';
    mbti += (selectedAnswers[1]?.contains('(S)') ?? false) ? 'S' : 'N';
    mbti += (selectedAnswers[2]?.contains('(T)') ?? false) ? 'T' : 'F';
    mbti += (selectedAnswers[3]?.contains('(J)') ?? false) ? 'J' : 'P';

    // TODO: 결과를 다음 화면으로 전달하거나 API로 전송
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (_) => NextScreen(mbti: mbti)),
    // );

    // 임시: 결과 다이얼로그
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('MBTI 결과'),
        content: Text(
          '${widget.userName}님의 MBTI는 $mbti 입니다!',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    // 이전까지 선택한 답변 목록
    final answeredList = selectedAnswers
        .where((a) => a != null)
        .map((a) => a!.split(' (')[0]) // "(E)" 등 제거
        .toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── 상단 헤더 ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, size: 20, color: textDark),
                        SizedBox(width: 8),
                        Text(
                          '팀으로 돌아가기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '아이스브레이킹 ${currentQuestion + 1} / ${questions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: textGrey,
                    ),
                  ),
                ],
              ),
            ),

            // ─── 진행 바 ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: primaryLight.withOpacity(0.3),
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ),

            // ─── 스크롤 가능한 컨텐츠 ───
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // ─── 캐릭터 (빨간 원 + 얼굴) ───
                    Container(
                      width: 160,
                      height: 160,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        question['face'],
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── 질문 말풍선 ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Text(
                        question['question'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── 선택지 버튼들 ───
                    ...List.generate(
                      (question['options'] as List).length,
                          (index) {
                        final option = question['options'][index] as String;
                        final isSelected =
                            selectedAnswers[currentQuestion] == option;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => selectAnswer(option),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor.withOpacity(0.08)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                  isSelected ? primaryColor : cardBorder,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                option,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: textDark,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ─── 내가 선택한 답변 영역 ───
                    if (answeredList.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '내가 선택한 답변:',
                              style: TextStyle(
                                fontSize: 14,
                                color: textGrey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: answeredList.map((answer) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: cardBorder),
                                  ),
                                  child: Text(
                                    answer,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textDark,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}