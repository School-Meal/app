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
  String? imageUri; // 프로필 이미지 URI를 저장할 변수

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
            imageUri = profileData['imageUri']; // 이미지 URI 저장
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

  // 이미지 선택 기능 (추가 기능 구현 가능)
  void _pickImage() {
    // 이미지 선택 기능 구현
    print("이미지 수정 버튼 클릭됨");
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
                MaterialPageRoute(builder: (context) => const SettingScreen()),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: imageUri != null
                      ? NetworkImage(imageUri!)
                      : null, // 이미지 URI가 null이 아니면 표시
                  child: imageUri == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        )
                      : null, // 이미지 URI가 null이면 기본 아이콘 표시
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("학교 이름: $schoolName"),
            Text("이메일: $email"),
            Text("닉네임: $nickName"),
          ],
        ),
      ),
    );
  }
}
