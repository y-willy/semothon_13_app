import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

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

  static const Color primaryColor = Color(0xFFA31621);
  static const Color bgColor = Color(0xFFF6F1F1);
  static const Color cardColor = Colors.white;
  static const Color subtitleColor = Color(0xFF7D6666);
  static const Color inputFillColor = Color(0xFFF9F1F1);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    majorController.dispose();
    passwordController.dispose();
    super.dispose();
  }
void onSignupSubmit() async {
  final Uri url = Uri.parse(
    'https://semothon13app-production.up.railway.app/auth/signup',
  );

  try {
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
      if (!mounted) return;

      final bool? goBackToLogin = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.35),
        builder: (dialogContext) {
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
                        Navigator.of(dialogContext).pop(true);
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

      if (goBackToLogin == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
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
                    // 수정된 코드 (이미지 적용)
Container(
  width: 160,
  height: 160,
  decoration: const BoxDecoration(
    color: Colors.white, // 배경색 유지
    shape: BoxShape.circle,
  ),
  child: Center(
    child: Image.asset(
      'assets/images/hikhuong-nk.png', // 사용할 이미지 경로
      
      width: 250, // 이미지 크기 조절
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
                          const SizedBox(height: 22),
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