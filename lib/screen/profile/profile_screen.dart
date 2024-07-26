import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic>? userProfile;

  const EditProfile({super.key, this.userProfile});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _schoolNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    _schoolNameController.text = widget.userProfile?['schoolName'] ?? '';
    _emailController.text = widget.userProfile?['email'] ?? '';
    _nicknameController.text = widget.userProfile?['nickName'] ?? '';
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
      print('Token read: $token'); // 토큰 읽기 로그 출력
      return token;
    } catch (e) {
      print('Failed to read token: $e'); // 토큰 읽기 실패 로그 출력
      return null;
    }
  }

  Future<void> _writeToken(String token) async {
    final path = await _getTokenPath();
    final file = File(path);
    await file.writeAsString(token);
    print('Token written: $token'); // 토큰 쓰기 로그 출력
  }

  Future<String?> _refreshToken() async {
    final url = Uri.parse('http://52.78.20.150/refresh');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final newToken = responseData['accessToken'];
      await _writeToken(newToken);
      print('Token refreshed: $newToken'); // 토큰 새로고침 로그 출력
      return newToken;
    } else {
      print(
          'Error refreshing token: ${response.statusCode}'); // 토큰 새로고침 실패 로그 출력
      return null;
    }
  }

  Future<void> _updateProfile() async {
    String? token = await _readToken();
    if (token == null) {
      print('No token available'); // 토큰 없음 로그 출력
      return;
    }

    final url = Uri.parse('${dotenv.env['API_URL']}/auth/me');
    var request = http.MultipartRequest('PATCH', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['schoolName'] = _schoolNameController.text
      ..fields['email'] = _emailController.text
      ..fields['nickName'] = _nicknameController.text;

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 401) {
      print('Token expired, refreshing token'); // 토큰 만료 로그 출력
      String? newToken = await _refreshToken();
      if (newToken != null) {
        request.headers['Authorization'] = 'Bearer $newToken';
        final retryResponse = await request.send();
        if (retryResponse.statusCode == 200) {
          final responseData = await retryResponse.stream.bytesToString();
          final updatedProfile = json.decode(responseData);
          Navigator.of(context).pop(updatedProfile);
        } else {
          print(
              'Error updating profile after token refresh: ${retryResponse.statusCode}');
        }
      }
    } else if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final updatedProfile = json.decode(responseData);
      Navigator.of(context).pop(updatedProfile);
    } else {
      print('Error updating profile: ${response.statusCode}');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _updateProfile();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _schoolNameController,
                decoration: InputDecoration(labelText: 'School Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your school name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: 'Nickname'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your nickname';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              if (_image != null) Image.file(_image!),
            ],
          ),
        ),
      ),
    );
  }
}
