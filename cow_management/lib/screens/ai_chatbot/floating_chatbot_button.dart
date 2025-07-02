// floating_chatbot_button.dart

import 'package:flutter/material.dart';
import 'package:cow_management/screens/ai_chatbot/chatbot_quick_page.dart';

class FloatingChatbotButton extends StatelessWidget {
  const FloatingChatbotButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 현재 스택을 모두 제거하고 ChatbotQuickPage로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotQuickPage()),
          (route) => false,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green[100], // 연한 초록색
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/chatbot_icon.png',
            width: 50, 
            height: 50,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}