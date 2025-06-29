import 'package:flutter/material.dart';
import 'package:cow_management/widgets/modern_card.dart';
import 'package:cow_management/widgets/loading_widget.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  final List<String> _filterOptions = ['전체', '건강', '번식', '백신', '착유', '치료', '시스템'];
  String _selectedFilter = '전체';
  List<Map<String, dynamic>> _notifications = [];
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _initializeNotifications();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeNotifications() {
    final now = DateTime.now();
    _notifications = [
      {
        'type': '건강',
        'title': '콩돌이 건강 검진 필요',
        'message': '마지막 건강 검진일로부터 30일이 경과했습니다. 정기 건강 검진을 받아주세요.',
        'time': now.subtract(const Duration(minutes: 5)),
        'isRead': false,
      },
      {
        'type': '번식',
        'title': '꽃분이 발정 감지',
        'message': '꽃분이가 발정기에 들어간 것으로 보입니다. 인공수정을 고려해보세요.',
        'time': now.subtract(const Duration(hours: 2)),
        'isRead': false,
      },
      {
        'type': '백신',
        'title': '구제역 백신 접종일 임박',
        'message': '농장 내 젖소들의 구제역 백신 접종일이 3일 남았습니다.',
        'time': now.subtract(const Duration(hours: 4)),
        'isRead': true,
      },
      {
        'type': '착유',
        'title': '착유량 급감 알림',
        'message': '별님이의 어제 착유량이 평균 대비 15% 감소했습니다.',
        'time': now.subtract(const Duration(hours: 8)),
        'isRead': false,
      },
      {
        'type': '치료',
        'title': '대장이 치료 완료',
        'message': '대장이의 유방염 치료가 완료되었습니다. 경과를 관찰해주세요.',
        'time': now.subtract(const Duration(days: 1)),
        'isRead': true,
      },
      {
        'type': '시스템',
        'title': '앱 업데이트 알림',
        'message': '새로운 기능이 추가된 버전이 출시되었습니다. 업데이트해주세요.',
        'time': now.subtract(const Duration(days: 2)),
        'isRead': false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: ModernAppBar(
        title: '알림',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'read_all':
                  _markAllAsRead();
                  break;
                case 'clear_all':
                  _clearAllNotifications();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, color: Color(0xFF4CAF50)),
                    SizedBox(width: 8),
                    Text('모두 읽음 처리'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('모든 알림 삭제'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildFilterChips(),
            _buildNotificationStats(),
            Expanded(
              child: _buildNotificationList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = option == _selectedFilter;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = option;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
              checkmarkColor: const Color(0xFF4CAF50),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildNotificationStats() {
    final totalNotifications = _notifications.length;
    final unreadCount = _notifications.where((n) => !n['isRead']).length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ModernCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '총 알림',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalNotifications개',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '읽지 않음',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$unreadCount개',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationList() {
    final notifications = _getFilteredNotifications();
    
    if (notifications.isEmpty) {
      return const Center(
        child: ModernEmptyWidget(
          title: '알림이 없습니다',
          message: '선택한 필터에 해당하는 알림이 없습니다.',
          icon: Icons.notifications_off,
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification, index);
      },
    );
  }
  
  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ModernCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getNotificationColor(notification['type']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getNotificationIcon(notification['type']),
              color: _getNotificationColor(notification['type']),
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: notification['isRead'] ? FontWeight.w500 : FontWeight.bold,
                    color: const Color(0xFF2E3A59),
                  ),
                ),
              ),
              if (!notification['isRead'])
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification['message'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification['type']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      notification['type'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getNotificationColor(notification['type']),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getTimeAgo(notification['time']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () => _markAsRead(index),
        ),
      ),
    );
  }
  
  List<Map<String, dynamic>> _getFilteredNotifications() {
    if (_selectedFilter == '전체') {
      return _notifications;
    }
    return _notifications.where((n) => n['type'] == _selectedFilter).toList();
  }
  
  Color _getNotificationColor(String type) {
    switch (type) {
      case '건강':
        return const Color(0xFF4CAF50);
      case '번식':
        return const Color(0xFF2196F3);
      case '백신':
        return const Color(0xFF9C27B0);
      case '착유':
        return const Color(0xFFFF9800);
      case '치료':
        return const Color(0xFFE53E3E);
      case '시스템':
        return const Color(0xFF607D8B);
      default:
        return Colors.grey;
    }
  }
  
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case '건강':
        return Icons.favorite;
      case '번식':
        return Icons.pregnant_woman;
      case '백신':
        return Icons.vaccines;
      case '착유':
        return Icons.opacity;
      case '치료':
        return Icons.medical_services;
      case '시스템':
        return Icons.system_update;
      default:
        return Icons.notifications;
    }
  }
  
  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${time.month}/${time.day}';
    }
  }
  
  void _markAsRead(int index) {
    setState(() {
      final filteredNotifications = _getFilteredNotifications();
      if (index < filteredNotifications.length) {
        final originalIndex = _notifications.indexOf(filteredNotifications[index]);
        if (originalIndex != -1) {
          _notifications[originalIndex]['isRead'] = true;
        }
      }
    });
  }
  
  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('모든 알림을 읽음 처리했습니다.'),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('알림 삭제'),
        content: const Text('모든 알림을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('모든 알림이 삭제되었습니다.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
  
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '알림 필터',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 20),
            ...(_filterOptions.map((option) => ListTile(
              leading: Radio<String>(
                value: option,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
                activeColor: const Color(0xFF4CAF50),
              ),
              title: Text(option),
              onTap: () {
                setState(() {
                  _selectedFilter = option;
                });
                Navigator.pop(context);
              },
            ))),
          ],
        ),
      ),
    );
  }
} 