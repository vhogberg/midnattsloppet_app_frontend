// ignore_for_file: avoid_print

import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  static SessionManager get instance => _instance;

  static const String _sessionKey = 'session_token';
  static String? _username;
  static String? _sessionToken;

  String? get username => _username;

  Future<void> saveSessionToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, token);
    _sessionToken = token;
    _extractUsernameFromToken(token);
  }

  Future<String?> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionToken = prefs.getString(_sessionKey);
    if (_sessionToken != null) {
      _extractUsernameFromToken(_sessionToken!);
    }
    return _sessionToken;
  }

  Future<void> _extractUsernameFromToken(String token) async {
    final List<String> parts = token.split(':');
    if (parts.length == 2) {
      _username = parts[0];
    }
  }

  Future<String> loginUser(String username, String password) async {
    const url = 'https://group-15-7.pvt.dsv.su.se/app/login';
    final credentials = {'username': username, 'password': password};
    final response = await ApiUtils.post(url, credentials);

    if (response.statusCode == 200) {
      final String sessionToken = response.body;
      await saveSessionToken(sessionToken);
      return sessionToken;
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<bool> signUserOut() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? sessionToken = prefs.getString(_sessionKey);
      if (sessionToken != null) {
        const url = 'https://group-15-7.pvt.dsv.su.se/app/logout';
        final response = await ApiUtils.logout(
          url,
          headers: {
            'Authorization': 'Bearer $sessionToken',
          },
        );
        if (response.statusCode == 200) {
          prefs.remove(_sessionKey);
          await prefs.clear();
          return true; // Sign-out successful
        } else {
          throw Exception('Failed to logout: ${response.statusCode}');
        }
      } else {
        // Session token is already null, so consider it as successful sign-out
        return true;
      }
    } catch (e) {
      print('Failed to logout: $e');
      return false; // Sign-out failed
    }
  }
}
