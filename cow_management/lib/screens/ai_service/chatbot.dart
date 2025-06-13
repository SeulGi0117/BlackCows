import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "안녕하세요! 무엇을 도와드릴까요?",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    _ChatMessage(
      text: "분만 정보 알려줘",
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    _ChatMessage(
      text: "103번 소가 최근 분만한 개체입니다.",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _controller.clear(); // 입력창 비우기
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? '오후' : '오전';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$period $hour:$minute';
  }

  // 실제 화면을 만드는 곳
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소담소담 상담 챗봇'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: msg.isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser) ...[
                        CircleAvatar(           // 챗봇일 경우, 소 캐릭터
                          radius: 18,
                          backgroundImage: AssetImage(
                              'assets/images/chatbot_icon.png'), 
                        ),
                        const SizedBox(width: 8),
                      ],
                      Column(
                        crossAxisAlignment: msg.isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            constraints: const BoxConstraints(maxWidth: 500),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? Colors.yellow[200]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.only(
                                bottomLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                topLeft:
                                    Radius.circular(msg.isUser ? 12 : 0),
                                bottomRight:
                                    Radius.circular(msg.isUser ? 0 : 12),
                              ),
                            ),
                            child: Text(msg.text),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              _formatTime(msg.timestamp),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "메시지를 입력하세요",
                      hintStyle: const TextStyle( 
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      filled: true, // 배경색 적용하려면 꼭 필요
                      fillColor: Colors.white, // 입력창 배경색
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24), 
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)), 
                      )
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _handleSend,
                  child: Image.asset(
                    'assets/images/send_chat.png',
                    width: 32,
                    height: 32,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
