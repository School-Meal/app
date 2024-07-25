import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:school_meal/screen/profile/profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
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

  Future<void> _fetchUserProfile() async {
    String? token = await _readToken();

    final url = Uri.parse('${dotenv.env['API_URL']}/auth/me');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userProfile = json.decode(response.body);
        isLoading = false;
      });
    } else {
      // Handle error
      print('Error fetching user profile: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(userProfile: userProfile),
                ),
              );
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProfile == null
              ? const Center(child: Text('Failed to load profile'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userProfile!['imageUri'] != null &&
                          userProfile!['imageUri'].isNotEmpty)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage(userProfile!['imageUri']),
                        ),
                      SizedBox(height: 20),
                      Text(
                        '학교 이름: ${userProfile!['schoolName']}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '이메일: ${userProfile!['email']}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '닉네임: ${userProfile!['nickName']}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
    );
  }
}
