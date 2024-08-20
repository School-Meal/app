import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:school_meal/screen/profile/edit/edit_screen.dart';
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
  // ProfileScreen.dart 내의 _pickImage 메서드 수정
  void _editProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(
          initialNickName: nickName,
          initialSchoolName: schoolName,
          initialEmail: email,
          initialImageUri: imageUri,
        ),
      ),
    );

    if (result == true) {
      // 프로필이 수정되었다면 프로필 정보를 다시 불러옵니다.
      _fetchProfile();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          imageUri != null ? NetworkImage(imageUri!) : null,
                      child: imageUri == null
                          ? Icon(Icons.person,
                              size: 60, color: Colors.grey[400])
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _editProfile,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue[400],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  nickName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  schoolName,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 42),
              _buildInfoItem(Icons.person, "닉네임", nickName),
              const Divider(height: 32),
              _buildInfoItem(Icons.school, "학교", schoolName),
              const Divider(height: 32),
              _buildInfoItem(Icons.email, "이메일", email),
              const Divider(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue[400]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
