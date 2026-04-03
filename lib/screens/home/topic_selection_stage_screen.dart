import 'package:flutter/material.dart';

// --- 1. 데이터 모델 및 모든 과목 질문 데이터 ---
enum QuestionType { singleChoice, multipleChoice, text, multipleChoiceWithOther }

class Question {
  final String title;
  final QuestionType type;
  final List<String> options;
  final int maxSelect;

  Question({
    required this.title,
    required this.type,
    this.options = const [],
    this.maxSelect = 0,
  });
}

final Map<String, List<Question>> subjectQuestions = {
  '디자인적 사고': [
    Question(title: '1. 최근 흥미로웠던 개발 주제가 있으신가요? (중복 가능)', type: QuestionType.multipleChoice, options: ['사회 문제 해결', '재미있는 서비스', '기술적으로 도전적인', '창업 아이디어', '생활 편의 서비스']),
    Question(title: '2. 어떤 개발 경험이 있으신가요? (중복 가능)', type: QuestionType.multipleChoice, options: ['디자인 (UI/UX)', '게임 개발', '웹 프로그래밍', '앱 프로그래밍', 'AI / 머신러닝', '시스템 프로그래밍', '데이터 분석']),
    Question(title: '3. 이건 정말 창의적이다라고 생각되시는 아이디어가 있나요?', type: QuestionType.text),
    Question(title: '4. 관심있는 문제 영역이 있나요?', type: QuestionType.multipleChoice, options: ['교육', '환경', '건강', '교통', '커뮤니티', '게임 / 엔터테인먼트', '생산성']),
    Question(title: '5. 프로젝트 결과물이 어디까지 나오면 좋겠나요?', type: QuestionType.singleChoice, options: ['아이디어 기획 중심', '간단한 프로토타입', '핵심 기능 구현', '대부분 기능 구현', '실제 배포 가능 수준']),
  ],
  '세계와 시민': [
    Question(title: '1. 우리 조가 다뤄봤으면 하는 사회문제 분야는 무엇인가요? (1~2개 선택)', type: QuestionType.multipleChoiceWithOther, options: ['환경/생태', '인권/복지', '생활/안전', '교육/문화', '기술/과학'], maxSelect: 2),
    Question(title: '2. 최근 일상생활에서 불편을 느끼거나 문제라고 생각했던 경험이 있다면 무엇인가요?', type: QuestionType.text),
    Question(title: '3. 해결하는 사회문제의 범위는 어디까지인가요?', type: QuestionType.singleChoice, options: ['캠퍼스', '지역사회', '대한민국/국가 및 글로벌']),
    Question(title: '4. 이번 활동에서 대변하거나 돕고싶은 구체적 대상은 누구인가요?', type: QuestionType.text),
    Question(title: '5. 도전해보고 싶은 해결 방식은 무엇인가요? (1~2개 선택)', type: QuestionType.multipleChoiceWithOther, options: ['숏폼 영상 제작', '오프라인 캠페인', '카드뉴스 제작', 'SNS 운영', '제도 제안'], maxSelect: 2),
  ],
  '데이터분석캡스톤디자인': [
    Question(title: '1. 가장 흥미를 느끼는 산업/도메인은 무엇인가요? (최대 3개)', type: QuestionType.multipleChoiceWithOther, options: ['스마트시티 / 교통', '헬스케어 / 스포츠', '엔터테인먼트 / 미디어', '금융 / 경제', '소셜 / 커뮤니티'], maxSelect: 3),
    Question(title: '2. 메인으로 다뤄보고 싶은 데이터의 종류는 무엇인가요? (1~2개)', type: QuestionType.multipleChoice, options: ['이미지 / 영상 데이터', '텍스트 데이터', '정형 데이터', '시계열 데이터'], maxSelect: 2),
    Question(title: '3. 우리 팀의 최종 결과물은 어떤 형태였으면 좋겠나요?', type: QuestionType.singleChoice, options: ['웹/앱 서비스', '온디바이스 AI 어플리케이션', '대시보드', '리포트/논문']),
    Question(title: '4. 활용해 보고 싶은 기술 스택이 있나요?', type: QuestionType.text),
    Question(title: '5. 데이터로 해결하고 싶은 불편함이 있다면?', type: QuestionType.text),
  ],
};

// --- 2. 주제 선정 화면 ---
class TopicSelectionStageScreen extends StatefulWidget {
  const TopicSelectionStageScreen({super.key});

  @override
  State<TopicSelectionStageScreen> createState() => _TopicSelectionStageScreenState();
}

class _TopicSelectionStageScreenState extends State<TopicSelectionStageScreen> {
  // 현재 선택된 과목 (기본값)
  String selectedSubject = '디자인적 사고';
  Map<int, dynamic> answers = {};

  @override
  Widget build(BuildContext context) {
    List<Question> questions = subjectQuestions[selectedSubject]!;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAF7),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF231A1C),
        title: const Text('주제선정', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // [추가된 부분] 과목 선택 섹션
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEBE2DE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('과목 선택', style: TextStyle(color: Color(0xFF231A1C), fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEBE2DE)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSubject,
                        isExpanded: true,
                        items: subjectQuestions.keys.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedSubject = newValue!;
                            answers.clear(); // 과목이 바뀌면 답변 초기화
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 질문 리스트
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                Question q = questions[index];
                return Container(
                  key: ValueKey('$selectedSubject-$index'), // 과목 변경 시 위젯 상태 초기화용 키
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFEBE2DE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.title, style: const TextStyle(color: Color(0xFF231A1C), fontSize: 16, fontWeight: FontWeight.w700, height: 1.4)),
                      const SizedBox(height: 16),
                      _buildQuestionInput(q, index),
                    ],
                  ),
                );
              },
            ),

            // 제출 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitSurvey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF231A1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('AI에게 주제 추천받기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // (입력 폼 렌더링 함수는 이전과 동일 - 지면 관계상 중복 생략 가능하나 완결성을 위해 유지)
  Widget _buildQuestionInput(Question q, int index) {
    if (q.type == QuestionType.text) {
      return TextField(
        decoration: InputDecoration(
          hintText: '자유롭게 적어주세요.',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEBE2DE))),
          contentPadding: const EdgeInsets.all(16),
        ),
        maxLines: 3,
        onChanged: (value) => answers[index] = value,
      );
    }
    if (q.type == QuestionType.singleChoice) {
      return Column(
        children: q.options.map((option) => RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: answers[index],
          activeColor: const Color(0xFF231A1C),
          onChanged: (value) => setState(() => answers[index] = value),
        )).toList(),
      );
    }
    if (q.type == QuestionType.multipleChoice || q.type == QuestionType.multipleChoiceWithOther) {
      answers[index] ??= <String>[];
      return Column(
        children: q.options.map((option) => CheckboxListTile(
          title: Text(option),
          value: (answers[index] as List).contains(option),
          activeColor: const Color(0xFF231A1C),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool? checked) {
            setState(() {
              if (checked == true) {
                if (q.maxSelect == 0 || (answers[index] as List).length < q.maxSelect) {
                  (answers[index] as List).add(option);
                }
              } else {
                (answers[index] as List).remove(option);
              }
            });
          },
        )).toList(),
      );
    }
    return const SizedBox();
  }

  void _submitSurvey() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF231A1C))),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      // 결과 화면으로 이동 로직 (이전 답변 코드의 ResultScreen 참고)
    });
  }
}