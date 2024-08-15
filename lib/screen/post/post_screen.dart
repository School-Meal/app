import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:school_meal/screen/post/add/add_screen.dart';
import 'package:intl/intl.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final url = Uri.parse('http://52.78.20.150/post');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> postData = json.decode(response.body);
        setState(() {
          posts = postData.map((data) {
            return {
              'id': data['id'], // 게시물 ID 추가
              'title': data['title'],
              'content': data['content'],
              'imageUrl': data['imageUrl'],
              'createdAt': _formatDate(data['createdAt']),
            };
          }).toList();
        });
      } else {
        print('Failed to load posts');
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  String _formatDate(String dateTime) {
    final DateTime date = DateTime.parse(dateTime);
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }

  void _editPost(Map<String, dynamic> post) {
    print('Edit post: ${post['id']}');
  }

  void _deletePost(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('게시물 삭제'),
          content: Text('정말로 이 게시물을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                // TODO: 실제 삭제 API 호출
                print('Delete post: ${post['id']}');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          "게시물",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: posts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "게시물이 없습니다.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  color: Colors.blue.shade100,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post['imageUrl'] != null)
                        ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.network(
                            post['imageUrl'],
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['title'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              post['content'],
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  post['createdAt'],
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert),
                                  onSelected: (String result) {
                                    if (result == 'edit') {
                                      _editPost(post);
                                    } else if (result == 'delete') {
                                      _deletePost(post);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('수정'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('삭제'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade600,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddPostScreen()));
        },
        child: const Icon(
          Icons.edit_document,
          color: Colors.white,
        ),
      ),
    );
  }
}
