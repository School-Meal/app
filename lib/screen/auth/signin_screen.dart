import 'package:flutter/material.dart';
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
                  _buildButton("로그인", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainNavigator()),
                    );
                  }),
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
