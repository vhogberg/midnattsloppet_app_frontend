import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    final url = Uri.parse('https://group-15-7.pvt.dsv.su.se/app/login');
    final credentials = {'username': username, 'password': password};
    final jsonBody = jsonEncode(credentials);

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        final String sessionToken = response.body;
        await saveSessionToken(sessionToken);
        return sessionToken;
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> signUserOut(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? sessionToken = prefs.getString(_sessionKey);
      if (sessionToken != null) {
        // Call logout endpoint on the backend
        final url = Uri.parse('https://group-15-7.pvt.dsv.su.se/app/logout');
        final response = await http.post(
          url,
          headers: <String, String>{
            'Authorization':
                'Bearer $sessionToken', // Include session token in the request header
          },
        );
        if (response.statusCode == 200) {
          // Clear session token from local storage
          prefs.remove(_sessionKey);
          // Navigate back to the login screen and remove all routes on top
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          print("Logout successful");
        } else {
          throw Exception('Failed to logout: ${response.statusCode}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout: $e'),
        ),
      );
    }
  }
}
