// chatbot_quick_page.dart

import 'package:flutter/material.dart';
import 'chatbot_quick_core.dart';

class ChatbotQuickPage extends StatelessWidget {
  const ChatbotQuickPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI 챗봇 소담이'),
          backgroundColor: const Color(0xFF9C27B0),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
          ),
        ),
        body: const ChatbotQuickCore(),
      ),
    );
  }
}