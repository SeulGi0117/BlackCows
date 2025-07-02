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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI 챗봇 도우미',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '궁금한 점을 자유롭게 물어보세요.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '챗봇 기능 준비 중입니다.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '메시지를 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}