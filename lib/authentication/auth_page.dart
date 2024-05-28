// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/components/custom_navigation_bar.dart';
import 'package:flutter_application/pages/login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late Future<String?> _sessionTokenFuture;

  @override
  void initState() {
    super.initState();
    _sessionTokenFuture = SessionManager.instance.getSessionToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String?>(
        future: _sessionTokenFuture,
        builder: (context, snapshot) {
          // Handle waiting state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle loaded state
          if (snapshot.hasData && snapshot.data != null) {
            return const CustomNavigationBar(selectedPage: 0,);
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
