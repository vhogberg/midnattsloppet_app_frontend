import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:http/http.dart' as http;

class TeamGoalReached extends StatefulWidget {
  const TeamGoalReached({super.key});

  @override
  _TeamGoalReachedState createState() => _TeamGoalReachedState();
}

class _TeamGoalReachedState extends State<TeamGoalReached> {
  bool isGoalReached = false;
  String? username;

  @override
  void initState() {
    super.initState();
    // Start continuous goal check when the widget initializes
    username = SessionManager.instance.username;
    startGoalCheck(username);
  }

  // Method for continuous goal check
  void startGoalCheck(username) {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      checkGoalReached(username);
    });
  }

  // Method to check if the goal is reached
  Future<void> checkGoalReached(username) async {
    try {
      var url = Uri.parse(
          'https://group-15-7.pvt.dsv.su.se/app/team/$username/checkGoal');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          isGoalReached = response.body.toLowerCase() == 'true';
        });
        if (isGoalReached) {
          // If goal is reached, show notification
          showCustomDialog(context);
        }
      } else {}
    } catch (e) {
      print('Error checking goal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: isGoalReached
              ? const Text('')
              : const Text(''),
        ),
      ),
    );
  }

  // Method to show custom dialog when goal is reached
  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset('images/GoalCompleted.png',
                        fit: BoxFit.cover),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Text(
                      'Donation goal reached!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Thank you so much for making a difference!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MyButton(
                      text: "Back",
                      onTap: () {
                        Navigator.of(context).pop();
                      }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
