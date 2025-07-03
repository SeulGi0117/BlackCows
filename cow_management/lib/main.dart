import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'dart:io' show Platform;

// import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 삭제
import 'package:firebase_core/firebase_core.dart';

// Models
import 'models/cow.dart';
// Providers
import 'providers/cow_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/todo_provider.dart';
// Services
import 'services/todo_service.dart';
import 'services/dio_client.dart';
// 상세기록 Providers
import 'providers/DetailPage/Health/health_check_provider.dart';
import 'providers/DetailPage/Health/treatment_record_provider.dart';
import 'providers/DetailPage/Health/vaccination_record_provider.dart';
import 'providers/DetailPage/Health/weight_record_provider.dart';
import 'providers/DetailPage/breeding_record_provider.dart';
import 'providers/DetailPage/feeding_record_provider.dart';
import 'providers/DetailPage/milking_record_provider.dart';
import 'providers/DetailPage/Reproduction/calving_record_provider.dart';
import 'providers/DetailPage/Reproduction/estrus_record_provider.dart';
import 'providers/DetailPage/Reproduction/insemination_record_provider.dart';
import 'providers/DetailPage/Reproduction/pregnancy_check_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_page.dart';
import 'screens/onboarding/auth_selection_page.dart';
import 'screens/accounts/login.dart';
import 'screens/accounts/signup.dart';
import 'screens/home/home_page.dart';
import 'screens/cow_list/cow_list_page.dart';
import 'screens/cow_list/cow_detail_page.dart';

import 'screens/cow_list/cow_edit_page.dart';

import 'screens/profile/profile_page.dart';
import 'screens/notifications/notification_page.dart';
import 'screens/todo/todo_page.dart';
import 'screens/ai_chatbot/app_wrapper.dart';
import 'screens/ai_chatbot/chatbot_history_page.dart';
import 'screens/ai_analysis/analysis_page.dart';

import 'screens/cow_list/Cow_Detail//Milk/milk_add_page.dart';
import 'screens/cow_list/Cow_Detail//Milk/milk_list_page.dart';
import 'screens/cow_list/Cow_Detail//Milk/milk_detail_page.dart';

import 'screens/cow_list/Cow_Detail//Health/health_check_list_page.dart';
import 'screens/cow_list/Cow_Detail/Health/health_check_add_page.dart';

import 'screens/cow_list/Cow_Detail/Vaccination/vaccination_list_page.dart';
import 'screens/cow_list/Cow_Detail/Vaccination/vaccination_add_page.dart';

import 'screens/cow_list/Cow_Detail/Weight/weight_list_page.dart';
import 'screens/cow_list/Cow_Detail/Weight/weight_add_page.dart';

import 'screens/cow_list/Cow_Detail/Treatment/treatment_list_page.dart';
import 'screens/cow_list/Cow_Detail/Treatment/treatment_add_page.dart';

import 'screens/cow_list/Cow_Detail/Estrus/estrus_add_page.dart';
import 'screens/cow_list/Cow_Detail/Estrus/estrus_list_page.dart';

import 'screens/cow_list/Cow_Detail//Insemination/insemination_add_page.dart';
import 'screens/cow_list/Cow_Detail//Insemination/insemination_list_page.dart';

import 'screens/cow_list/Cow_Detail/Breeding/breeding_add_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Windows가 아니면 Firebase 초기화
  if (!kIsWeb && !Platform.isWindows) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase 초기화 실패: $e');
    }
  }

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.time}: ${record.level.name}: ${record.loggerName}: ${record.message}');
  });

  // DioClient 인스턴스 생성
  final dioClient = DioClient();
  // TodoService 인스턴스 생성
  final todoService = TodoService(dioClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CowProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // TodoProvider 추가
        ChangeNotifierProvider(create: (_) => TodoProvider(todoService)),
        // 상세기록 Providers
        ChangeNotifierProvider(create: (_) => HealthCheckProvider()),
        ChangeNotifierProvider(create: (_) => TreatmentRecordProvider()),
        ChangeNotifierProvider(create: (_) => VaccinationRecordProvider()),
        ChangeNotifierProvider(create: (_) => WeightRecordProvider()),
        ChangeNotifierProvider(create: (_) => BreedingRecordProvider()),
        ChangeNotifierProvider(create: (_) => FeedingRecordProvider()),
        ChangeNotifierProvider(create: (_) => MilkingRecordProvider()),
        ChangeNotifierProvider(create: (_) => CalvingRecordProvider()),
        ChangeNotifierProvider(create: (_) => EstrusRecordProvider()),
        ChangeNotifierProvider(create: (_) => InseminationRecordProvider()),
        ChangeNotifierProvider(create: (_) => PregnancyCheckProvider()),
      ],
      child: const SoDamApp(),
    ),
  );
}

class SoDamApp extends StatelessWidget {
  const SoDamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'BlackCows 젖소 관리',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ko', 'KR'),
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: const Color(0xFF4CAF50),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4CAF50),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            cardTheme: CardTheme(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFFE53E3E)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Color(0xFF4CAF50),
              unselectedItemColor: Color(0xFF9E9E9E),
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              elevation: 8,
            ),
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko', 'KR'),
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingPage(),
            '/auth_selection': (context) => const AuthSelectionPage(),
            '/main': (context) => const MainScaffold(),
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignupPage(),
            '/cows': (context) => const CowListPage(),
            '/analysis': (context) => const AnalysisPage(),
            '/profile': (context) => const ProfilePage(),
            '/cows/detail': (context) {
              final cow = ModalRoute.of(context)!.settings.arguments as Cow;
              return CowDetailPage(cow: cow);
            },
            '/cows/edit': (context) {
              final cow = ModalRoute.of(context)!.settings.arguments as Cow;
              return CowEditPage(cow: cow);
            },
            '/notifications': (context) => const NotificationPage(),
            '/todo': (context) => const TodoPage(),

            // 상세 기록 페이지
            '/milking-record-add': (context) {
              // 우유 기록 추가 (새 라우트 이름)
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, String>;
              return MilkingRecordPage(
                cowId: args['cowId']!,
                cowName: args['cowName']!,
              );
            },
            '/milking-records': (context) {
              // 우유 기록 조회
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              return MilkingRecordListPage(
                cowId: args['cowId'],
                cowName: args['cowName'],
              );
            },
            '/milking-record-detail': (context) =>
                const MilkingRecordDetailPage(),
            '/breeding-record': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, String>;
              return BreedingRecordAddPage(
                cowId: args['cowId']!,
                cowName: args['cowName']!,
              );
            },

            '/health-check/add': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              return HealthCheckAddPage(
                cowId: args['cowId'],
                cowName: args['cowName'],
              );
            },
            '/health-check/list': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              return HealthCheckListPage(
                cowId: args['cowId'],
                cowName: args['cowName'],
              );
            },
            '/vaccination/list': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              return VaccinationListPage(
                cowId: args['cowId'],
                cowName: args['cowName'],
              );
            },
            '/weight/list': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              return WeightListPage(
                cowId: args['cowId'],
                cowName: args['cowName'],
              );
            },
            '/treatment/list': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              return TreatmentListPage(
                cowId: args['cowId'],
                cowName: args['cowName'],
              );
            },

            '/treatment/add': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              return TreatmentAddPage(
                cowId: args['cowId'],
                cowName: args['cowName'],
              );
            },
            '/vaccination/add': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              return VaccinationAddPage(
                cowId: args['cowId'],
                cowName: args['cowName'],
              );
            },
            '/weight/add': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              return WeightAddPage(
                cowId: args['cowId'],
                cowName: args['cowName'],
              );
            },
            '/estrus-record/list': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, String>;
              return EstrusRecordListPage(
                cowId: args['cowId']!,
                cowName: args['cowName']!,
              );
            },
            '/estrus-record/add': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, String>;
              return EstrusAddPage(
                cowId: args['cowId']!,
                cowName: args['cowName']!,
              );
            },
            // 인공수정 기록 라우트
            '/insemination-record/list': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, String>;
              return InseminationRecordListPage(
                cowId: args['cowId']!,
                cowName: args['cowName']!,
              );
            },
            '/insemination-record/add': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, String>;
              return InseminationRecordAddPage(
                cowId: args['cowId']!,
                cowName: args['cowName']!,
              );
            },
          },
        );
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
    const AnalysisPage(),
    const ChatbotHistoryPage(),
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
        resizeToAvoidBottomInset: true,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: '젖소 관리'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'AI 분석'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: '챗봇'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
          ],
        ),
      ),
    );
  }
}
