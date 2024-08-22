import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:school_meal/screen/services/auth_service.dart';
import 'package:intl/intl.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> rankedPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRankedPosts();
  }

  Future<void> _fetchRankedPosts() async {
    try {
      String? accessToken = await _authService.getValidAccessToken();
      if (accessToken == null) {
        _showErrorDialog('토큰이 만료되었습니다. 다시 로그인하세요.');
        return;
      }

      final postUrl = Uri.parse('${dotenv.env['API_URL']}/post');
      final postResponse = await http.get(postUrl, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (postResponse.statusCode == 200) {
        final List<dynamic> postData = json.decode(postResponse.body);
        List<Map<String, dynamic>> postsWithLikes = [];

        for (var post in postData) {
          final likeUrl =
              Uri.parse('${dotenv.env['API_URL']}/like/count/${post['id']}');
          final likeResponse = await http.get(likeUrl, headers: {
            'Authorization': 'Bearer $accessToken',
          });

          int likeCount =
              likeResponse.statusCode == 200 ? int.parse(likeResponse.body) : 0;

          postsWithLikes.add({
            'id': post['id'],
            'title': post['title'],
            'content': post['content'],
            'likeCount': likeCount,
            'imageUrl': post['imageUrl'],
            'author': post['author'],
            'createdAt': post['createdAt'],
          });
        }

        postsWithLikes.sort((a, b) => b['likeCount'] - a['likeCount']);

        setState(() {
          rankedPosts = postsWithLikes;
          isLoading = false;
        });
      } else {
        _showErrorDialog('게시물 가져오기에 실패했습니다.');
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateTime) {
    final DateTime date = DateTime.parse(dateTime);
    return DateFormat('yyyy.MM.dd').format(date);
  }

  Widget _buildRankItem(Map<String, dynamic> post, int rank) {
    final bool isTopThree = rank <= 3;
    final Color rankColor = rank == 1
        ? Colors.amber
        : (rank == 2 ? Colors.grey.shade400 : Colors.brown.shade200);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isTopThree ? rankColor.withOpacity(0.2) : Colors.grey.shade100,
            border: Border.all(
                color: isTopThree ? rankColor : Colors.grey.shade300, width: 2),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isTopThree ? rankColor : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        title: Text(
          post['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${post['author']['nickName']} • ${_formatDate(post['createdAt'])}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '❤️ ${post['likeCount']}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          "급식랭킹",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.blue,
            ))
          : ListView.builder(
              itemCount: rankedPosts.length,
              itemBuilder: (context, index) {
                return _buildRankItem(rankedPosts[index], index + 1);
              },
            ),
    );
  }
}
