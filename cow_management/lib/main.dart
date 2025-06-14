import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/screens/accounts/login.dart';
import 'package:cow_management/screens/accounts/signup.dart';
import 'package:cow_management/screens/home/home_page.dart';
import 'package:cow_management/screens/profile/profile_page.dart';
import 'package:cow_management/screens/cow_list/cow_list_page.dart';
import 'package:cow_management/screens/cow_list/cow_detail_page.dart';
import 'package:cow_management/models/cow.dart';
import 'package:cow_management/widgets/app_wrapper.dart';
import 'package:cow_management/widgets/floating_chatbot_button.dart';
import 'package:cow_management/screens/cow_list/cow_edit_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config/.env");
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
      locale: const Locale('ko', 'KR'),
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
        '/cows/edit': (context) {
          final cow = ModalRoute.of(context)!.settings.arguments as Cow;
          return CowEditPage(cow: cow);
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
    return AppWrapper(
      child: Scaffold(
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
      ),
    );
  }
}
