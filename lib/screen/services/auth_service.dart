import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _refreshUrl = Uri.parse('http://52.78.20.150/auth/refresh');

  // 토큰이 만료되었는지 확인하는 함수
  bool _isTokenExpired(String token) {
    try {
      // JWT 토큰을 디코딩하여 만료 시간을 확인
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // exp 필드에서 만료 시간을 가져옴 (Unix 타임스탬프)
      int exp = decodedToken['exp'];

      // 현재 시간을 Unix 타임스탬프로 가져옴
      int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // 남은 시간 계산
      int timeLeft = exp - currentTime;

      // 남은 시간 출력
      print('남은 시간: ${timeLeft ~/ 60}분 ${timeLeft % 60}초');

      // 만료 시간을 현재 시간과 비교
      return currentTime >= exp;
    } catch (e) {
      // 토큰이 잘못된 경우, 만료된 것으로 간주
      print('Error decoding JWT: $e');
      return true;
    }
  }

  // 유효한 access token을 반환하거나, 필요시 재발급
  Future<String?> getValidAccessToken() async {
    String? accessToken = await _storage.read(key: 'accessToken');
    if (accessToken == null || _isTokenExpired(accessToken)) {
      bool success = await _refreshAccessToken();
      if (success) {
        accessToken = await _storage.read(key: 'accessToken');
      } else {
        return null;
      }
    }
    return accessToken;
  }

  // refresh token을 사용해 access token 재발급
  Future<bool> _refreshAccessToken() async {
    String? refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return false;

    try {
      final response = await http.get(
        _refreshUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final newAccessToken = responseData['accessToken'];
        final newRefreshToken = responseData['refreshToken'];

        // 새로운 토큰 저장
        await _storage.write(key: 'accessToken', value: newAccessToken);
        await _storage.write(key: 'refreshToken', value: newRefreshToken);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }
}
