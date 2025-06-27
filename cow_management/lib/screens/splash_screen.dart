import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/main.dart';
import 'package:cow_management/screens/accounts/login.dart';
import 'package:logging/logging.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _logger = Logger('SplashScreen');

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      _logger.info('스플래시 화면 시작 - 자동 로그인 확인');
      
      // 최소 1초는 스플래시 화면을 보여줌
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final cowProvider = Provider.of<CowProvider>(context, listen: false);
      
      final autoLoginFuture = userProvider.checkAutoLogin();
      final delayFuture = Future.delayed(const Duration(seconds: 1));
      
      final results = await Future.wait([autoLoginFuture, delayFuture]);
      final isLoggedIn = results[0] as bool;

      if (!mounted) return;

      if (isLoggedIn) {
        _logger.info('자동 로그인 성공 - 사용자 데이터 로딩');
        
        // 자동 로그인 성공 시 소 목록도 함께 로드
        if (userProvider.accessToken != null) {
          try {
            // CowProvider 초기화 및 데이터 로드
            cowProvider.clearAll();
            await cowProvider.fetchCowsFromBackend(userProvider.accessToken!);
            _logger.info('소 목록 데이터 로딩 완료');
          } catch (e) {
            _logger.warning('소 목록 로딩 실패 (자동 로그인 시): $e');
            // 소 목록 로딩 실패해도 메인 화면으로 이동
          }
        }
        
        // 메인 화면으로 이동
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        _logger.info('자동 로그인 실패 - 로그인 화면으로 이동');
        // 자동 로그인 실패 시 로그인 화면으로
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _logger.severe('스플래시 화면 에러: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고 또는 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.pets,
                size: 60,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 24),
            
            // 앱 이름
            const Text(
              '소담소담',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // 부제목
            const Text(
              '스마트 젖소 관리 시스템',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            
            // 로딩 인디케이터
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
            ),
            const SizedBox(height: 16),
            
            const Text(
              '로딩 중...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 