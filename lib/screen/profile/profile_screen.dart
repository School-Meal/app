import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:school_meal/screen/profile/setting/setting_screen.dart';
import 'package:school_meal/screen/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String schoolName = '';
  String email = '';
  String nickName = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    String? accessToken = await _authService.getValidAccessToken();

    if (accessToken != null) {
      final url = Uri.parse('${dotenv.env['API_URL']}/auth/me');
      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final profileData = json.decode(response.body);
          setState(() {
            schoolName = profileData['schoolName'];
            email = profileData['email'];
            nickName = profileData['nickName'];
          });
        } else {
          print('Failed to load profile data');
        }
      } catch (e) {
        print('Error fetching profile: $e');
      }
    } else {
      print('No valid access token found');
      // 로그인이 필요하다는 메시지를 표시하거나, 로그인 화면으로 이동할 수 있습니다.
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
          "프로필",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingScreen()),
              );
            },
            icon: const Icon(
              Icons.settings,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("학교 이름: $schoolName"),
                Text("이메일: $email"),
                Text("닉네임: $nickName"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
