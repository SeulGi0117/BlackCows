import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

import 'package:cow_management/models/cow.dart';
import 'package:cow_management/models/Detail/feeding_record.dart';
import 'package:cow_management/models/Detail/Health/vaccination_record.dart';
import 'package:cow_management/models/Detail/Health/treatment_record.model.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';

import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/cow_provider.dart';
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
import 'package:cow_management/screens/ai_chatbot/app_wrapper.dart';
import 'package:cow_management/screens/ai_chatbot/chatbot_history_page.dart';

import 'package:cow_management/screens/ai_chatbot/app_wrapper.dart';
import 'package:cow_management/screens/ai_chatbot/chatbot_history_page.dart';

import 'package:cow_management/screens/accounts/login.dart';
import 'package:cow_management/screens/accounts/signup.dart';

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

import 'package:cow_management/screens/cow_list/Cow_Detail/Reproduction/insemination_list_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Reproduction/insemination_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Reproduction/pregnancy_check_list_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Reproduction/pregnancy_check_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Reproduction/calving_record_list_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Reproduction/calving_record_add_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config/.env");

  // 로깅 설정
  Logger.root.level = Level.ALL; // 모든 로그 레벨 허용
  Logger.root.onRecord.listen((record) {
    print(
        '${record.time}: ${record.level.name}: ${record.loggerName}: ${record.message}');
  });

  // 테스트 모드 설정
  const bool isTestMode = false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CowProvider()),
        ChangeNotifierProvider(create: (_) => BreedingRecordProvider()),
        ChangeNotifierProvider(create: (_) => MilkingRecordProvider()),
        ChangeNotifierProvider(create: (_) => HealthCheckProvider()),
        ChangeNotifierProvider(create: (_) => VaccinationRecordProvider()),
        ChangeNotifierProvider(create: (_) => FeedingRecordProvider()),
        ChangeNotifierProvider(create: (_) => WeightRecordProvider()),
        ChangeNotifierProvider(create: (_) => TreatmentRecordProvider()),
        ChangeNotifierProvider(create: (_) => EstrusRecordProvider()),
        ChangeNotifierProvider(create: (_) => InseminationRecordProvider()),
        ChangeNotifierProvider(create: (_) => PregnancyCheckProvider()),
        ChangeNotifierProvider(create: (_) => CalvingRecordProvider()),
      ],
      child: const SoDamApp(isTestMode: isTestMode),
    ),
  );
}

class SoDamApp extends StatelessWidget {
  final bool isTestMode;
  const SoDamApp({super.key, this.isTestMode = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ko', 'KR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
        ],
        initialRoute: '/', // 시작 루트를 스플래시로 변경
        routes: {
          '/': (context) => const SplashScreen(), // 스플래시 화면
          '/main': (context) => const MainScaffold(), // 메인 홈
          '/login': (context) => LoginPage(isTestMode: isTestMode), // 로그인
          '/signup': (context) => const SignupPage(), // 회원가입
          '/cows': (context) => const CowListPage(), // 소 목록
          '/analysis': (context) => const AnalysisPage(), // AI 분석
          '/profile': (context) => const ProfilePage(), // 프로필
          '/cows/detail': (context) {
            final cow = ModalRoute.of(context)!.settings.arguments as Cow;
            return CowDetailPage(cow: cow);
          },
          '/cows/edit': (context) {
            // 기본 정보 수정
            final cow = ModalRoute.of(context)!.settings.arguments as Cow;
            return CowEditPage(cow: cow);
          },
          '/milking-record': (context) {
            // 우유 기록 추가
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>;
            return MilkingRecordPage(
              cowId: args['cowId']!,
              cowName: args['cowName']!,
            );
          },
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
          '/breeding-records': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>;
            return BreedingRecordListPage(
              cowId: args['cowId']!,
              cowName: args['cowName']!,
            );
          },

          '/breeding-record-detail': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return BreedingRecordDetailPage(record: args['record']);
          },
          '/health-check/add': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;
            return HealthCheckAddPage(
              cowId: args['cowId'],
              cowName: args['cowName'],
            );
          },
          '/health-check/detail': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;
            return HealthCheckDetailPage(
              record: args['record'],
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
          '/treatment/detail': (context) {
            final record = ModalRoute.of(context)!.settings.arguments as TreatmentRecord;
            return TreatmentDetailPage(record: record);
          },

          '/vaccination/add': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;
            return VaccinationAddPage(
              cowId: args['cowId'],
              cowName: args['cowName'],
            );
          },
          '/vaccination/detail': (context) {
            final record = ModalRoute.of(context)!.settings.arguments as VaccinationRecord;
            return VaccinationDetailPage(record: record);
          },

          '/feeding-record/list': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;
            return FeedingRecordListPage(
              cowId: args['cowId'],
              cowName: args['cowName'],
            );
          },
          '/feeding-record/add': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;
            return FeedingRecordAddPage(
              cowId: args['cowId'],
              cowName: args['cowName'],
            );
          },

          '/feeding-record/detail': (context) {
            final record =
                ModalRoute.of(context)!.settings.arguments as FeedingRecord;
            return FeedingRecordDetailPage(record: record);
          },
          '/weight/add': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;
            return WeightAddPage(
              cowId: args['cowId'],
              cowName: args['cowName'],
            );
          },
          '/weight/detail': (context) {
            final record = ModalRoute.of(context)!.settings.arguments as WeightRecord;
            return WeightDetailPage(record: record);
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
          // 임신감정 기록 라우트
          '/pregnancy-check/list': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>;
            return PregnancyCheckListPage(
              cowId: args['cowId']!,
              cowName: args['cowName']!,
            );
          },
          '/pregnancy-check/add': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>;
            return PregnancyCheckAddPage(
              cowId: args['cowId']!,
              cowName: args['cowName']!,
            );
          },
          // 분만 기록 라우트
          '/calving-record/list': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>;
            return CalvingRecordListPage(
              cowId: args['cowId']!,
              cowName: args['cowName']!,
            );
          },
          '/calving-record/add': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>;
            return CalvingRecordAddPage(
              cowId: args['cowId']!,
              cowName: args['cowName']!,
            );
          },
        });
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
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: '소 관리'),
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
