import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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

  static const Color primaryColor = Color(0xFFA31621);
  static const Color bgColor = Color(0xFFF6F1F1);
  static const Color cardColor = Colors.white;
  static const Color subtitleColor = Color(0xFF7D6666);
  static const Color inputFillColor = Color(0xFFF9F1F1);
  static const Color cardBorder = Color(0xFFE7C9C9);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    majorController.dispose();
    passwordController.dispose();
    personalityController.dispose();
    super.dispose();
  }

  void onSignupSubmit() async {
    final Uri url = Uri.parse(
      'https://semothon13app-production.up.railway.app/auth/signup',
    );

    try {
      // ── 1단계: 회원가입 ──
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
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
        // ── 2단계: 자동 로그인해서 토큰 받기 ──
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

              // ── 3단계: 프로필에 MBTI, personality_summary 저장 ──
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
              }
            }
          } catch (_) {
            // 프로필 저장 실패해도 회원가입은 성공이므로 무시
            debugPrint('프로필 저장 실패 (회원가입은 성공)');
          }
        }

        // ── 성공 다이얼로그 ──
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

                    // ─── 기본 정보 카드 (기존 그대로) ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFBFB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFEAE1E1),
                        ),
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

                    // ─── 추가: MBTI + 자기소개 카드 ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFBFB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFEAE1E1),
                        ),
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
                          // MBTI 선택
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
                                          : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),

                          // 한줄 자기소개
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