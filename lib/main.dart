import 'package:flutter/material.dart';
import 'package:flutter_application/pages/login_page/login_widget.dart';
import 'package:flutter_application/pages/registration/complete_profile_page.dart';
import 'package:flutter_application/pages/registration/register_page.dart';
import 'package:flutter_application/pages/registration/team/join_team_page.dart';
import 'package:flutter_application/pages/registration/team/team_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
