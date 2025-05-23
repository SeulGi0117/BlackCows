import 'package:flutter/material.dart';


void main() => runApp(const SoDamApp());

class SoDamApp extends StatelessWidget {
  const SoDamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // 전체 화면 스크롤
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildCowStatusChartCard(), // 소 상태 요약
              _buildAIPredictionSummary(), // AI 예측
              _buildReminderList(), // 태그 버튼
              _buildTaskList(context), // context 전달
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}

Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/cow.png',
              width: 36,
              height: 36,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 36);
              },
            ),
            const SizedBox(width: 12),
            const Text(
              '소담소담',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            const Icon(Icons.notifications_none, size: 28),
            Positioned(
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ],
        )
      ],
    ),
  );
}

Widget _buildCowStatusChartCard() {
  final statusSummary = [
    {'label': '정상', 'count': 10, 'color': Colors.green},
    {'label': '주의', 'count': 3, 'color': Colors.orange},
    {'label': '이상', 'count': 1, 'color': Colors.red},
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '소 상태 요약',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: statusSummary.map((item) {
              return Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '${item['count']}두',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}

class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _FakeBarChart extends StatelessWidget {
  final List<double> values = [200, 400, 300, 600, 500, 350];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: values.map((value) {
          return Container(
            width: 20,
            height: value / 6, // 비율 조절
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }).toList(),
      ),
    );
  }
}

Widget _buildAIPredictionSummary() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 도넛 느낌 퍼센트
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 0.78, // 78% 정상
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.pink,
                ),
              ),
              const Text(
                '78%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // 텍스트 정보
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 예측 결과',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.search, size: 18, color: Colors.black87),
                    SizedBox(width: 6),
                    Text('의심 소: 1두 (C384)', style: TextStyle(fontSize: 14)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: Colors.green),
                    SizedBox(width: 6),
                    Text('정상: 78%', style: TextStyle(fontSize: 14)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 18, color: Colors.orange),
                    SizedBox(width: 6),
                    Text('주의: 3두', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildReminderList() {
  final List<String> tags = ['To do', 'Doing', 'Done', 'Emergency', 'Checkup'];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags.map((tag) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}

Widget _buildTaskList(BuildContext context) {
  final List<Map<String, dynamic>> tasks = [
    {
      'title': '우유 착유 일정 확인',
      'subtitle': '오전 10:00까지',
      'done': false,
    },
    {
      'title': '질병 진단 제출',
      'subtitle': 'D+1까지 보고',
      'done': true,
    },
    {
      'title': '환경 센서 확인',
      'subtitle': '오늘 온도: 28°C',
      'done': false,
    },
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
    child: Column(
      children: [
        ...tasks.map((task) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  task['done']
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task['done'] ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task['subtitle'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        // "나의 소 목록 불러오기" 버튼 추가
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CowListScreen(),
                ),
              );
            },
            child: const Text(
              '나의 소 목록 불러오기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildBottomNav() {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed, // 아이콘 4개 이상일 때 고정
    currentIndex: 0, // 선택된 인덱스 (현재는 고정값)
    onTap: (index) {
      // TODO: 상태로 이동 로직 구현 가능
    },
    selectedItemColor: Colors.pink,
    unselectedItemColor: Colors.grey,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: '홈',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: '할 일',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.pie_chart),
        label: '분석',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: '내 정보',
      ),
    ],
  );
}
