// floating_chatbot_button.dart

import 'package:flutter/material.dart';
import 'package:cow_management/screens/ai_chatbot/chatbot_quick_core.dart';

class FloatingChatbotButton extends StatelessWidget {
  final VoidCallback? onLongPress;
  
  const FloatingChatbotButton({super.key, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'AI 챗봇 소담이',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: ChatbotQuickCore(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      onLongPress: () {
        if (onLongPress != null) {
          // 길게 누르면 숨기기 확인 다이얼로그 표시
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('소담이 숨기기'),
                content: const Text('소담이를 숨기시겠습니까?\n우측 하단의 작은 아이콘을 눌러 다시 표시할 수 있습니다.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onLongPress!();
                    },
                    child: const Text('숨기기'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.shade200, // 연한 초록색
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 0),
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
