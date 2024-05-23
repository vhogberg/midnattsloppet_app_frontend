import 'package:flutter/material.dart';
import 'package:flutter_application/session_manager.dart';

class SignOutDialog {
  static void show(BuildContext context) {
    NavigatorState navigator = Navigator.of(context,
        rootNavigator: true); // Store a reference to the Navigator
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Bekräfta logga ut',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
          content: Text(
            'Är du säker att du vill logga ut?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Avbryt',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Sora',
                ),
              ),
              onPressed: () {
                navigator.pop(); // Use the stored reference to pop the dialog
              },
            ),
            TextButton(
              child: Text(
                'Logga ut',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Sora',
                ),
              ),
              onPressed: () async {
                navigator.pop(); // Close the dialog first
                // Delay the sign out slightly to ensure the dialog is fully closed
                Future.delayed(Duration(milliseconds: 100), () async {
                  bool signOutSuccess =
                      await SessionManager.instance.signUserOut();
                  if (signOutSuccess) {
                    navigator.pushNamedAndRemoveUntil(
                        '/',
                        (route) =>
                            false); // Use the stored reference to navigate
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to sign out'),
                      ),
                    );
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
