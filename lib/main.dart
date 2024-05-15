import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/notification_api.dart';
import 'package:flutter_application/components/my_navigation_bar.dart';
import 'package:flutter_application/pages/homepage.dart';
import 'package:flutter_application/pages/login_page/login_widget.dart';
import 'package:flutter_application/pages/notification_page/notification_manager.dart';
import 'package:flutter_application/pages/notification_page/notification_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationApi.init();
  NotificationManager.instance.hasUnreadNotifications;
  runApp(const MyApp());
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
