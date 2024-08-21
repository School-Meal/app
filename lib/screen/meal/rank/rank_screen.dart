// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:school_meal/screen/services/auth_service.dart';

// class RankScreen extends StatefulWidget {
//   const RankScreen({super.key});

//   @override
//   State<RankScreen> createState() => _RankScreenState();
// }

// class _RankScreenState extends State<RankScreen> {
//   final AuthService _authService = AuthService();
//   List<Map<String, dynamic>> rankedPosts = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchRankedPosts();
//   }

//   Future<void> _fetchRankedPosts() async {
//     try {
//       // 1. Access Token 가져오기
//       String? accessToken = await _authService.getValidAccessToken();
//       if (accessToken == null) {
//         _showErrorDialog('토큰이 만료되었습니다. 다시 로그인하세요.');
//         return;
//       }

//       // 2. 게시물 가져오기
//       final postUrl = Uri.parse('${dotenv.env['API_URL']}/post');
//       final postResponse = await http.get(postUrl, headers: {
//         'Authorization': 'Bearer $accessToken',
//       });

//       if (postResponse.statusCode == 200) {
//         final List<dynamic> postData = json.decode(postResponse.body);

//         // 3. 게시물 별 좋아요 수 가져오기
//         List<Map<String, dynamic>> postsWithLikes = [];
//         for (var post in postData) {
//           final likeUrl =
//               Uri.parse('${dotenv.env['API_URL']}/like/count/${post['id']}');
//           final likeResponse = await http.get(likeUrl, headers: {
//             'Authorization': 'Bearer $accessToken',
//           });

//           int likeCount = 0;
//           if (likeResponse.statusCode == 200) {
//             likeCount = int.parse(likeResponse.body);
//           }

//           postsWithLikes.add({
//             'id': post['id'],
//             'title': post['title'],
//             'content': post['content'],
//             'likeCount': likeCount,
//             'imageUrl': post['imageUrl'],
//             'author': post['author'],
//             'createdAt': post['createdAt'],
//           });
//         }

//         // 4. 좋아요 수에 따라 게시물 정렬
//         postsWithLikes.sort((a, b) => b['likeCount'] - a['likeCount']);

//         // 5. 상태 업데이트
//         setState(() {
//           rankedPosts = postsWithLikes;
//         });
//       } else {
//         _showErrorDialog('게시물 가져오기에 실패했습니다.');
//       }
//     } catch (e) {
//       _showErrorDialog('오류가 발생했습니다.');
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('오류'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//             child: const Text('확인'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue.shade300,
//         centerTitle: false,
//         title: const Text(
//           "랭킹",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: const Icon(
//             Icons.arrow_back_ios_new,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             children: rankedPosts.isEmpty
//                 ? [const Text("랭킹 정보를 불러오는 중입니다...")]
//                 : rankedPosts.map((post) {
//                     return ListTile(
//                       title: Text(post['title']),
//                       subtitle: Text('좋아요 수: ${post['likeCount']}'),
//                       trailing: post['imageUrl'] != null
//                           ? Image.network(post['imageUrl'],
//                               width: 50, height: 50)
//                           : const Icon(Icons.image_not_supported),
//                       onTap: () {
//                         // 게시물 상세보기 화면으로 이동하는 로직 추가 가능
//                       },
//                     );
//                   }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:school_meal/screen/services/auth_service.dart';
import 'package:intl/intl.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({Key? key}) : super(key: key);

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
      // 1. Access Token 가져오기
      String? accessToken = await _authService.getValidAccessToken();
      if (accessToken == null) {
        _showErrorDialog('토큰이 만료되었습니다. 다시 로그인하세요.');
        return;
      }

      // 2. 게시물 가져오기
      final postUrl = Uri.parse('${dotenv.env['API_URL']}/post');
      final postResponse = await http.get(postUrl, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (postResponse.statusCode == 200) {
        final List<dynamic> postData = json.decode(postResponse.body);

        // 3. 게시물 별 좋아요 수 가져오기
        List<Map<String, dynamic>> postsWithLikes = [];
        for (var post in postData) {
          final likeUrl =
              Uri.parse('${dotenv.env['API_URL']}/like/count/${post['id']}');
          final likeResponse = await http.get(likeUrl, headers: {
            'Authorization': 'Bearer $accessToken',
          });

          int likeCount = 0;
          if (likeResponse.statusCode == 200) {
            likeCount = int.parse(likeResponse.body);
          }

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

        // 4. 좋아요 수에 따라 게시물 정렬
        postsWithLikes.sort((a, b) => b['likeCount'] - a['likeCount']);

        // 5. 상태 업데이트
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
            onPressed: () {
              Navigator.of(ctx).pop();
            },
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

  Widget _buildTopThree() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (rankedPosts.length > 1)
            _buildTopItem(rankedPosts[1], 2, Colors.grey),
          if (rankedPosts.isNotEmpty)
            _buildTopItem(rankedPosts[0], 1, Colors.amber),
          if (rankedPosts.length > 2)
            _buildTopItem(rankedPosts[2], 3, Colors.brown.shade400),
        ],
      ),
    );
  }

  Widget _buildTopItem(Map<String, dynamic> post, int rank, Color color) {
    double size = rank == 1 ? 120 : 100;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$rank',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 8),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            image: post['imageUrl'] != null
                ? DecorationImage(
                    image: NetworkImage(post['imageUrl']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: post['imageUrl'] == null
              ? Icon(Icons.image, size: size / 2, color: color)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          post['title'],
          style: TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            Image.asset(
              'assets/images/like.png',
              width: 18,
            ),
            SizedBox(width: 5),
            Text(
              '${post['likeCount']}',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRankList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: rankedPosts.length > 3 ? rankedPosts.length - 3 : 0,
      itemBuilder: (context, index) {
        final post = rankedPosts[index + 3];
        return Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: post['imageUrl'] != null
                  ? NetworkImage(post['imageUrl'])
                  : null,
              child: post['imageUrl'] == null ? Icon(Icons.image) : null,
            ),
            title: Text(post['title'],
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
                '${post['author']['nickName']} • ${_formatDate(post['createdAt'])}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${index + 4}위',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${post['likeCount']}',
                    style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        centerTitle: false,
        title: const Text(
          "랭킹",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.blue,
            ))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopThree(),
                  Divider(thickness: 1, height: 1),
                  _buildRankList(),
                ],
              ),
            ),
    );
  }
}
