import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/notification_api.dart';
import 'package:flutter_application/auth_page.dart';
import 'package:flutter_application/pages/login_page/login_widget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// NOTIFIKATIONER
final navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// NOTIFIKATIONER

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // se till att notifikationsklass alltid körs
  await LocalNotifications.init();

// NOTIFIKATIONER
  //  hantera  i vissa states
  var initialNotification =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (initialNotification?.didNotificationLaunchApp == true) {
    // LocalNotifications.onClickNotification.stream.listen((event) {
    Future.delayed(Duration(seconds: 1), () {
      // print(event);
      navigatorKey.currentState!.pushNamed('/another',
          arguments: initialNotification?.notificationResponse?.payload);
    });
  }
// NOTIFIKATIONER


  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
