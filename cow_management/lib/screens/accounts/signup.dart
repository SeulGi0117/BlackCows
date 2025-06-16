import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  late String baseUrl;
  final _logger = Logger('SignupPage');

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      _logger.warning('경고: API_BASE_URL이 설정되지 않았습니다. .env 파일을 확인해주세요.');
    }
  }

  Future<void> _signup() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();
    final farmName = _farmNameController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || passwordConfirm.isEmpty || farmName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    if (username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디는 최소 3글자 이상이어야 합니다!')),
      );
      return;
    }

    if (password != passwordConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/auth/register');
      _logger.info('회원가입 요청 URL: $url');
      _logger.info('요청 데이터: username=$username, email=$email, farm_name=$farmName');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'farm_name': farmName,
        }),
      );

      _logger.info('응답 상태코드: ${response.statusCode}');
      
      // UTF-8로 디코딩
      final responseBody = utf8.decode(response.bodyBytes);
      _logger.info('응답 본문: $responseBody');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? '회원가입 성공! 로그인해주세요.')),
        );
        Navigator.pop(context, true); // 성공 시 true 반환
      } else {
        _logger.severe('회원가입 실패: ${response.statusCode} - $responseBody');
        
        String errorMessage = _getErrorMessage(response.statusCode, responseBody);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      _logger.severe('회원가입 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        if (responseBody.contains('email')) {
          return '올바른 이메일 형식을 입력해주세요.';
        } else if (responseBody.contains('username')) {
          return '이미 사용 중인 아이디입니다. 다른 아이디를 입력해주세요.';
        } else if (responseBody.contains('password')) {
          return '비밀번호가 조건에 맞지 않습니다. 다시 확인해주세요.';
        } else {
          return '입력한 정보를 다시 확인해주세요.';
        }
      case 404:
        return '서비스에 일시적인 문제가 있습니다. 잠시 후 다시 시도해주세요.';
      case 409:
        return '이미 등록된 정보입니다. 아이디나 이메일을 확인해주세요.';
      case 422:
        return '입력한 정보가 올바르지 않습니다. 다시 확인해주세요.';
      case 500:
        return '서버에 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      default:
        return '회원가입 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _farmNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣]'),
                ),
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: const InputDecoration(
                labelText: '아이디',
                helperText: '영어, 한글, 숫자만 입력 가능 (3-20자)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              onTap: () {
                _passwordController.clear();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9!"#$%&()*+,./:;<=>?@^_`{|}~\-\[\]\\]'),
                ),
              ],
              decoration: InputDecoration(
                labelText: '비밀번호',
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
            const SizedBox(height: 16),
            TextField(
              controller: _passwordConfirmController,
              obscureText: !_isPasswordConfirmVisible,
              onTap: () {
                _passwordConfirmController.clear();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9!"#$%&()*+,./:;<=>?@^_`{|}~\-\[\]\\]'),
                ),
              ],
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                helperText: '영어, 숫자, 허용된 특수문자만 사용 가능',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordConfirmVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordConfirmVisible = !_isPasswordConfirmVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _farmNameController,
              decoration: const InputDecoration(labelText: '목장 이름'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('회원가입'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
