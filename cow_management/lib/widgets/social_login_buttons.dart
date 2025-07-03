import 'package:flutter/material.dart';
import 'package:cow_management/services/auth/google_auth_service.dart';

class SocialLoginButtons extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final Function(String)? onLoginError;

  const SocialLoginButtons({
    Key? key,
    this.onLoginSuccess,
    this.onLoginError,
  }) : super(key: key);

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  bool _isLoading = false;

  Future<void> _handleLogin(String provider, Future<Map<String, dynamic>?> Function() loginFunction) async {
    setState(() => _isLoading = true);

    try {
      final result = await loginFunction();
      
      if (result != null) {
        widget.onLoginSuccess?.call();
      } else {
        widget.onLoginError?.call('$provider 로그인에 실패했습니다');
      }
    } catch (error) {
      widget.onLoginError?.call('$provider 로그인 중 오류가 발생했습니다: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Google 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Stack(
            children: [
              ElevatedButton.icon(
                onPressed: null, // 버튼 비활성화
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  width: 24,
                  height: 24,
                ),
                label: const Text('Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.red.shade200,
                  disabledForegroundColor: Colors.white70,
                ),
              ),
              Positioned(
                right: 8,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '준비 중',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
} 