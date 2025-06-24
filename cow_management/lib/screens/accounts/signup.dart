import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/main.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController(); // 사용자 이름/실명
  final TextEditingController _userIdController = TextEditingController();   // 로그인용 아이디
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _farmNicknameController = TextEditingController(); // 목장 별명
  
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
    final username = _usernameController.text.trim();    // 사용자 이름/실명
    final userId = _userIdController.text.trim();        // 로그인용 아이디
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();
    final farmNickname = _farmNicknameController.text.trim(); // 목장 별명

    // 필수 필드 검증
    if (username.isEmpty || userId.isEmpty || email.isEmpty || password.isEmpty || passwordConfirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 필드를 모두 입력해주세요.')),
      );
      return;
    }

    // 사용자 이름 유효성 검사 (한글, 영문만 허용)
    if (!RegExp(r'^[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AFa-zA-Z\s]+$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름은 한글, 영문만 입력 가능합니다.')),
      );
      return;
    }

    if (username.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름은 최소 2글자 이상이어야 합니다!')),
      );
      return;
    }

    // 아이디 유효성 검사 (영문으로 시작, 영문+숫자+언더스코어)
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디는 영문으로 시작하고 영문, 숫자, 언더스코어(_)만 사용 가능합니다.')),
      );
      return;
    }

    if (userId.length < 3) {
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

    bool isDialogOpen = true;
    
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false, // 뒤로가기 버튼 비활성화
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('회원가입 시도 중...'),
                const SizedBox(height: 8),
                Text(
                  '계정을 생성하고 있습니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final url = Uri.parse('$baseUrl/auth/register');
      _logger.info('회원가입 요청 URL: $url');
      _logger.info('요청 데이터: username=$username, user_id=$userId, email=$email, farm_nickname=$farmNickname');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'username': username,           // 사용자 이름/실명
          'user_id': userId,              // 로그인용 아이디
          'email': email,                 // 이메일
          'password': password,           // 비밀번호
          'password_confirm': passwordConfirm, // 비밀번호 확인
          'farm_nickname': farmNickname.isNotEmpty ? farmNickname : null, // 목장 별명 (선택사항)
        }),
      );

      _logger.info('응답 상태코드: ${response.statusCode}');
      
      // UTF-8로 디코딩
      final responseBody = utf8.decode(response.bodyBytes);
      _logger.info('응답 본문: $responseBody');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(responseBody);
        _logger.info('회원가입 성공! 자동 로그인을 시도합니다.');
        
        // 로딩 메시지 업데이트 - 자동 로그인 단계
        if (isDialogOpen && mounted) {
          Navigator.of(context).pop(); // 기존 다이얼로그 닫기
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('자동 로그인 중...'),
                      const SizedBox(height: 8),
                      Text(
                        '홈 화면으로 이동하고 있습니다.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        
        // 회원가입 성공 후 자동 로그인 시도
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final loginSuccess = await userProvider.login(userId, password, '$baseUrl/auth/login');
        
        // 로딩 다이얼로그 닫기
        if (isDialogOpen && mounted) {
          Navigator.of(context).pop();
          isDialogOpen = false;
        }
        
        if (loginSuccess && mounted) {
          _logger.info('자동 로그인 성공! 홈 화면으로 이동합니다.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입 완료! 자동 로그인되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 잠시 대기 후 홈 화면으로 이동
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false, // 모든 이전 화면 제거
            );
          }
        } else {
          _logger.warning('자동 로그인 실패. 로그인 페이지로 이동합니다.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? '회원가입 성공! 로그인해주세요.')),
            );
            Navigator.pop(context, true); // 성공 시 true 반환
          }
        }
      } else {
        _logger.severe('회원가입 실패: ${response.statusCode} - $responseBody');
        
        // 로딩 다이얼로그가 열려있으면 닫기
        if (isDialogOpen && mounted) {
          Navigator.of(context).pop();
          isDialogOpen = false;
        }
        
        // 회원가입 실패 시 비밀번호 필드들 초기화
        _passwordController.clear();
        _passwordConfirmController.clear();
        
        if (mounted) {
          // 서버 오류 시 개발자 문의 다이얼로그 표시
          if (response.statusCode >= 500) {
            _showDeveloperContactDialog();
          } else {
            String errorMessage = _getErrorMessage(response.statusCode, responseBody);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        }
      }
    } catch (e) {
      _logger.severe('회원가입 실패: $e');
      
      // 로딩 다이얼로그가 열려있으면 닫기
      if (isDialogOpen && mounted) {
        Navigator.of(context).pop();
        isDialogOpen = false;
      }
      
      // 네트워크 오류 시에도 비밀번호 필드들 초기화
      _passwordController.clear();
      _passwordConfirmController.clear();
      
      if (mounted) {
        // 네트워크 연결 문제인지 확인하고 개발자 문의 다이얼로그 표시
        if (e.toString().contains('SocketException') || 
            e.toString().contains('TimeoutException') ||
            e.toString().contains('Connection refused') ||
            baseUrl.isEmpty) {
          _showDeveloperContactDialog();
        } else {
          // 일반적인 네트워크 오류
          String errorMessage = '네트워크 오류가 발생했습니다: ${e.toString()}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    }
  }

  // 개발자 문의 다이얼로그 표시
  void _showDeveloperContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('서버 연결 오류'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '서버에 이상이 생긴 것 같습니다.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '다음과 같은 문제일 수 있습니다:',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('• 서버가 일시적으로 중단됨'),
              Text('• 네트워크 연결 문제'),
              Text('• 서버 점검 중'),
              SizedBox(height: 16),
              Text(
                '문제가 지속되면 개발자에게 문의해주세요.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    '개발자 문의: team@blackcowsdairy.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _copyEmailToClipboard();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('이메일 복사'),
            ),
          ],
        );
      },
    );
  }

  // 이메일 주소 클립보드 복사
  Future<void> _copyEmailToClipboard() async {
    try {
      await Clipboard.setData(const ClipboardData(text: 'team@blackcowsdairy.com'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('개발자 이메일 주소가 클립보드에 복사되었습니다.\n이메일 앱에서 붙여넣기 하세요.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _logger.warning('클립보드 복사 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('복사에 실패했습니다. 수동으로 입력해주세요: team@blackcowsdairy.com'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _getErrorMessage(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        if (responseBody.contains('email')) {
          return '올바른 이메일 형식을 입력해주세요.';
        } else if (responseBody.contains('user_id') || responseBody.contains('아이디')) {
          return '이미 사용 중인 아이디입니다. 다른 아이디를 입력해주세요.';
        } else if (responseBody.contains('username') || responseBody.contains('이름')) {
          return '이름 형식이 올바르지 않습니다. 한글, 영문만 입력해주세요.';
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
      appBar: AppBar(title: const Text('회원가입')),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 사용자 이름/실명 입력
            TextField(
              controller: _usernameController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AFa-zA-Z\s]'), // 한글 전체 범위, 영문, 공백 허용
                ),
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: const InputDecoration(
                labelText: '이름 *',
                helperText: '한글, 영문만 입력 가능 (2-20자)',
                hintText: '홍길동',
              ),
            ),
            const SizedBox(height: 16),
            
            // 로그인용 아이디 입력
            TextField(
              controller: _userIdController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9_]'), // 영문, 숫자, 언더스코어만 허용
                ),
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: const InputDecoration(
                labelText: '아이디 *',
                helperText: '영문으로 시작, 영문+숫자+언더스코어(_) 가능 (3-20자)',
                hintText: 'farmer123',
              ),
            ),
            const SizedBox(height: 16),
            
            // 이메일 입력
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '이메일 *',
                hintText: 'example@farm.com',
              ),
            ),
            const SizedBox(height: 16),
            
            // 비밀번호 입력
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
                labelText: '비밀번호 *',
                helperText: '영어, 숫자, 허용된 특수문자만 사용 가능 (6-20자)',
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
            
            // 비밀번호 확인
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
                labelText: '비밀번호 확인 *',
                helperText: '위에서 입력한 비밀번호를 다시 입력해주세요',
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
            
            // 목장 별명 입력 (선택사항)
            TextField(
              controller: _farmNicknameController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AFa-zA-Z0-9\s\-_()]'), // 한글 전체 범위, 영문, 숫자, 기본 특수문자
                ),
                LengthLimitingTextInputFormatter(15),
              ],
              decoration: const InputDecoration(
                labelText: '목장 별명 (선택사항)',
                helperText: '입력하지 않으면 "이름님의 목장"으로 자동 설정됩니다',
                hintText: '행복한 목장',
              ),
            ),
            const SizedBox(height: 24),
            
            // 회원가입 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 안내 문구
            const Text(
              '* 표시된 항목은 필수 입력 항목입니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}