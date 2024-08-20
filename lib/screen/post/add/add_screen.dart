import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:school_meal/screen/services/auth_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  final AuthService _authService = AuthService();

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('이미지를 선택해주세요.'),
        ),
      );
      return;
    }
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('제목을 입력해주세요.'),
        ),
      );
      return;
    }
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('내용을 입력해주세요.'),
        ),
      );
      return;
    }

    String? accessToken = await _authService.getValidAccessToken();

    final url = Uri.parse('${dotenv.env['API_URL']}/post');
    var request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['title'] = _titleController.text;
    request.fields['content'] = _contentController.text;

    if (_image != null) {
      var stream = http.ByteStream(_image!.openRead());
      var length = await _image!.length();
      var multipartFile = http.MultipartFile('image', stream, length,
          filename: path.basename(_image!.path));
      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('게시물이 추가되었습니다.'),
          ),
        );
      } else {
        _showErrorDialog('게시물 추가에 실패했습니다.');
      }
    } catch (e) {
      _showErrorDialog('오류가 발생했습니다.');
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        centerTitle: false,
        title: const Text(
          "게시물 추가",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600, // 최대 너비 설정
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSection(
                    title: '이미지',
                    child: _image == null
                        ? Center(
                            child: ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image),
                              label: const Text('이미지 선택'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade300,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_image!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.edit),
                                label: const Text('이미지 변경'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '제목',
                    child: TextFormField(
                      controller: _titleController,
                      decoration: _getInputDecoration('제목을 입력하세요'),
                      cursorColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '내용',
                    child: TextFormField(
                      controller: _contentController,
                      maxLines: 5,
                      decoration: _getInputDecoration('내용을 입력하세요'),
                      cursorColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('게시물 추가',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

InputDecoration _getInputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
    ),
  );
}
