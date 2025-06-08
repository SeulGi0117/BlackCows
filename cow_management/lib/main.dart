import 'package:cow_management/screens/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/screens/accounts/login.dart';
import 'package:cow_management/screens/cow_list/cow_list_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/screens/accounts/signup.dart';
import 'package:cow_management/screens/cow_list/cow_detail_page.dart';
import 'package:cow_management/models/cow.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CowProvider()),
      ],
      child: const SoDamApp(),
    ),
  );
}

class SoDamApp extends StatelessWidget {
  const SoDamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // 시작 루트
      routes: {
        '/': (context) => const MainScaffold(), // 메인 홈
        '/login': (context) => const LoginPage(), // 로그인
        '/signup': (context) => const SignupPage(), // 회원가입
        '/cows': (context) => const CowListPage(), // 소 목록
        '/analysis': (context) =>
            const Center(child: Text('분석 페이지')), // 분석 페이지 미구현
        '/profile': (context) => const ProfilePage(), // 프로필필
        '/cows/detail': (context) {
          final cow = ModalRoute.of(context)!.settings.arguments as Cow;
          return CowDetailPage(cow: cow);
        },
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const CowListPage(),
    const Center(child: Text('분석 페이지')), // 아직 미구현
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '소 관리'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: '분석'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
        ],
      ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildCowStatusChartCard(), // 소 상태 요약
              _buildAIPredictionSummary(), // AI 예측
              _buildFavoriteCows(context), // context 전달
            ],
          ),
        ),
      ),
    );
  }
}

// 나머지 _buildHeader(), _buildCowStatusChartCard(), _buildAIPredictionSummary(), _buildReminderList(), _buildTaskList() 함수는 동일하게 유지해도 됩니다.

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

Widget _buildFavoriteCows(BuildContext context) {
  final cowProvider = Provider.of<CowProvider>(context);
  final favorites = cowProvider.favorites;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '즐겨찾는 소',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (favorites.isEmpty)
          const Text('즐겨찾기한 소가 없어요!')
        else
          ...favorites.map((cow) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/cows/detail', arguments: cow);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        cow.isFavorite ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        cowProvider.toggleFavorite(cow);
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cow.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '품종: ${cow.breed}, 상태: ${cow.status}',
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
              ),
            );
          }),
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
              Navigator.pushNamed(context, '/cows');
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
    onTap: (index) {},
    selectedItemColor: Colors.pink,
    unselectedItemColor: Colors.grey,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: '홈',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: '소 관리',
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
