import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';

// 웹이 아닐 때만 import
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:firebase_core/firebase_core.dart';

// Models
import 'models/cow.dart';

// Providers
import 'providers/cow_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
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
import 'screens/accounts/find_user_id_page.dart';
import 'screens/accounts/find_password_page.dart';
import 'screens/home/home_page.dart';
import 'screens/cow_list/cow_list_page.dart';
import 'screens/cow_list/cow_detail_page.dart';
import 'screens/cow_list/cow_add_page.dart';
import 'screens/cow_list/cow_edit_page.dart';
import 'screens/cow_list/cow_registration_flow_page.dart';
import 'screens/cow_list/cow_detailed_records_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/notifications/notification_page.dart';
import 'screens/todo/todo_page.dart';
import 'screens/ai_chatbot/app_wrapper.dart';
import 'screens/ai_chatbot/chatbot_history_page.dart';
import 'screens/ai_analysis/analysis_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: "assets/config/.env");
    } catch (e) {
      print('dotenv 로드 실패: $e');
    }
    
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase 초기화 실패: $e');
    }
    
    try {
      KakaoSdk.init(
        nativeAppKey: '40bba826862b5b1107aec5179bdbcb81',
      );
    } catch (e) {
      print('Kakao SDK 초기화 실패: $e');
    }
  }
  
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.time}: ${record.level.name}: ${record.loggerName}: ${record.message}');
  });
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CowProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
          title: 'BlackCows 젖소 관리',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ko', 'KR'),
          themeMode: themeProvider.themeMode,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4CAF50),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1A1A1A),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            cardTheme: CardTheme(
              color: const Color(0xFF232323),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF232323),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF444444)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF444444)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFFE53E3E)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Color(0xFF4CAF50),
              unselectedItemColor: Color(0xFF9E9E9E),
              backgroundColor: Color(0xFF232323),
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
            BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'AI예측'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: '챗봇'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
          ],
        ),
      ),
    );
  }
} 