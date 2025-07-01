import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:cow_management/utils/api_config.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/widgets/modern_card.dart';
import 'package:cow_management/widgets/loading_widget.dart';
import 'package:flutter/foundation.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  // Form Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _farmNicknameController = TextEditingController();
  
  // State Variables
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  bool _isLoading = false;
  int _currentPage = 0;
  
  final _logger = Logger('SignupPage');
  
  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _usernameController.dispose();
    _userIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _farmNicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '회원가입',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildBasicInfoPage(),
                      _buildAccountInfoPage(),
                      _buildTermsPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= _currentPage 
                      ? const Color(0xFF4CAF50) 
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < 2) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(
              '기본 정보',
              '소담소담에 오신 것을 환영합니다!\n기본 정보를 입력해주세요.',
              Icons.person_outline,
            ),
            SizedBox(height: 40),
            ModernTextField(
              label: '이름 *',
              hint: '실제 이름을 입력하세요',
              controller: _usernameController,
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4CAF50)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이름을 입력해주세요';
                }
                if (value.length < 2) {
                  return '이름은 최소 2글자 이상이어야 합니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ModernTextField(
              label: '목장 이름',
              hint: '목장 이름을 입력하세요 (선택사항)',
              controller: _farmNicknameController,
              prefixIcon: const Icon(Icons.home_outlined, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 40),
            ModernButton(
              text: '다음',
              onPressed: _nextPage,
              isFullWidth: true,
              icon: const Icon(Icons.arrow_forward, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            '계정 정보',
            '로그인에 사용할 계정 정보를\n입력해주세요.',
            Icons.security,
          ),
          const SizedBox(height: 40),
          ModernTextField(
            label: '아이디 *',
            hint: '영문, 숫자, 언더스코어만 가능',
            controller: _userIdController,
            prefixIcon: const Icon(Icons.account_circle_outlined, color: Color(0xFF4CAF50)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '아이디를 입력해주세요';
              }
              if (value.length < 3) {
                return '아이디는 최소 3글자 이상이어야 합니다';
              }
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                return '영문, 숫자, 언더스코어만 사용 가능합니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ModernTextField(
            label: '이메일 *',
            hint: 'example@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF4CAF50)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '올바른 이메일 형식이 아닙니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ModernTextField(
            label: '비밀번호 *',
            hint: '8자 이상 입력하세요',
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
              if (value.length < 8) {
                return '비밀번호는 최소 8글자 이상이어야 합니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ModernTextField(
            label: '비밀번호 확인 *',
            hint: '비밀번호를 다시 입력하세요',
            controller: _passwordConfirmController,
            obscureText: !_isPasswordConfirmVisible,
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4CAF50)),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordConfirmVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordConfirmVisible = !_isPasswordConfirmVisible;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호 확인을 입력해주세요';
              }
              if (value != _passwordController.text) {
                return '비밀번호가 일치하지 않습니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: ModernButton(
                  text: '이전',
                  type: ButtonType.secondary,
                  onPressed: _previousPage,
                  icon: const Icon(Icons.arrow_back, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernButton(
                  text: '다음',
                  onPressed: _nextPage,
                  icon: const Icon(Icons.arrow_forward, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            '약관 동의',
            '서비스 이용을 위한 약관에\n동의해주세요.',
            Icons.assignment_turned_in_outlined,
          ),
          const SizedBox(height: 40),
          ModernCard(
            child: Column(
              children: [
                _buildTermsItem(
                  '서비스 이용약관 동의',
                  '필수',
                  _agreeToTerms,
                  (value) => setState(() => _agreeToTerms = value ?? false),
                  onViewTerms: () => _showTermsDialog('서비스 이용약관', _getTermsOfService()),
                ),
                const Divider(height: 24),
                _buildTermsItem(
                  '개인정보 수집·이용 동의',
                  '필수',
                  _agreeToPrivacy,
                  (value) => setState(() => _agreeToPrivacy = value ?? false),
                  onViewTerms: () => _showTermsDialog('개인정보 처리방침', _getPrivacyPolicy()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ModernButton(
                  text: '이전',
                  type: ButtonType.secondary,
                  onPressed: _previousPage,
                  icon: const Icon(Icons.arrow_back, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernButton(
                  text: '회원가입',
                  onPressed: _signup,
                  isLoading: _isLoading,
                  icon: _isLoading ? null : const Icon(Icons.check, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLoginPrompt(),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsItem(
    String title,
    String required,
    bool isChecked,
    Function(bool?) onChanged, {
    VoidCallback? onViewTerms,
  }) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: onChanged,
          activeColor: const Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E3A59),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: required == '필수' 
                          ? const Color(0xFFE53E3E) 
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      required,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (onViewTerms != null) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onViewTerms,
                  child: Text(
                    '약관 보기',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF4CAF50),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '이미 계정이 있으신가요? ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            '로그인',
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

  void _nextPage() {
    if (_currentPage == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentPage = 1);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentPage == 1) {
      if (_validateAccountInfo()) {
        setState(() => _currentPage = 2);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateAccountInfo() {
    final userId = _userIdController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;

    if (userId.isEmpty) {
      _showErrorSnackBar('아이디를 입력해주세요');
      return false;
    }
    if (userId.length < 3) {
      _showErrorSnackBar('아이디는 최소 3글자 이상이어야 합니다');
      return false;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(userId)) {
      _showErrorSnackBar('아이디는 영문, 숫자, 언더스코어만 사용 가능합니다');
      return false;
    }
    if (email.isEmpty) {
      _showErrorSnackBar('이메일을 입력해주세요');
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorSnackBar('올바른 이메일 형식이 아닙니다');
      return false;
    }
    if (password.isEmpty) {
      _showErrorSnackBar('비밀번호를 입력해주세요');
      return false;
    }
    if (password.length < 8) {
      _showErrorSnackBar('비밀번호는 최소 8글자 이상이어야 합니다');
      return false;
    }
    if (password != passwordConfirm) {
      _showErrorSnackBar('비밀번호가 일치하지 않습니다');
      return false;
    }

    return true;
  }

  Future<void> _signup() async {
    if (!_agreeToTerms || !_agreeToPrivacy) {
      _showErrorSnackBar('필수 약관에 동의해주세요');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final userId = _userIdController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final passwordConfirm = _passwordConfirmController.text;
      final farmNickname = _farmNicknameController.text.trim();
      final baseUrl = ApiConfig.baseUrl;
      
      final url = Uri.parse('$baseUrl/auth/register');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'username': username,
          'user_id': userId,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'farm_nickname': farmNickname.isNotEmpty ? farmNickname : null,
        }),
      );

      final responseBody = utf8.decode(response.bodyBytes);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 회원가입 성공 후 자동 로그인 시도
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final loginSuccess = await userProvider.login(userId, password, '$baseUrl/auth/login');
        
        if (loginSuccess && mounted) {
          _showSuccessSnackBar('회원가입 완료! 자동 로그인되었습니다.');
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false,
            );
          }
        } else {
          _showSuccessSnackBar('회원가입 성공! 로그인해주세요.');
          Navigator.pop(context, true);
        }
      } else {
        final responseData = jsonDecode(responseBody);
        _showErrorSnackBar(responseData['message'] ?? '회원가입에 실패했습니다');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('서버 연결 오류'),
            ],
          ),
          content: const Text('서버에 연결할 수 없습니다.\n잠시 후 다시 시도해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'support@blackcowsdairy.com'));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('이메일 주소가 클립보드에 복사되었습니다'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4CAF50)),
              child: const Text('개발자 문의'),
            ),
          ],
        ),
      );
    }
  }

  void _showTermsDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(content),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '닫기',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              String url = '';
              if (title.contains('서비스 이용약관')) {
                url = 'https://blackcows-team.github.io/blackcows-privacy/terms-of-service.html';
              } else if (title.contains('개인정보')) {
                url = 'https://blackcows-team.github.io/blackcows-privacy/privacy-policy.html';
              }
              
              if (url.isNotEmpty) {
                try {
                  final Uri uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    throw 'URL을 열 수 없습니다';
                  }
                } catch (e) {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('링크가 클립보드에 복사되었습니다. 브라우저에서 붙여넣기 하세요.'),
                        backgroundColor: Color(0xFF4CAF50),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('자세히 보기'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getTermsOfService() {
    return '''
소담소담 서비스 이용약관

제1조 (목적)
이 약관은 blackcowsdairy(이하 "회사")가 제공하는 낙농 관리 어플리케이션 '소담소담'(이하 "서비스")의 이용과 관련하여 회사와 이용자간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.

제2조 (용어의 정의)
1. "서비스"란 회사가 제공하는 낙농 관리 어플리케이션 '소담소담' 및 관련 제반 서비스를 의미합니다.
2. "이용자" 또는 "회원"이란 이 약관에 따라 서비스를 이용하는 자를 의미합니다.
3. "계정"이란 서비스 이용을 위해 회원이 설정한 로그인 아이디와 비밀번호의 조합을 의미합니다.
4. "콘텐츠"란 서비스 내에서 이용자가 생성, 등록, 수정하는 젖소 정보, 관리 기록, 목장 정보 등을 의미합니다.
5. "축산물 이력제 연동 서비스"란 이표번호를 통해 축산물품질평가원의 정보를 조회하는 서비스를 의미합니다.

제3조 (서비스의 제공)
회사가 제공하는 서비스의 내용은 다음과 같습니다:
1. 회원 관리 서비스: 회원가입, 로그인, 계정 관리
2. 농장 관리 서비스: 목장 정보 설정 및 관리
3. 젖소 관리 서비스: 젖소 정보 등록, 관리 기록 작성 및 조회
4. 축산물 이력제 연동 서비스: 이표번호를 통한 정부 데이터베이스 연동
5. AI 분석 서비스: 젖소 건강상태 및 생산성 예측 분석
6. AI 챗봇 서비스: 낙농 관련 상담 및 정보 제공
7. 기타 회사가 추가로 개발하거나 제공하는 일체의 서비스

제4조 (AI 서비스)
1. 회사는 AI 기술을 활용한 분석 서비스 및 챗봇 서비스를 제공합니다.
2. AI 서비스의 결과는 참고용 정보이며, 실제 농장 관리 결정은 회원의 판단과 책임 하에 이루어져야 합니다.
3. 회사는 AI 서비스 결과의 정확성을 보장하지 않으며, 해당 결과로 인한 손해에 대해 책임지지 않습니다.
4. 회원의 개인정보는 AI 학습에 사용되지 않으며, 대화 내용은 14일 후 자동으로 삭제됩니다.

제5조 (면책조항)
1. 회사는 무료로 제공되는 서비스와 관련하여 회원에게 어떠한 손해가 발생하더라도 동 손해가 회사의 고의 또는 중대한 과실에 의한 경우를 제외하고는 이에 대하여 책임을 부담하지 아니합니다.
2. 회사는 축산물 이력제 연동 서비스를 통해 제공되는 정부 데이터의 정확성에 대해 책임을 지지 않습니다.
3. 회사는 AI 서비스를 통해 제공되는 분석 결과나 조언의 정확성을 보장하지 않으며, 이로 인한 손해에 대해 책임을 지지 않습니다.

본 약관은 2025년 6월 29일부터 시행됩니다.

자세한 내용은 https://blackcows-team.github.io/blackcows-privacy/terms-of-service.html 에서 확인하실 수 있습니다.
''';
  }

  String _getPrivacyPolicy() {
    return '''
소담소담 개인정보 처리방침

blackcowsdairy(이하 "회사")는 정보주체의 자유와 권리 보호를 위해 「개인정보 보호법」 및 관계 법령이 정한 바를 준수하여, 적법하게 개인정보를 처리하고 안전하게 관리하고 있습니다.

1. 개인정보의 처리목적
회사는 낙농 관리 어플리케이션 '소담소담' 서비스 제공을 위해 다음의 목적으로 개인정보를 처리합니다:
- 회원 인증 및 사용자 식별
- 농장 관리 서비스 제공
- 서비스 운영 및 고지사항 전달
- 낙농 관리 서비스 제공
- AI 챗봇 서비스 제공
- AI 분석 서비스 제공
- 축산물 이력제 연동 서비스
- 위치 기반 서비스 제공
- 앱 서비스 개선 및 통계 분석

2. 처리하는 개인정보의 항목
[필수 수집 정보]
- 사용자 이름(실명), 로그인 아이디, 이메일 주소, 비밀번호
[선택 수집 정보]
- 목장 별명(농장명)
[서비스 이용 과정에서 생성되는 정보]
- 젖소 정보, 관리 기록, 챗봇 대화 내용, 서비스 이용 기록

3. 개인정보의 처리 및 보유 기간
- 회원정보: 회원 탈퇴 시까지
- 젖소 관리 데이터: 회원 탈퇴 후 즉시 파기
- 챗봇 대화 기록: 14일 (자동 삭제)
- 서비스 이용 기록: 3개월

4. 개인정보의 제3자 제공
회사는 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다. 단, 다음의 경우는 예외로 합니다:
- 축산물이력제 API (농림축산식품부): 이표번호 조회
- OpenAI: AI 챗봇 서비스 제공 (개인식별정보 제외)
- 법령의 규정에 의거하거나 수사기관의 요구가 있는 경우

5. 개인정보 보호책임자
성명: 강슬기
연락처: support@blackcowsdairy.com

본 개인정보 처리방침은 2025년 6월 29일부터 적용됩니다.

자세한 내용은 https://blackcows-team.github.io/blackcows-privacy/privacy-policy.html 에서 확인하실 수 있습니다.
''';
  }
}