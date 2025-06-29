import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/widgets/modern_card.dart';
import 'package:cow_management/widgets/loading_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'dart:math';
import 'find_user_id_page.dart';
import 'find_password_page.dart';
import '../../services/auth/google_auth_service.dart';
import '../../services/auth/token_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  late String baseUrl;
  final _logger = Logger('LoginPage');
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<String> _loadingMessages = [
    '로그인 중이에요! 🐄',
    '젖소들이 기다리고 있어요! 🥛',
    '농장으로 가는 중... 🚜',
    '소담소담 준비 중! ✨',
    '목장 문을 여는 중... 🚪',
    '우유 짜러 가볼까요? 🐮',
    '농장 친구들이 반겨요! 🌾',
  ];
  
  String get _randomLoadingMessage {
    final random = Random();
    return _loadingMessages[random.nextInt(_loadingMessages.length)];
  }

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      _logger.warning('경고: API_BASE_URL이 설정되지 않았습니다. .env 파일을 확인해주세요.');
    }
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 60),
                  _buildLoginForm(),
                  const SizedBox(height: 24),
                  _buildForgotPassword(),
                  const SizedBox(height: 40),
                  _buildSocialLogin(),
                  const SizedBox(height: 30),
                  _buildSignUpPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '소담소담',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '농장 관리의 새로운 시작',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '로그인',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '계정에 로그인하여 농장을 관리하세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ModernTextField(
              label: '아이디',
              hint: '아이디를 입력하세요',
              controller: _userIdController,
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4CAF50)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '아이디를 입력해주세요';
                }
                if (value.length < 3) {
                  return '아이디는 최소 3글자 이상이어야 합니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ModernTextField(
              label: '비밀번호',
              hint: '비밀번호를 입력하세요',
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4CAF50)),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ModernButton(
              text: _isLoading ? _randomLoadingMessage : '로그인',
              onPressed: _login,
              isLoading: _isLoading,
              isFullWidth: true,
              icon: _isLoading ? null : const Icon(Icons.login, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindUserIdPage()),
            );
          },
          child: Text(
            '아이디 찾기',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 16,
          color: Colors.grey.shade300,
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindPasswordPage()),
            );
          },
          child: Text(
            '비밀번호 찾기',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '또는',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                color: const Color(0xFFDB4437),
                onPressed: _loginWithGoogle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSocialButton(
                icon: Icons.chat_bubble,
                label: 'Kakao',
                color: const Color(0xFFFFE812),
                textColor: Colors.black,
                onPressed: _loginWithKakao,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    Color? textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? Colors.white,
          backgroundColor: color,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '계정이 없으신가요? ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: const Text(
            '회원가입',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final result = await userProvider.loginWithResult(userId, password, '$baseUrl/auth/login');

      setState(() => _isLoading = false);

      if (result.success && mounted) {
        final cowProvider = Provider.of<CowProvider>(context, listen: false);
        cowProvider.clearAll();
        if (userProvider.accessToken != null) {
          await cowProvider.fetchCowsFromBackend(userProvider.accessToken!);
        }
        Navigator.pushReplacementNamed(context, '/main');
      } else if (mounted) {
        _passwordController.clear();
        _showErrorDialog(result);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('로그인 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
    }
  }

  void _showErrorDialog(LoginResult result) {
    String title = '로그인 실패';
    String message = result.message;
    List<Widget> actions = [];

    if (result.errorType == LoginErrorType.serverError || 
        result.errorType == LoginErrorType.timeout ||
        result.errorType == LoginErrorType.unknown) {
      title = '서버 연결 오류';
      message = '서버에 연결할 수 없습니다.\n잠시 후 다시 시도해주세요.';
      actions = [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('확인'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _copyEmailToClipboard();
          },
          child: const Text('개발자 문의'),
        ),
      ];
    } else {
      actions = [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('확인'),
        ),
      ];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: actions,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _copyEmailToClipboard() async {
    try {
      await Clipboard.setData(const ClipboardData(text: 'team@blackcowsdairy.com'));
      if (mounted) {
        _showErrorSnackBar('개발자 이메일이 클립보드에 복사되었습니다.');
      }
    } catch (e) {
      _logger.warning('클립보드 복사 실패: $e');
    }
  }

     Future<void> _loginWithGoogle() async {
     try {
       setState(() => _isLoading = true);
       
       final token = await GoogleAuthService.signInWithGoogle();
      
      if (token != null && mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        // Google 로그인 처리 로직 구현
        _showErrorSnackBar('Google 로그인 기능은 준비 중입니다.');
      }
    } catch (e) {
      _showErrorSnackBar('Google 로그인에 실패했습니다.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithKakao() async {
    try {
      setState(() => _isLoading = true);
      
      // Kakao 로그인 처리 로직 구현
      _showErrorSnackBar('Kakao 로그인 기능은 준비 중입니다.');
    } catch (e) {
      _showErrorSnackBar('Kakao 로그인에 실패했습니다.');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}