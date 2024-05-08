import 'package:flutter/material.dart';
import 'package:flutter_application/components/my_navigation_bar.dart';
import 'package:flutter_application/pages/login_page/login_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyNavigationBar(),
    );
  }
}
