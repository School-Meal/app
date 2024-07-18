import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:school_meal/screen/meal/meal_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<String> _getTokenPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/token.txt';
  }

  Future<void> _saveToken(String token) async {
    final path = await _getTokenPath();
    final file = File(path);
    await file.writeAsString(token);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://3.38.149.135/auth/signin');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'schoolName': _schoolNameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 201) {
          final responseData = json.decode(response.body);
          if (responseData['accessToken'] != null) {
            await _saveToken(responseData['accessToken']);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MealScreen()),
            );
          } else {
            _showErrorDialog('로그인 실패: 토큰을 받지 못했습니다.');
          }
        } else {
          _showErrorDialog('로그인 실패: ${response.statusCode}');
        }
      } catch (e) {
        _showErrorDialog('로그인 중 오류 발생: $e');
      }
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
            child: const Text('확인'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _schoolNameController,
                decoration: InputDecoration(labelText: '학교 이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '학교 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '이메일'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('로그인하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
