import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/notification_provider.dart';
import 'package:cow_management/models/notification.dart';
import 'package:intl/intl.dart';
import 'package:cow_management/providers/cow_provider.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  String selectedType = '전체';

  final List<String> notificationTypes = [
    '전체',
    '할일',
    '젖소',
    '기록',
    '건강',
    '착유',
    '번식',
    '사료',
    '체중',
    '검사',
    '시스템',
    '통계',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<NotificationProvider>();
      provider.fetchNotifications();
    });
  }

  String getGroupByType(String type) {
    if (type.startsWith('TASK_')) return '할일';
    if (type.startsWith('COW_')) return '젖소';
    if (type.startsWith('RECORD_')) return '기록';
    if (type.contains('HEALTH') ||
        type.contains('VACCINATION') ||
        type.contains('TREATMENT')) return '건강';
    if (type.startsWith('MILKING_')) return '착유';
    if (type.contains('ESTRUS') ||
        type.contains('INSEMINATION') ||
        type.contains('PREGNANCY') ||
        type.contains('CALVING')) return '번식';
    if (type.startsWith('FEED_')) return '사료';
    if (type.startsWith('WEIGHT_')) return '체중';
    if (type.contains('BRUCELLA') || type.contains('TUBERCULOSIS')) return '검사';
    if (type.startsWith('SYSTEM_') ||
        type.startsWith('ACCOUNT_') ||
        type.startsWith('LOGIN_') ||
        type == 'WELCOME') return '시스템';
    if (type.endsWith('_SUMMARY') ||
        type == 'PERFORMANCE_ALERT' ||
        type == 'TREND_ANALYSIS') return '통계';
    return '기타';
  }

  bool isDoNotDisturb(DateTime dt) {
    final hour = dt.hour;
    return hour >= 22 || hour < 8;
  }

  Color getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return Colors.redAccent;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.low:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    final filteredNotifications = selectedType == '전체'
        ? notifications
        : notifications
            .where((n) => getGroupByType(n.type.name) == selectedType)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read_outlined),
            tooltip: '모두 읽음 처리',
            onPressed: () => provider.markAllAsRead(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: DropdownButton<String>(
              value: selectedType,
              isExpanded: true,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                }
              },
              items: notificationTypes
                  .map((type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNotifications.isEmpty
                    ? const Center(child: Text('알림이 없습니다'))
                    : ListView.builder(
                        itemCount: filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final notification = filteredNotifications[index];
                          return _buildNotificationTile(notification);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(AppNotification n) {
    final isUnread = n.status == NotificationStatus.unread;
    final formattedDate = DateFormat('yyyy.MM.dd HH:mm').format(n.createdAt);
    final isNight = isDoNotDisturb(n.createdAt);
    final priorityColor = getPriorityColor(n.priority);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isNight ? Colors.lightBlueAccent : Colors.transparent,
          width: isNight ? 1.5 : 0,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isUnread ? Colors.grey[200] : null,
      ),
      child: ListTile(
        leading: Icon(
          Icons.notifications_active,
          color: priorityColor,
        ),
        title: Text(
          n.title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${n.message}\n$formattedDate',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        onTap: () async {
          final notifier = context.read<NotificationProvider>();
          await notifier.markAsRead(n.id);

          final cowProvider = Provider.of<CowProvider>(context, listen: false);
          final cow = n.relatedCowId != null
              ? cowProvider.getCowById(n.relatedCowId!)
              : null;

          if (cow != null) {
            Navigator.pushNamed(context, '/cows/detail', arguments: cow);
          } else if (n.relatedTaskId != null) {
            Navigator.pushNamed(
              context,
              '/todo/detail',
              arguments: {'taskId': n.relatedTaskId},
            );
          } else if (n.relatedRecordId != null) {
            Navigator.pushNamed(
              context,
              '/record/detail',
              arguments: {'recordId': n.relatedRecordId},
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("이 알림에 연결된 상세 항목이 없습니다")),
            );
          }
        },
      ),
    );
  }
}
