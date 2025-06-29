import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Models
import 'models/cow.dart';

// Providers
import 'providers/cow_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Flutter Web에서는 .env 파일을 로드하지 않음
  if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CowProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'BlackCows 젖소 관리',
            debugShowCheckedModeBanner: false,
            locale: const Locale('ko', 'KR'),
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4CAF50),
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4CAF50),
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(0xFF2A2A2A),
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
                titleLarge: TextStyle(color: Colors.white),
                titleMedium: TextStyle(color: Colors.white),
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
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                // 온보딩 및 인증
                case '/onboarding':
                  return MaterialPageRoute(
                    builder: (context) => const OnboardingPage(),
                  );
                case '/auth_selection':
                  return MaterialPageRoute(
                    builder: (context) => const AuthSelectionPage(),
                  );
                case '/login':
                  return MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  );
                case '/signup':
                  return MaterialPageRoute(
                    builder: (context) => const SignupPage(),
                  );
                case '/find_user_id':
                  return MaterialPageRoute(
                    builder: (context) => const FindUserIdPage(),
                  );
                case '/find_password':
                  return MaterialPageRoute(
                    builder: (context) => const FindPasswordPage(),
                  );
                
                // 메인 화면들
                case '/home':
                  return MaterialPageRoute(
                    builder: (context) => const AppWrapper(child: HomeScreen()),
                  );
                case '/cow_list':
                  return MaterialPageRoute(
                    builder: (context) => const AppWrapper(child: CowListPage()),
                  );
                case '/profile':
                  return MaterialPageRoute(
                    builder: (context) => const AppWrapper(child: ProfilePage()),
                  );
                case '/notifications':
                  return MaterialPageRoute(
                    builder: (context) => const AppWrapper(child: NotificationPage()),
                  );
                case '/todo':
                  return MaterialPageRoute(
                    builder: (context) => const AppWrapper(child: TodoPage()),
                  );
                
                // 젖소 관련
                case '/cow_add':
                  return MaterialPageRoute(
                    builder: (context) => const CowAddPage(),
                  );
                case '/cow_registration_flow':
                  return MaterialPageRoute(
                    builder: (context) => const CowRegistrationFlowPage(),
                  );
                case '/cow_detail':
                  final cow = settings.arguments as Cow?;
                  if (cow != null) {
                    return MaterialPageRoute(
                      builder: (context) => CowDetailPage(cow: cow),
                    );
                  }
                  return MaterialPageRoute(
                    builder: (context) => const CowListPage(),
                  );
                case '/cow_edit':
                  final cow = settings.arguments as Cow?;
                  if (cow != null) {
                    return MaterialPageRoute(
                      builder: (context) => CowEditPage(cow: cow),
                    );
                  }
                  return MaterialPageRoute(
                    builder: (context) => const CowListPage(),
                  );
                case '/cow_detailed_records':
                  final cow = settings.arguments as Cow?;
                  if (cow != null) {
                    return MaterialPageRoute(
                      builder: (context) => CowDetailedRecordsPage(cow: cow),
                    );
                  }
                  return MaterialPageRoute(
                    builder: (context) => const CowListPage(),
                  );
                
                // AI 챗봇
                case '/chatbot_history':
                  return MaterialPageRoute(
                    builder: (context) => const ChatbotHistoryPage(),
                  );
                
                default:
                  return MaterialPageRoute(
                    builder: (context) => const SplashScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
} 