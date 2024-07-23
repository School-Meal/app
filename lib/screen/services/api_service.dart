import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_manager.dart';

class ApiService {
  final TokenManager _tokenManager = TokenManager();

  Future<void> refreshToken() async {
    String? token = await _tokenManager.readToken();

    final url = Uri.parse('http://52.78.20.150/auth/refresh');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['accessToken'] != null) {
        await _tokenManager.saveToken(responseData['accessToken']);
      } else {
        print('Error refreshing token: No new token received');
      }
    } else {
      print('Error refreshing token: ${response.statusCode}');
    }
  }

  Future<http.Response> get(String endpoint) async {
    String? token = await _tokenManager.readToken();
    final url = Uri.parse('http://52.78.20.150$endpoint');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await refreshToken();
      token = await _tokenManager.readToken();
      final retryResponse = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return retryResponse;
    }
    return response;
  }
}
