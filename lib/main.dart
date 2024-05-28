import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/local_notifications.dart';
import 'package:flutter_application/authentication/auth_page.dart';
import 'package:flutter_application/pages/notification_page.dart';
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
  DailyAbsenceCheck().dailyNotification();
  ScheduledNotification().notification50DaysLeft();
  ScheduledNotification().notification100DaysLet();

// NOTIFIKATIONER
  //  hantera  i vissa states
  var initialNotification =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (initialNotification?.didNotificationLaunchApp == true) {
    // LocalNotifications.onClickNotification.stream.listen((event) {
    Future.delayed(const Duration(seconds: 1), () {
      // print(event);
      navigatorKey.currentState!.pushNamed('/notificationPage',
          arguments: initialNotification?.notificationResponse?.payload);
    });
  }
// NOTIFIKATIONER

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        NotificationPage.routeName: (context) => NotificationPage(),
      },
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}

class DailyAbsenceCheck {
  void dailyNotification() {
    LocalNotifications.cancel(1);
    LocalNotifications.showPeriodicNotifications(
        title: "Gå in i appen och se hur erat lag ligger till!",
        body: "Kolla på sidorna för lapkamp och topplista för mer information",
        payload: "notification_page");
  }
}

class ScheduledNotification {
  void notification50DaysLeft() {
    LocalNotifications.showNotificationWhen50DaysLeft(
        id: 10,
        title: "50 Dagar kvar till loppet!",
        body: "Nu är det bara 50 dagar kvar!",
        payload: "50 dagar");
  }

  void notification100DaysLet() {
    LocalNotifications.showNotificationWhen100DaysLeft(
        id: 20,
        title: "100 Dagar kvar till loppet!",
        body: "Nu är det bara 100 dagar kvar!",
        payload: "100 dagar");
  }
}
