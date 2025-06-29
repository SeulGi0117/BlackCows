import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/widgets/modern_card.dart';
import 'package:cow_management/widgets/loading_widget.dart';

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
  
  late String baseUrl;
  final _logger = Logger('SignupPage');
  
  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      _logger.warning('경고: API_BASE_URL이 설정되지 않았습니다. .env 파일을 확인해주세요.');
    }
    
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2E3A59)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '회원가입',
          style: TextStyle(
            color: const Color(0xFF2E3A59),
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
            const SizedBox(height: 40),
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
      _showErrorSnackBar('회원가입 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
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
              '확인',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
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
이 약관은 "소담소담"(이하 "회사")이 제공하는 농장 관리 서비스의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"란 회사가 제공하는 농장 관리 소프트웨어 및 관련 서비스를 의미합니다.
2. "이용자"란 회사의 서비스에 접속하여 이 약관에 따라 회사가 제공하는 서비스를 받는 회원 및 비회원을 말합니다.

제3조 (약관의 효력 및 변경)
1. 이 약관은 서비스 화면에 게시하거나 기타의 방법으로 이용자에게 공지함으로써 효력을 발생합니다.
2. 회사는 필요하다고 인정되는 경우 이 약관을 변경할 수 있으며, 변경된 약관은 제1항과 같은 방법으로 공지 또는 통지함으로써 효력을 발생합니다.

제4조 (서비스의 제공 및 변경)
1. 회사는 다음과 같은 업무를 수행합니다:
   - 농장 관리 소프트웨어 제공
   - 축산물 이력 관리 지원
   - 기타 회사가 정하는 업무

제5조 (서비스 이용시간)
1. 서비스 이용은 연중무휴, 1일 24시간을 원칙으로 합니다.
2. 다만, 회사의 업무상이나 기술상의 이유로 서비스가 일시 중단될 수 있습니다.

이 약관은 2024년 1월 1일부터 시행됩니다.
''';
  }

  String _getPrivacyPolicy() {
    return '''
소담소담 개인정보 처리방침

1. 개인정보의 처리목적
"소담소담"은 다음의 목적을 위하여 개인정보를 처리합니다:
- 회원 가입 및 관리
- 서비스 제공 및 이용자 식별
- 고객 상담 및 불만 처리
- 서비스 개선 및 신규 서비스 개발

2. 개인정보의 처리 및 보유기간
회사는 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.

3. 개인정보의 제3자 제공
회사는 원칙적으로 정보주체의 개인정보를 수집·이용 목적으로 명시한 범위 내에서 처리하며, 정보주체의 사전 동의 없이는 본래의 목적 범위를 초과하여 처리하거나 제3자에게 제공하지 않습니다.

4. 개인정보처리의 위탁
회사는 원활한 개인정보 업무처리를 위하여 다음과 같이 개인정보 처리업무를 위탁하고 있습니다:
- 서버 호스팅: AWS(Amazon Web Services)

5. 정보주체의 권리·의무 및 행사방법
정보주체는 회사에 대해 언제든지 다음 각 호의 개인정보 보호 관련 권리를 행사할 수 있습니다:
- 개인정보 처리정지 요구권
- 개인정보 열람요구권
- 개인정보 정정·삭제요구권
- 개인정보 처리정지 요구권

이 개인정보 처리방침은 2024년 1월 1일부터 적용됩니다.
''';
  }
}