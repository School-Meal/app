import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:school_meal/screen/post/add/add_screen.dart';
import 'package:intl/intl.dart';
import 'package:school_meal/screen/post/edit/edit_screen.dart';
import 'package:school_meal/screen/services/auth_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> posts = [];
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId(); // 현재 사용자 ID 가져오기
    _fetchPostsAndLikeCounts();
  }

  Future<void> _fetchCurrentUserId() async {
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
            currentUserId = profileData['id'];
          });
        } else {
          print('Failed to load user data');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _fetchPostsAndLikeCounts() async {
    await _fetchPosts();
    await _fetchLikeCounts();
  }

  Future<void> _fetchPosts() async {
    final url = Uri.parse('${dotenv.env['API_URL']}/post');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> postData = json.decode(response.body);
        setState(() {
          posts = postData.map((data) {
            return {
              'id': data['id'],
              'authorId': data['author']['id'], // 작성자 ID 추가
              'title': data['title'],
              'content': data['content'],
              'imageUrl': data['imageUrl'],
              'nickName': data['author']['nickName'],
              'imageUri': data['author']['imageUri'],
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
      final url = Uri.parse('${dotenv.env['API_URL']}/like/count/$postId');
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

  void _editPost(Map<String, dynamic> post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(
          postId: post['id'],
          initialTitle: post['title'],
          initialContent: post['content'],
          initialImageUrl: post['imageUrl'],
        ),
      ),
    );

    // result가 true인 경우에만 새로고침
    if (result == true) {
      _fetchPostsAndLikeCounts();
    }
  }

  Future<void> _deletePost(int postId) async {
    String? accessToken = await _authService.getValidAccessToken();
    if (accessToken == null) {
      print('Access token is null');
      return;
    }

    final url = Uri.parse('${dotenv.env['API_URL']}/post/$postId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          posts.removeWhere((post) => post['id'] == postId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 삭제되었습니다.')),
        );
      } else if (response.statusCode == 401) {
        // 서버에서 반환된 메시지를 디코딩하여 가져옴
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? '삭제 권한이 없습니다.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(message),
          ),
        );
      } else {
        print('Failed to delete post');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물 삭제에 실패했습니다.')),
        );
      }
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오류가 발생했습니다.')),
      );
    }
  }

  String _formatDate(String dateTime) {
    final DateTime date = DateTime.parse(dateTime);
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }

  void _confirmDeletePost(Map<String, dynamic> post) {
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
                Navigator.of(context).pop();
                _deletePost(post['id']);
              },
            ),
          ],
        );
      },
    );
  }

  void _reportPost(Map<String, dynamic> post) {
    // 신고 처리 로직을 여기에 구현
    print('Report post: ${post['id']}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('신고가 접수되었습니다.')),
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
                final isDefaultUser = nickName == "사용자";

                final isCurrentUserPost =
                    currentUserId != null && post['authorId'] == currentUserId;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: isDefaultUser
                                  ? const Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.grey,
                                    )
                                  : (post['imageUri'] != null
                                      ? Image.network(
                                          post['imageUri'],
                                          width: double.infinity,
                                          height: 300,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 30,
                                          color: Colors.grey,
                                        )),
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
                                _confirmDeletePost(post);
                              } else if (result == 'report') {
                                _reportPost(post);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              if (isCurrentUserPost) ...[
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/edit.png',
                                        width: 25,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text('수정'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete),
                                      SizedBox(width: 5),
                                      Text('삭제'),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                PopupMenuItem<String>(
                                  value: 'report',
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/report.png',
                                        width: 30,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text('신고'),
                                    ],
                                  ),
                                ),
                              ],
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
                              const SizedBox(width: 10),
                              LikeButton(
                                likeCount: 1,
                                likeBuilder: (isTapped) {
                                  return Icon(
                                    Icons.chat,
                                    color: isTapped ? Colors.blue : Colors.grey,
                                    size: 30,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPostScreen(),
            ),
          ).then((result) {
            if (result == true) {
              _fetchPostsAndLikeCounts(); // 게시물 생성 후 새로고침
            }
          });
        },
        child: const Icon(
          Icons.edit_document,
          color: Colors.white,
        ),
      ),
    );
  }
}
