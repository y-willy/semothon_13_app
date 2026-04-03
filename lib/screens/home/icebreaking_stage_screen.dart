import 'package:flutter/material.dart';

class IcebreakingStageScreen extends StatelessWidget {
  const IcebreakingStageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAF7),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF231A1C),
        title: const Text(
          '아이스브레이킹',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEBE2DE)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '아이스브레이킹',
                style: TextStyle(
                  color: Color(0xFF231A1C),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '아이스브레이킹 화면입니다.',
                style: TextStyle(
                  color: Color(0xFF8C7E7F),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}