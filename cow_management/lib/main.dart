import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/cow_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_page.dart';
import 'screens/ai_chatbot/app_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
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
                case '/onboarding':
                  return MaterialPageRoute(
                    builder: (context) => const OnboardingPage(),
                  );
                case '/app':
                  return MaterialPageRoute(
                    builder: (context) => const AppWrapper(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (context) => const SplashScreen(),
                  );
              }
            },
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
} 