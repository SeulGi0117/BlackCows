import 'package:flutter/material.dart';
import 'package:cow_management/screens/ai_service/chatbot.dart';

class FloatingChatbotButton extends StatelessWidget {
  const FloatingChatbotButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatbotScreen()),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/chatbot_icon.png',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
