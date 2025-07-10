import 'package:flutter/material.dart';
import 'package:cow_management/services/chatbot_api.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class ChatbotQuickCore extends StatefulWidget {
  const ChatbotQuickCore({super.key, this.chatId});

  final String? chatId;

  @override
  State<ChatbotQuickCore> createState() => _ChatbotQuickCoreState();
}

class _ChatbotQuickCoreState extends State<ChatbotQuickCore> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _chatId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chatId = widget.chatId;
    _loadChatHistory();
  }

  @override
  void didUpdateWidget(ChatbotQuickCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatId != widget.chatId) {
      _chatId = widget.chatId;
      _loadChatHistory();
    }
  }

  Future<void> _loadChatHistory() async {
    if (_chatId == null) {
      setState(() {
        _messages.clear();
        _messages.add(_ChatMessage(
          text: "안녕하세요 소담이입니다! 무엇을 도와드릴까요?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _messages.clear();
    });

    try {
      final history = await getChatHistory(_chatId!);
      if (history.isEmpty) {
        setState(() {
          _messages.add(_ChatMessage(
            text: "안녕하세요 소담이입니다! 무엇을 도와드릴까요?",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      } else {
        final sortedHistory = history
            .map((msg) => _ChatMessage(
                  text: msg['content'] ?? msg['message'] ?? '',
                  isUser: msg['is_user'] == true || msg['role'] == 'user',
                  timestamp: DateTime.parse(msg['timestamp'] ?? msg['created_at'] ?? DateTime.now().toIso8601String()),
                ))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        setState(() {
          _messages.addAll(sortedHistory);
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: "채팅 기록을 불러올 수 없습니다.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.userId;
    if (userId == null) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _controller.clear();

    _chatId ??= await createChatRoom(userId);
    if (_chatId == null) {
      _addBotMessage("채팅방 생성에 실패했어요.");
      return;
    }

    final answer = await sendChatbotMessage(
      userId: userId,
      chatId: _chatId!,
      question: text,
    );

    _addBotMessage(answer ?? "답변을 가져오지 못했어요.");
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? '오후' : '오전';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$period $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser) ...[
                        const CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage('assets/images/chatbot_icon.png'),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: msg.isUser ? Colors.lightGreen.shade100 : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300.withOpacity(0.4),
                                      offset: const Offset(0, 2),
                                      blurRadius: 5,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: msg.isUser ? -10 : null,
                              left: msg.isUser ? null : -10,
                              child: CustomPaint(
                                size: const Size(12, 10),
                                painter: BubbleTailPainter(
                                  isUser: msg.isUser,
                                  color: msg.isUser ? Colors.lightGreen.shade100 : Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (msg.isUser) ...[
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.lightGreen.shade200,
                          child: const Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: "메시지를 입력하세요",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _handleSend,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.lightGreen.shade200,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
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

class BubbleTailPainter extends CustomPainter {
  final bool isUser;
  final Color color;

  BubbleTailPainter({
    required this.isUser,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (isUser) {
      // 사용자 메시지: 오른쪽에 있으므로 꼬리는 왼쪽을 향해야 함
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(0, size.height);
    } else {
      // 봇 메시지: 왼쪽에 있으므로 꼬리는 오른쪽을 향해야 함
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width, size.height);
    }
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
