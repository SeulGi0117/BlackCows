import 'package:flutter/material.dart';
import 'chatbot_quick_core.dart'; // 분리한 대화 UI

class ChatbotHistoryPage extends StatefulWidget {
  const ChatbotHistoryPage({super.key});

  @override
  State<ChatbotHistoryPage> createState() => _ChatbotHistoryPageState();
}

class _ChatbotHistoryPageState extends State<ChatbotHistoryPage> {
  bool _isSidebarOpen = true;

  final List<String> _chatSessions = [
    '오늘 오전 상담',
    '어제 저녁 기록',
    '6월 15일 대화',
  ];

  int _selectedSessionIndex = 0;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = _isSidebarOpen ? 200.0 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('소담소담 상담 챗봇'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            _isSidebarOpen ? Icons.close_fullscreen : Icons.history_toggle_off,
          ),
          tooltip: _isSidebarOpen ? '기록 닫기' : '기록 열기',
          onPressed: _toggleSidebar,
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: sidebarWidth,
              color: Colors.grey[100],
              child: _isSidebarOpen
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            '채팅 기록',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _chatSessions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_chatSessions[index]),
                                selected: index == _selectedSessionIndex,
                                onTap: () {
                                  setState(() {
                                    _selectedSessionIndex = index;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            if (_isSidebarOpen) const VerticalDivider(width: 1),
            const Expanded(
              child: ChatbotQuickCore(),
            ),
          ],
        ),
      ),
    );
  }
}
