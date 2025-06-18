import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'find_user_id_page.dart';
import 'find_password_page.dart';

class LoginPage extends StatefulWidget {
  final bool isTestMode;
  const LoginPage({super.key, this.isTestMode=false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController(); // 아이디 컨트롤러로 변경
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  late String baseUrl;
  final _logger = Logger('LoginPage');

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      _logger.warning('경고: API_BASE_URL이 설정되지 않았습니다. .env 파일을 확인해주세요.');
    }

    // 테스트 모드일 경우 자동 로그인
    if (widget.isTestMode) {
      _autoLogin();
    }
  }

  Future<void> _autoLogin() async {
    setState(() => _isLoading = true);
    
    final success = await Provider.of<UserProvider>(context, listen: false)
        .login('test1234', 'qwer1234', '$baseUrl/auth/login');

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    }
  }

  Future<void> _login() async {
    final userId = _userIdController.text.trim();     // 아이디로 변경
    final password = _passwordController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 모두 입력해주세요!')),
      );
      return;
    }

    if (userId.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디는 최소 3글자 이상이어야 합니다!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await Provider.of<UserProvider>(context, listen: false)
        .login(userId, password, '$baseUrl/auth/login'); // user_id로 로그인

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else if (mounted) {
      // 로그인 실패 시 비밀번호 필드 초기화
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디 또는 비밀번호가 올바르지 않습니다.')),
      );
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '소담소담 로그인',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              
              // 아이디 입력 필드 (username → user_id로 변경)
              TextField(
                controller: _userIdController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9_]'), // 영문, 숫자, 언더스코어만 허용
                  ),
                  LengthLimitingTextInputFormatter(20),
                ],
                decoration: const InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                  helperText: '영문, 숫자, 언더스코어(_)만 입력 가능 (3-20자)',
                  hintText: 'farmer123',
                ),
              ),
              const SizedBox(height: 16),
              
              // 비밀번호 입력 필드
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9!"#$%&()*+,./:;<=>?@^_`{|}~\-\[\]\\]'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: const OutlineInputBorder(),
                  helperText: '영어, 숫자, 허용된 특수문자만 사용 가능',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 아이디/비밀번호 찾기 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FindUserIdPage()),
                      );
                    },
                    child: const Text("아이디 찾기"),
                  ),
                  Container(
                    width: 1,
                    height: 16,
                    color: Colors.grey,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FindPasswordPage()),
                      );
                    },
                    child: const Text("비밀번호 찾기"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 회원가입 버튼
              TextButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/signup');
                  if (result == true) {
                    // 회원가입 성공 시 텍스트 필드 초기화
                    _userIdController.clear();
                    _passwordController.clear();
                  }
                },
                child: const Text("아직 회원이 아니신가요? 회원가입"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}