// app_wrapper.dart

import 'package:flutter/material.dart';
import 'floating_chatbot_button.dart';

class AppWrapper extends StatefulWidget {
  final Widget child;
  final bool hideChatbot; // 챗봇 버튼을 숨길지 여부
  const AppWrapper({required this.child, this.hideChatbot = false, super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  double _x = 20;
  double _y = 120;
  bool _isVisible = true; // 챗봇 버튼 표시 여부
  bool _showIntroMessage = true; // 소개 메시지 표시 여부
  bool _isHoveringBubble = false; // 말풍선에 마우스가 올라가 있는지 여부

  void _toggleChatbotVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void _hideIntroMessage() {
    setState(() {
      _showIntroMessage = false;
    });
  }

  void _onBubbleHover(bool isHovering) {
    setState(() {
      _isHoveringBubble = isHovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    // hideChatbot이 true이면 챗봇 버튼을 완전히 숨김
    final shouldShowChatbot = !widget.hideChatbot && _isVisible;
    
    return Stack(
      children: [
        widget.child,
        if (shouldShowChatbot)
          Positioned(
            right: _x,
            bottom: _y,
            child: Draggable(
              feedback: FloatingChatbotButton(onLongPress: _toggleChatbotVisibility),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                  final size = MediaQuery.of(context).size;

                  setState(() {
                      _x = size.width - details.offset.dx - 60;  // 60은 버튼 크기
                      _y = size.height - details.offset.dy - 60;
                  });
              },
              child: FloatingChatbotButton(onLongPress: _toggleChatbotVisibility),
            ),
          ),
        // 챗봇이 숨겨졌을 때 다시 보이게 하는 작은 버튼 (hideChatbot이 false일 때만)
        if (!widget.hideChatbot && !_isVisible)
          Positioned(
            right: 10,
            bottom: 10,
            child: GestureDetector(
              onTap: _toggleChatbotVisibility,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        // 소개 메시지 말풍선 (챗봇이 표시되고 hideChatbot이 false일 때만)
        if (!widget.hideChatbot && shouldShowChatbot && _showIntroMessage)
          Positioned(
            right: _x + 70, // 챗봇 버튼 왼쪽에 위치
            bottom: _y + 10, // 챗봇 버튼과 비슷한 높이
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: MouseRegion(
                onEnter: (_) => _onBubbleHover(true),
                onExit: (_) => _onBubbleHover(false),
                child: GestureDetector(
                  onTap: () => _onBubbleHover(!_isHoveringBubble),
                  child: Stack(
                    children: [
                      // 말풍선 본체
                      Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF81C784),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      '궁금한게 있나요?\n지금 바로 소담이에게 물어보세요!',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                      // X 버튼 (호버 또는 클릭 상태일 때만 표시)
                      if (_isHoveringBubble)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: _hideIntroMessage,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close,
                                color: const Color(0xFF81C784),
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      // 말풍선 꼬리 (오른쪽으로 향하는 삼각형)
                      Positioned(
                        right: -8,
                        bottom: 12,
                        child: CustomPaint(
                          size: const Size(16, 16),
                          painter: SpeechBubbleTailPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// 말풍선 꼬리를 그리는 CustomPainter
class SpeechBubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF81C784)
      ..style = PaintingStyle.fill;

    final path = Path();
    // 더 자연스러운 말풍선 꼬리 모양
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.5, 0, size.height * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}