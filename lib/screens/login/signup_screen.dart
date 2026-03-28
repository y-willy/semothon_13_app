import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 기존 입력 필드
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController personalityController = TextEditingController();

  // MBTI 선택
  String? selectedMBTI;
  final List<String> mbtiList = [
    'ISTJ', 'ISFJ', 'INFJ', 'INTJ',
    'ISTP', 'ISFP', 'INFP', 'INTP',
    'ESTP', 'ESFP', 'ENFP', 'ENTP',
    'ESTJ', 'ESFJ', 'ENFJ', 'ENTJ',
  ];

  // 시간표 데이터
  final List<String> days = ['월', '화', '수', '목', '금'];
  final int startHour = 9;
  final int endHour = 21;

  // 일정 목록: {id, day, startHour, startMin, endHour, endMin, title}
  List<Map<String, dynamic>> scheduleItems = [];
  int _nextId = 0;

  static const Color primaryColor = Color(0xFFA31621);
  static const Color bgColor = Color(0xFFF6F1F1);
  static const Color cardColor = Colors.white;
  static const Color subtitleColor = Color(0xFF7D6666);
  static const Color inputFillColor = Color(0xFFF9F1F1);
  static const Color cardBorder = Color(0xFFE7C9C9);
  static const Color textDark = Color(0xFF1A1A1A);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    majorController.dispose();
    passwordController.dispose();
    personalityController.dispose();
    super.dispose();
  }

  // ─── 일정 추가 다이얼로그 ───
  void _showAddScheduleDialog({String? preselectedDay}) {
    String selectedDay = preselectedDay ?? '월';
    int sHour = 9, sMin = 0, eHour = 10, eMin = 0;
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          '일정 추가',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 일정 이름
                      const Text(
                        '일정 이름',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5F4747),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: '예) 데이터구조, 알바, 동아리',
                          hintStyle: const TextStyle(
                            color: Color(0xFFA58787),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: cardBorder,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: primaryColor,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 요일 선택
                      const Text(
                        '요일',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5F4747),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: days.map((day) {
                          final isSelected = selectedDay == day;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() => selectedDay = day);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 2),
                                padding:
                                const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : cardBorder,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : textDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // 시작 시간
                      const Text(
                        '시작 시간',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5F4747),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              value: sHour,
                              items: List.generate(
                                  endHour - startHour,
                                      (i) => startHour + i),
                              label: (v) => '$v시',
                              onChanged: (v) {
                                setDialogState(() => sHour = v);
                                if (sHour > eHour ||
                                    (sHour == eHour && sMin >= eMin)) {
                                  setDialogState(() {
                                    eHour = sHour;
                                    eMin = (sMin + 15) % 60;
                                    if (eMin < sMin) eHour++;
                                    if (eHour > endHour) eHour = endHour;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDropdown(
                              value: sMin,
                              items: [0, 15, 30, 45],
                              label: (v) => '${v.toString().padLeft(2, '0')}분',
                              onChanged: (v) {
                                setDialogState(() => sMin = v);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 종료 시간
                      const Text(
                        '종료 시간',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5F4747),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              value: eHour,
                              items: List.generate(
                                  endHour - startHour + 1,
                                      (i) => startHour + i),
                              label: (v) => '$v시',
                              onChanged: (v) {
                                setDialogState(() => eHour = v);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDropdown(
                              value: eMin,
                              items: [0, 15, 30, 45],
                              label: (v) => '${v.toString().padLeft(2, '0')}분',
                              onChanged: (v) {
                                setDialogState(() => eMin = v);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 버튼
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: cardBorder),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '취소',
                                  style: TextStyle(
                                    color: textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (titleController.text.trim().isEmpty) {
                                    return;
                                  }
                                  final startTotal = sHour * 60 + sMin;
                                  final endTotal = eHour * 60 + eMin;
                                  if (endTotal <= startTotal) {
                                    return;
                                  }

                                  setState(() {
                                    scheduleItems.add({
                                      'id': _nextId++,
                                      'day': selectedDay,
                                      'startHour': sHour,
                                      'startMin': sMin,
                                      'endHour': eHour,
                                      'endMin': eMin,
                                      'title': titleController.text.trim(),
                                    });
                                  });
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '추가',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown({
    required int value,
    required List<int> items,
    required String Function(int) label,
    required void Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          items: items.map((v) {
            return DropdownMenuItem(
              value: v,
              child: Text(
                label(v),
                style: const TextStyle(fontSize: 14, color: textDark),
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  // ─── 시간표 격자 위젯 (15분 단위, 일정 표시) ───
  Widget _buildScheduleGrid() {
    final hours = List.generate(endHour - startHour, (i) => startHour + i);
    final quarterLabels = ['00', '15', '30', '45'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 요일 헤더
        Row(
          children: [
            const SizedBox(width: 40),
            ...days.map((day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
              ),
            )),
          ],
        ),
        const SizedBox(height: 4),

        // 격자 본체
        ...hours.expand((hour) {
          return List.generate(4, (q) {
            final min = q * 15;
            final showLabel = q == 0;

            return Row(
              children: [
                // 시간 라벨 (정시에만 표시)
                SizedBox(
                  width: 40,
                  height: 18,
                  child: showLabel
                      ? Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        '$hour:00',
                        style: const TextStyle(
                          fontSize: 10,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                  )
                      : null,
                ),
                // 각 요일 셀
                ...days.map((day) {
                  // 이 셀에 해당하는 일정 찾기
                  final slotStart = hour * 60 + min;
                  final item = scheduleItems.firstWhere(
                        (s) {
                      if (s['day'] != day) return false;
                      final iStart = s['startHour'] * 60 + s['startMin'];
                      final iEnd = s['endHour'] * 60 + s['endMin'];
                      return slotStart >= iStart && slotStart < iEnd;
                    },
                    orElse: () => {},
                  );
                  final hasSchedule = item.isNotEmpty;

                  // 일정 시작 셀인지 확인 (이름 표시용)
                  bool isStart = false;
                  if (hasSchedule) {
                    isStart = (item['startHour'] == hour &&
                        item['startMin'] == min);
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (hasSchedule) {
                          // 일정 삭제 확인
                          _showDeleteDialog(item);
                        } else {
                          // 새 일정 추가
                          _showAddScheduleDialog(preselectedDay: day);
                        }
                      },
                      child: Container(
                        height: 18,
                        margin: const EdgeInsets.all(0.5),
                        decoration: BoxDecoration(
                          color: hasSchedule
                              ? primaryColor.withOpacity(0.85)
                              : const Color(0xFFF9F1F1),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: hasSchedule
                                ? primaryColor
                                : const Color(0xFFEDE3E3),
                            width: 0.5,
                          ),
                        ),
                        child: isStart
                            ? Padding(
                          padding:
                          const EdgeInsets.only(left: 2, top: 1),
                          child: Text(
                            item['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                            : null,
                      ),
                    ),
                  );
                }),
              ],
            );
          });
        }),
      ],
    );
  }

  void _showDeleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          item['title'] ?? '일정',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '${item['day']}요일 '
              '${item['startHour']}:${item['startMin'].toString().padLeft(2, '0')}'
              ' ~ '
              '${item['endHour']}:${item['endMin'].toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 14, color: subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                scheduleItems.removeWhere((s) => s['id'] == item['id']);
              });
              Navigator.pop(context);
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // 시간표 데이터를 JSON으로 변환
  List<Map<String, dynamic>> getScheduleData() {
    return scheduleItems.map((item) {
      return {
        'day': item['day'],
        'start': '${item['startHour']}:${item['startMin'].toString().padLeft(2, '0')}',
        'end': '${item['endHour']}:${item['endMin'].toString().padLeft(2, '0')}',
        'title': item['title'],
      };
    }).toList();
  }

  void onSignupSubmit() async {
    final Uri url = Uri.parse(
      'https://semothon13app-production.up.railway.app/auth/signup',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "display_name": nameController.text.trim(),
          "major": majorController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (selectedMBTI != null ||
            personalityController.text.trim().isNotEmpty) {
          try {
            final loginResponse = await http.post(
              Uri.parse(
                'https://semothon13app-production.up.railway.app/auth/login',
              ),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                "email": emailController.text.trim(),
                "password": passwordController.text.trim(),
              }),
            );

            if (loginResponse.statusCode == 200) {
              final loginData = jsonDecode(loginResponse.body);
              final token = loginData['access_token'];

              if (token != null) {
                final Map<String, dynamic> profileData = {};
                if (selectedMBTI != null) {
                  profileData['mbti'] = selectedMBTI;
                }
                if (personalityController.text.trim().isNotEmpty) {
                  profileData['personality_summary'] =
                      personalityController.text.trim();
                }

                await http.patch(
                  Uri.parse(
                    'https://semothon13app-production.up.railway.app/profile/me',
                  ),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode(profileData),
                );

                // 시간표 저장
                if (scheduleItems.isNotEmpty) {
                  final scheduleData = getScheduleData();
                  debugPrint('시간표 데이터: ${jsonEncode(scheduleData)}');

                  // TODO: 백엔드 API 준비되면 아래 주석 해제
                  // await http.post(
                  //   Uri.parse(
                  //     'https://semothon13app-production.up.railway.app/schedule/me',
                  //   ),
                  //   headers: {
                  //     'Content-Type': 'application/json',
                  //     'Authorization': 'Bearer $token',
                  //   },
                  //   body: jsonEncode({'schedule': scheduleData}),
                  // );
                }
              }
            }
          } catch (_) {
            debugPrint('프로필/시간표 저장 실패 (회원가입은 성공)');
          }
        }

        if (!mounted) return;

        await showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.35),
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/happykhuong.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '회원가입 성공!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A2A2A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data['message'] ?? '회원가입이 완료되었습니다.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7D6666),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (!mounted) return;
        Navigator.pop(context);
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['detail']?.toString() ??
                  data['message'] ??
                  '회원가입 실패',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 연결 실패: $e')),
      );
    }
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFFA58787),
        fontSize: 14,
      ),
      filled: true,
      fillColor: inputFillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE7C9C9),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.2,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF5F4747),
      ),
    );
  }

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
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    // ─── 뒤로가기 ───
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
                              color: Color(0xFF7D6666),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '로그인으로 돌아가기',
                              style: TextStyle(
                                color: Color(0xFF7D6666),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ─── 캐릭터 이미지 ───
                    Container(
                      width: 160,
                      height: 160,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/hikhuong-nk.png',
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      '회원가입!',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '쿠옹과 함께 팀플을 시작해보세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── 기본 정보 카드 ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFBFB),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('이름'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            decoration: _inputDecoration('김경희'),
                          ),
                          const SizedBox(height: 18),
                          _label('이메일 (경희대 이메일)'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration('example@khu.ac.kr'),
                          ),
                          const SizedBox(height: 18),
                          _label('전공'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: majorController,
                            decoration: _inputDecoration('컴퓨터공학과'),
                          ),
                          const SizedBox(height: 18),
                          _label('비밀번호'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: _inputDecoration('••••••••'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── MBTI + 자기소개 카드 ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFBFB),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              '나를 소개해주세요!',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _label('MBTI'),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.8,
                            ),
                            itemCount: mbtiList.length,
                            itemBuilder: (context, index) {
                              final mbti = mbtiList[index];
                              final isSelected = selectedMBTI == mbti;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => selectedMBTI = mbti),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : cardBorder,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    mbti,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : textDark,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          _label('한줄 자기소개'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: personalityController,
                            decoration: _inputDecoration(
                              '예) 계획적이고 꼼꼼한 성격입니다',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── 시간표 카드 ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFBFB),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              '내 시간표',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Center(
                            child: Text(
                              '빈 칸을 터치해서 일정을 추가하세요',
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 격자표
                          _buildScheduleGrid(),

                          const SizedBox(height: 12),

                          // 추가된 일정 리스트
                          if (scheduleItems.isNotEmpty) ...[
                            const Divider(color: cardBorder),
                            const SizedBox(height: 8),
                            _label('추가된 일정'),
                            const SizedBox(height: 8),
                            ...scheduleItems.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item['day']}  '
                                                '${item['startHour']}:${item['startMin'].toString().padLeft(2, '0')}'
                                                ' ~ '
                                                '${item['endHour']}:${item['endMin'].toString().padLeft(2, '0')}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: subtitleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          scheduleItems.removeWhere(
                                                (s) => s['id'] == item['id'],
                                          );
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],

                          // + 일정 추가 버튼
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => _showAddScheduleDialog(),
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: primaryColor,
                              ),
                              label: const Text(
                                '일정 추가',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ─── 회원가입 버튼 ───
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: onSignupSubmit,
                        icon: const Icon(
                          Icons.person_add_alt_1,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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
}