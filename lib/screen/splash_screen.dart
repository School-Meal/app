// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:school_meal/screen/auth/signin_screen.dart';
import 'package:school_meal/screen/meal/meal_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<String> _getTokenPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path + '/token.txt';
  }

  Future<String?> _readToken() async {
    try {
      final path = await _getTokenPath();
      final file = File(path);
      String token = await file.readAsString();
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<void> _checkLoginStatus() async {
    String? accessToken = await _readToken();

    if (accessToken != null) {
      await Future.delayed(const Duration(seconds: 3), () {});
      // Token exists, navigate to MealScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MealScreen()),
      );
    } else {
      // No token, navigate to SignInScreen
      await Future.delayed(const Duration(seconds: 3), () {});
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("splash"),
      ),
    );
  }
}
