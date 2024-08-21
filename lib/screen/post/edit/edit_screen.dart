import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:school_meal/screen/services/auth_service.dart';

class EditPostScreen extends StatefulWidget {
  final int postId; // 게시물 ID를 받아오기 위해 추가
  final String initialTitle;
  final String initialContent;
  final String? initialImageUrl;

  const EditPostScreen({
    super.key,
    required this.postId,
    required this.initialTitle,
    required this.initialContent,
    this.initialImageUrl,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _contentController.text = widget.initialContent;
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

    final url = Uri.parse('http://3.34.76.135/post/${widget.postId}');
    var request = http.MultipartRequest('PATCH', url);

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
      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        _showErrorDialog('게시물 수정에 실패했습니다.');
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
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        centerTitle: false,
        title: const Text(
          "게시물 수정",
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 24),
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildContentField(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                image: _image != null
                    ? DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      )
                    : (widget.initialImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(widget.initialImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null),
              ),
              child: _image == null && widget.initialImageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 8, // 하단으로부터의 거리
              right: 8, // 오른쪽으로부터의 거리
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  "이미지를 터치하세요!",
                  style: TextStyle(
                    color: Colors.white, // 텍스트 색상 설정
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: '제목',
        labelStyle: const TextStyle(
          color: Colors.black,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.black, // 포커스 상태의 테두리 색상
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      cursorColor: Colors.blue,
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: InputDecoration(
        labelText: '내용',
        labelStyle: const TextStyle(
          color: Colors.black,
        ),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.black, // 포커스 상태의 테두리 색상
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      cursorColor: Colors.blue,
      maxLines: 8,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitChanges,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade300,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        '게시물 수정',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
