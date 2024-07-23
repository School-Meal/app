import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TokenManager {
  Future<String> _getTokenPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/token.txt';
  }

  Future<void> saveToken(String token) async {
    final path = await _getTokenPath();
    final file = File(path);
    await file.writeAsString(token);
  }

  Future<String?> readToken() async {
    try {
      final path = await _getTokenPath();
      final file = File(path);
      String token = await file.readAsString();
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteToken() async {
    final path = await _getTokenPath();
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
