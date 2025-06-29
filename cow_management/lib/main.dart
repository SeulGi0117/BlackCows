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
import 'utils/error_utils.dart';

import 'package:logging/logging.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:cow_management/models/cow.dart';
import 'package:cow_management/models/Detail/feeding_record.dart';
import 'package:cow_management/models/Detail/Health/vaccination_record.dart';
import 'package:cow_management/models/Detail/Health/treatment_record_model.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';

import 'package:cow_management/providers/DetailPage/breeding_record_provider.dart';
import 'package:cow_management/providers/DetailPage/milking_record_provider.dart';
import 'package:cow_management/providers/DetailPage/Health/health_check_provider.dart';
import 'package:cow_management/providers/DetailPage/Health/vaccination_record_provider.dart';
import 'package:cow_management/providers/DetailPage/feeding_record_provider.dart';
import 'package:cow_management/providers/DetailPage/Health/weight_record_provider.dart';
import 'package:cow_management/providers/DetailPage/Health/treatment_record_provider.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/estrus_record_provider.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/insemination_record_provider.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/pregnancy_check_provider.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/calving_record_provider.dart';

import 'package:cow_management/screens/ai_analysis/analysis_page.dart';
import 'package:cow_management/screens/ai_chatbot/chatbot_history_page.dart';

import 'package:cow_management/screens/accounts/login.dart';
import 'package:cow_management/screens/accounts/signup.dart';
import 'package:cow_management/screens/onboarding/auth_selection_page.dart';

import 'package:cow_management/screens/home/home_page.dart';

import 'package:cow_management/screens/profile/profile_page.dart';

import 'package:cow_management/screens/cow_list/cow_list_page.dart';
import 'package:cow_management/screens/cow_list/cow_detail_page.dart';
import 'package:cow_management/screens/cow_list/cow_edit_page.dart';

import 'package:cow_management/screens/cow_list/Cow_Detail/Milk/milk_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Milk/milk_list_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Milk/milk_detail_page.dart';

import 'package:cow_management/screens/cow_list/Cow_Detail/Breeding/breeding_list_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Breeding/breeding_detail_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Breeding/breeding_add_page.dart';

import 'package:cow_management/screens/cow_list/Cow_Detail/Health/health_check_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Health/health_check_detail_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Health/health_check_list_page.dart';

import 'package:cow_management/screens/cow_list/Cow_Detail/Vaccination/vaccination_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Vaccination/vaccination_detail_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Vaccination/vaccination_list_page.dart';

import 'package:cow_management/screens/cow_list/Cow_Detail/Feeding/feeding_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Feeding/feeding_list_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Feeding/feeding_detail_page.dart';

import 'package:cow_management/screens/splash_screen.dart';

import 'package:cow_management/screens/cow_list/Cow_Detail/Weight/weight_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Weight/weight_list_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Weight/weight_detail_page.dart';

import 'package:cow_management/screens/cow_list/Cow_Detail/Treatment/treatment_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Treatment/treatment_list_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Treatment/treatment_detail_page..dart';

import 'package:cow_management/screens/cow_list/Cow_Detail/Estrus/estrus_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Estrus/estrus_list_page.dart';

import 'package:cow_management/screens/cow_list/Cow_Detail/Insemination/insemination_list_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Insemination/insemination_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Pregnancy/pregnancy_check_list_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Pregnancy/pregnancy_check_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Calving/calving_record_list_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Calving/calving_record_add_page.dart';

Future<void> main() async {
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
        builder: (context, themeProvider, child) {
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
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

