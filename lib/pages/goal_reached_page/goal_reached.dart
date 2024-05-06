import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeamGoalReached extends StatefulWidget {
  const TeamGoalReached({Key? key}) : super(key: key);

  @override
  _TeamGoalReachedState createState() => _TeamGoalReachedState();
}

class _TeamGoalReachedState extends State<TeamGoalReached> {
  bool isGoalReached = false;
  String? username;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    startGoalCheck(username);
  }

  void startGoalCheck(String? username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      checkGoalReached(username, prefs);
    });
  }

  Future<void> checkGoalReached(
      String? username, SharedPreferences prefs) async {
    try {
      var url = Uri.parse(
          'https://group-15-7.pvt.dsv.su.se/app/team/$username/checkGoal');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          isGoalReached = response.body.toLowerCase() == 'true';
        });
        if (isGoalReached && !(prefs.getBool('dialogShown') ?? false)) {
          prefs.setBool('dialogShown', true);
          showCustomDialog(context);
        }
      }
    } catch (e) {
      print('Error checking goal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: isGoalReached ? const Text('') : const Text(''),
        ),
      ),
    );
  }

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
                      'Tack så hemskt mycket!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Eran insats kommer att göra en verklig skillnad och bidra till en bättre värld! Vi är djupt tacksamma för er godhet och stöd.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MyButton(
                      text: "Tillbaka",
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
