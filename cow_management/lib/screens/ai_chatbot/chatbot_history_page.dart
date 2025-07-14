// chatbot_history_page.dart
import 'package:flutter/material.dart';
import 'package:cow_management/services/chatbot_api.dart';
import 'package:cow_management/screens/ai_chatbot/chatbot_quick_core.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class ChatbotHistoryPage extends StatefulWidget {
  const ChatbotHistoryPage({super.key});

  @override
  State<ChatbotHistoryPage> createState() => _ChatbotHistoryPageState();
}

class _ChatbotHistoryPageState extends State<ChatbotHistoryPage> {
  List<Map<String, dynamic>> _chatRooms = [];
  bool _isLoading = true;
  String? _selectedChatId;
  
  // 사이드바 상태 관리
  bool _isSidebarVisible = false;
  double _sidebarWidth = 200.0;
  double _minSidebarWidth = 150.0;
  double _maxSidebarWidth = 280.0;
  bool _isResizing = false;

  @override
  void initState() {
    super.initState();
    _initializeChatbot();
  }

  Future<void> _initializeChatbot() async {
    // 만료된 채팅방 자동 삭제 후 채팅방 목록 불러오기
    await deleteExpiredChatRooms();
    await _fetchChatRooms();
  }

  Future<void> _fetchChatRooms() async {
    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.userId;
    print("🔥 userId: $userId");
    if (userId == null) return;

    final rooms = await getChatRoomList(userId);
    setState(() {
      _chatRooms = rooms;
      _isLoading = false;
    });
  }

  Future<void> _createNewChatRoom() async {
    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.userId;
    if (userId == null) return;

    final newChatId = await createChatRoom(userId);
    if (newChatId != null) {
      await _fetchChatRooms();
      setState(() {
        _selectedChatId = newChatId;
      });
    }
  }

  Future<void> _deleteChatRoom(String chatId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("삭제 확인"),
        content: const Text("이 채팅방을 삭제할까요?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제")),
        ],
      ),
    );

    if (confirm == true) {
      await deleteChatRoom(chatId);
      await _fetchChatRooms();
      if (_selectedChatId == chatId) {
        setState(() => _selectedChatId = null);
      }
    }
  }

  Future<void> _renameChatRoom(String chatId, String currentName) async {
    final TextEditingController nameController = TextEditingController(text: currentName);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit, color: Colors.grey.shade400, size: 20),
            ),
            const SizedBox(width: 12),
            const Text("채팅방 이름 변경"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: '새로운 채팅방 이름',
                hintText: '예: 젖소 질문, 건강 검진 문의',
                prefixIcon: const Icon(Icons.chat_bubble_outline),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              autofocus: true,
              maxLength: 30,
              onSubmitted: (value) {
                final newName = value.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context, newName);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              "현재 이름: $currentName",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(context, newName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('채팅방 이름을 입력해주세요.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("변경"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final success = await updateChatRoomName(chatId, result);
      
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('채팅방 이름이 변경되었습니다.'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        await _fetchChatRooms();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Text('채팅방 이름 변경에 실패했습니다.'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  String _formatDate(String iso) {
    final date = DateTime.parse(iso);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _getChatRoomName(Map<String, dynamic> chat) {
    // name 필드가 있으면 사용, 없으면 기본 이름 생성
    final name = chat['name'];
    if (name != null && name.isNotEmpty) {
      return name;
    }
    
    // 기본 이름: 생성 날짜 기반으로 생성
    final createdAt = chat['created_at'];
    if (createdAt != null) {
      final date = DateTime.parse(createdAt);
      final formattedDate = '${date.month}/${date.day}';
      final formattedTime = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return "채팅 $formattedDate $formattedTime";
    }
    
    // 최후의 수단: 인덱스 기반
    final index = _chatRooms.indexOf(chat);
    return "채팅 ${index + 1}";
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("AI 챗봇 소담이"),
          automaticallyImplyLeading: false,  // 뒤로가기 버튼 제거
        ),
        body: Row(
          children: [
            // ⬅ 사이드바 확장형
            if (_isSidebarVisible)
              Container(
                width: _sidebarWidth,
                color: Colors.grey.shade300,
                child: Column(
                  children: [
                    // 헤더
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '채팅 기록',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.menu_open),
                            tooltip: "채팅방 목록 숨기기",
                            onPressed: _toggleSidebar,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_comment_outlined),
                            tooltip: "새 채팅 시작",
                            onPressed: _createNewChatRoom,
                          ),
                        ],
                      ),
                    ),
                    // 채팅방 목록
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _chatRooms.isEmpty
                              ? const Center(child: Text("채팅방이 없습니다"))
                              : ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: _chatRooms.length,
                                  itemBuilder: (context, index) {
                                    final chat = _chatRooms[index];
                                    final chatId = chat['chat_id'];
                                    final createdAt = _formatDate(chat['created_at']);
                                    final chatName = _getChatRoomName(chat);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                        color: _selectedChatId == chatId
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () => setState(() {
                                          _selectedChatId = chatId;
                                          _isSidebarVisible = false; // 채팅방 선택 시 사이드바 닫기
                                        }),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      chatName,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.grey.shade800,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      createdAt,
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.edit, size: 16, color: Colors.indigo.shade400),
                                                tooltip: "이름 변경",
                                                onPressed: () => _renameChatRoom(chatId, chatName),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete, size: 16, color: Colors.red.shade400),
                                                tooltip: "삭제",
                                                onPressed: () => _deleteChatRoom(chatId),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              )
            else
              // ⬅ 축소된 사이드바 (세로 아이콘 2개)
              Container(
                width: 48,
                color: Colors.grey.shade300,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    IconButton(
                      icon: const Icon(Icons.menu, size: 20),
                      tooltip: "채팅방 목록 열기",
                      onPressed: _toggleSidebar,
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.add_comment_outlined, size: 20),
                      tooltip: "새 채팅 시작",
                      onPressed: _createNewChatRoom,
                    ),
                  ],
                ),
              ),

            const VerticalDivider(width: 1),

            // 🟨 오른쪽 챗봇 대화 영역
            Expanded(
              child: _selectedChatId == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _isSidebarVisible
                                  ? "채팅방을 선택하여 대화를 이어나가거나 새로 시작해보세요!"
                                  : "채팅방 목록을 열어서 대화를 이어나가거나 새로 시작해보세요!",
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ChatbotQuickCore(
                      key: ValueKey(_selectedChatId),
                      chatId: _selectedChatId!,
                    ),
                    
            ),
          ],
        ),
      ),
    );
  }
}