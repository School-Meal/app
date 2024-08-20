import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:school_meal/screen/services/auth_service.dart';
import 'package:path/path.dart' as path;

class ProfileEditScreen extends StatefulWidget {
  final String initialNickName;
  final String initialSchoolName;
  final String initialEmail;
  final String? initialImageUri;

  const ProfileEditScreen({
    super.key,
    required this.initialNickName,
    required this.initialSchoolName,
    required this.initialEmail,
    this.initialImageUri,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final AuthService _authService = AuthService();
  late TextEditingController _nickNameController;
  late TextEditingController _schoolNameController;
  late TextEditingController _emailController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nickNameController = TextEditingController(text: widget.initialNickName);
    _schoolNameController =
        TextEditingController(text: widget.initialSchoolName);
    _emailController = TextEditingController(text: widget.initialEmail);
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

  Future<void> _submitChanges() async {
    String? accessToken = await _authService.getValidAccessToken();

    if (accessToken == null) {
      _showErrorDialog('토큰이 만료되었습니다. 다시 로그인하세요.');
      return;
    }

    final url = Uri.parse('http://52.78.20.150/auth/me');
    var request = http.MultipartRequest('PATCH', url);

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['nickName'] = _nickNameController.text;
    request.fields['schoolName'] = _schoolNameController.text;
    request.fields['email'] = _emailController.text;

    if (_image != null) {
      var stream = http.ByteStream(_image!.openRead());
      var length = await _image!.length();
      var multipartFile = http.MultipartFile('image', stream, length,
          filename: path.basename(_image!.path));
      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        _showErrorDialog('프로필 수정에 실패했습니다.');
      }
    } catch (e) {
      _showErrorDialog('오류가 발생했습니다.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    _schoolNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        centerTitle: false,
        title: const Text(
          "프로필 수정",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (widget.initialImageUri != null
                                ? NetworkImage(widget.initialImageUri!)
                                : null) as ImageProvider?,
                        child: _image == null && widget.initialImageUri == null
                            ? Icon(Icons.person,
                                size: 60, color: Colors.grey[400])
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue[400],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(_nickNameController, '닉네임'),
                const SizedBox(height: 16),
                _buildTextField(_schoolNameController, '학교 이름'),
                const SizedBox(height: 16),
                _buildTextField(_emailController, '이메일'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '수정하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
        ),
      ),
      cursorColor: Colors.blue,
    );
  }
}
