// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_meal/screen/auth/signin_screen.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  List<dynamic> meals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<String> _getTokenPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/token.txt';
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

  Future<void> _fetchMeals() async {
    String? token = await _readToken();
    if (token == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
      return;
    }

    final url = Uri.parse('http://52.78.20.150/meal');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        meals = responseData['meals'] ?? [];
        isLoading = false;
      });
    } else {
      // Handle error
      print('Error fetching meals: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final path = await _getTokenPath();
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("급식화면"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : meals.isEmpty
              ? const Center(child: Text("급식데이터 없음"))
              : Center(
                  child: SizedBox(
                    width: 500,
                    height: 500,
                    child: PageView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  meal['type'],
                                  style: const TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                ...meal['menu'].map<Widget>((item) {
                                  return Text(item);
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
