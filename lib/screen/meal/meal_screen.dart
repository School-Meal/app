import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:school_meal/screen/meal/rank/rank_screen.dart';
import 'package:school_meal/screen/services/auth_service.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> meals = [];

  @override
  void initState() {
    super.initState();
    _fetchMealData();
  }

  Future<void> _fetchMealData() async {
    String? accessToken = await _authService.getValidAccessToken();

    if (accessToken != null) {
      final url = Uri.parse('${dotenv.env['API_URL']}/meal');
      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final mealData = json.decode(response.body);
          if (mealData['meals'] != null) {
            setState(() {
              meals = List<Map<String, dynamic>>.from(mealData['meals']);
            });
          } else {
            if (mounted) {
              setState(() {
                meals = [];
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
              meals = [];
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            meals = [];
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          meals = [];
        });
      }
    }
  }

  String _getMealImage(String mealType) {
    switch (mealType) {
      case '조식':
        return 'assets/images/emoji1.png';
      case '중식':
        return 'assets/images/emoji2.png';
      case '석식':
        return 'assets/images/emoji3.png';
      default:
        return 'assets/images/emoji1.png'; // 기본 이미지 또는 예외 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          "학교급식",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const RankScreen()));
            },
            icon: Icon(
              Icons.emoji_events_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: meals.isEmpty
          ? const Center(
              child: Text(
                "오늘 급식은 없습니다.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : PageView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                final mealType = meal['type'];
                final menu = List<String>.from(meal['menu']);

                return Card(
                  color: Colors.blue.shade100,
                  margin: const EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Image.asset(
                              _getMealImage(mealType),
                              scale: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 400,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                child: Text(
                                  mealType,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: menu.length,
                                  itemBuilder: (context, index) {
                                    return Center(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        width: 300,
                                        height: 40,
                                        child: Center(
                                          child: Text(
                                            menu[index],
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
