import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyGoalReached extends StatefulWidget {
  const MyGoalReached({Key? key}) : super(key: key);

  @override
  _MyGoalReachedState createState() => _MyGoalReachedState();
}

class _MyGoalReachedState extends State<MyGoalReached> {
  bool isGoalReached = false;

  @override
  void initState() {
    super.initState();
    // Starta kontinuerlig kontroll av målet när widgeten initialiseras
    startGoalCheck();
  }

  // Metod för att kontinuerligt kontrollera om målet har nåtts
  // Är däremot osäker på om detta är en bra lösning...
  void startGoalCheck() {
    Timer.periodic(Duration(minutes: 5), (timer) {
      checkGoalReached();
    });
  }

  // Metod för att göra en GET-förfrågan till servern för att kontrollera om målet har nåtts
  Future<void> checkGoalReached() async {
    try {
      var url = Uri.parse(
          'https://group-15-7.pvt.dsv.su.se/app/team/{teamId}/checkGoal'); //på något sätt få tag på teamId
      var response = await http.get(url);
      if (response.statusCode == 200) {
        // Om målet har nåtts, visa popup-rutan
        setState(() {
          isGoalReached = response.body.toLowerCase() == 'true';
        });
      } else {
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
          child: isGoalReached    // inte helt säker på vad som händer här
              ? ElevatedButton(   // men kort och gott ---> om isGoalReached == true 
                  onPressed: () { // ---> tryck på en osynlig knapp som sätter igång notifikation??? eller?
                    showCustomDialog(context);
                  },
                  child: Text('Show Goal Reached Dialog'),
                )
              : Text('Donation goal not reached yet'),
        ),
      ),
    );
  }

  // Metod för att visa popup-rutan när målet har nåtts
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset('images/goal_reached.png',
                        fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    child: Text(
                      'Donation goal reached!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Thank you so much for making a difference!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Color(int.parse('0xFF3C4785')), // Justerad till lila
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
