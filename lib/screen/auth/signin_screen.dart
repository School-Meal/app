import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:school_meal/screen/auth/signup_screen.dart';
import 'package:school_meal/screen/navigator.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  Future<void> _signIn() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('이메일과 비밀번호를 입력해주세요.'),
        ),
      );
      // _showErrorDialog('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    final url = Uri.parse('${dotenv.env['API_URL']}/auth/signin');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        // 서버로부터 accessToken과 refreshToken을 받아서 처리
        final responseData = json.decode(response.body);
        final accessToken = responseData['accessToken'];
        final refreshToken = responseData['refreshToken'];

        // 토큰 저장
        await _storage.write(key: 'accessToken', value: accessToken);
        await _storage.write(key: 'refreshToken', value: refreshToken);

        // 저장 토큰 값 출력(test용)
        final savedAccessToken = await _storage.read(key: 'accessToken');
        final savedRefreshToken = await _storage.read(key: 'refreshToken');
        print('Access Token: $savedAccessToken');
        print('Refresh Token: $savedRefreshToken');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('로그인이 완료되었습니다.'),
          ),
        );

        // MainNavigator로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigator()),
        );
      } else {
        _showErrorDialog('로그인에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (error) {
      _showErrorDialog('오류가 발생했습니다. 인터넷 연결을 확인해주세요.');
      print(error);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade300],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 180,
                  ),
                  const Text(
                    "학교급식",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(_emailController, '이메일', Icons.email),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, '비밀번호', Icons.lock,
                      isPassword: true),
                  const SizedBox(height: 30),
                  _buildButton("로그인", _signIn),
                  const SizedBox(height: 15),
                  _buildButton("홈화면", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainNavigator()),
                    );
                  }, isSecondary: true),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "계정이 없으신가요? 회원가입",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        cursorColor: Colors.blue,
        obscureText: isPassword,
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed,
      {bool isSecondary = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: isSecondary ? Colors.blue : Colors.white,
          backgroundColor: isSecondary ? Colors.white : Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
