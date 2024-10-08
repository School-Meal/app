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
  PageController? _pageController;

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
              _initializePageController();
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

  void _initializePageController() {
    final currentHour = DateTime.now().hour;

    int initialPage = 0;

    if (currentHour >= 5 && currentHour < 10) {
      // 아침 시간: 5시 ~ 10시
      initialPage = _findMealPage('조식');
    } else if (currentHour >= 10 && currentHour < 14) {
      // 점심 시간: 10시 ~ 14시
      initialPage = _findMealPage('중식');
    } else if (currentHour >= 14 && currentHour < 20) {
      // 저녁 시간: 14시 ~ 20시
      initialPage = _findMealPage('석식');
    }

    _pageController = PageController(initialPage: initialPage);
  }

  int _findMealPage(String mealType) {
    for (int i = 0; i < meals.length; i++) {
      if (meals[i]['type'] == mealType) {
        return i;
      }
    }
    return 0; // 기본적으로 첫 페이지
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.food_bank, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "오늘 급식은 없습니다.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : PageView.builder(
              controller: _pageController,
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
                        Expanded(
                          // Expanded 위젯을 사용하여 남은 공간을 사용하도록 합니다.
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
                                // 이곳에도 Expanded를 사용하여 스크롤 가능하도록 합니다.
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
