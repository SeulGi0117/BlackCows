import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  late String loginUrl;

  @override
  void initState() {
    super.initState();
    // final baseUrl = dotenv.env['BASE_URL']!;
    // print('✅ BASE_URL: $baseUrl');

    // .env는 웹에서 안되는지 오류가 자꾸 뜸 불러오질 못하는듯
    loginUrl =
        'http://52.78.212.96:8000/http://ec2-52-78-212-96.ap-northeast-2.compute.amazonaws.com:8000/';
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 모두 입력해주세요!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await Provider.of<UserProvider>(context, listen: false)
        .login(username, password, loginUrl); // 👈 loginUrl 전달

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 실패! 아이디와 비밀번호를 확인해주세요.')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
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
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/'); // 로그인 누르면 메인 홈으로 이동
                  },
                  // onPressed: _isLoading ? null : _login,
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
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // 회원가입 버튼
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context,
                      '/signup'); // 또는 Navigator.push(context, MaterialPageRoute(...))
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
