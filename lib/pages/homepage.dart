import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;

  @override
  void initState() {
    super.initState();
    getUsernameFromSession();
  }

  Future<void> getUsernameFromSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');
    if (sessionToken != null) {
      // Extract username from session token
      final List<String> parts = sessionToken.split(':');
      if (parts.length == 2) {
        setState(() {
          username = parts[0];
        });
      }
    }
  }

  // method to sign the user out TODO: move to session manager(?) 
  void signUserOut(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? sessionToken = prefs.getString('session_token');
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
          prefs.remove('session_token');
          // Navigate back to the login screen
          Navigator.popUntil(context, ModalRoute.withName('/'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () =>
                signUserOut(context), // Call signUserOut method on press
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: username != null
            ? Text("Logged in as: $username")
            : CircularProgressIndicator(), // Display a loading indicator while retrieving username
      ),
    );
  }
}
