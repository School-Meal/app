import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:school_meal/screen/post/add/add_screen.dart';
import 'package:intl/intl.dart';
import 'package:school_meal/screen/services/auth_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPostsAndLikeCounts();
  }

  Future<void> _fetchPostsAndLikeCounts() async {
    await _fetchPosts();
    await _fetchLikeCounts();
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
              'id': data['id'],
              'title': data['title'],
              'content': data['content'],
              'imageUrl': data['imageUrl'],
              'nickName': data['author']['nickName'],
              'schoolName': data['author']['schoolName'],
              'createdAt': _formatDate(data['createdAt']),
            };
          }).toList();
          posts = posts.reversed.toList();
        });
      } else {
        print('Failed to load posts');
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  Future<void> _fetchLikeCounts() async {
    String? accessToken = await _authService.getValidAccessToken();
    if (accessToken == null) {
      print('Access token is null');
      return;
    }

    for (var post in posts) {
      final postId = post['id'];
      final url = Uri.parse('http://52.78.20.150/like/count/$postId');
      try {
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (response.statusCode == 200) {
          setState(() {
            post['likeCount'] = int.parse(response.body);
          });
        } else {
          print('Failed to load like count for post $postId');
        }
      } catch (e) {
        print('Error fetching like count: $e');
      }
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text('게시물 삭제'),
          content: const Text('정말로 이 게시물을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
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
          "커뮤니티",
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
          : ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey[300]),
              itemBuilder: (context, index) {
                final post = posts[index];
                final nickName =
                    post['nickName'].isNotEmpty ? post['nickName'] : "사용자";
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            post['id'].toString(),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            nickName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            color: Colors.white,
                            icon: const Icon(Icons.more_vert),
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
                    ),
                    if (post['imageUrl'] != null)
                      Image.network(
                        post['imageUrl'],
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              LikeButton(
                                likeCount: post['likeCount'] ?? 0,
                              ),
                              SizedBox(width: 5),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.chat,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            post['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            post['content'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                post['createdAt'],
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                              const Spacer(),
                              Text(
                                post['schoolName'],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddPostScreen()));
        },
        child: const Icon(
          Icons.edit_document,
          color: Colors.white,
        ),
      ),
    );
  }
}
