// ignore_for_file: library_private_types_in_public_api, use_super_parameters, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamGoalReached extends StatefulWidget {
  const TeamGoalReached({Key? key}) : super(key: key);

  @override
  _TeamGoalReachedState createState() => _TeamGoalReachedState();
}

class _TeamGoalReachedState extends State<TeamGoalReached> {
  late SharedPreferences _prefs;
  late String? username;
  double donationGoal = 0;
  double totalDonations = 0;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _startGoalCheck(username);
  }

  void _startGoalCheck(String? username) {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchDonationsAndGoal();
    });
  }

  Future<void> _fetchDonationsAndGoal() async {
    try {
      final fetchedDonations = await ApiUtils.fetchDonations(username);
      final fetchedGoal = await ApiUtils.fetchGoal(username);

      if (mounted) {
        setState(() {
          totalDonations = fetchedDonations;
          donationGoal = fetchedGoal;
        });
      }
      // Show custom dialog if needed after state has been updated
      _showCustomDialogIfNeeded();
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _showCustomDialogIfNeeded() {
    if (totalDonations >= donationGoal) {
      if (!_prefs.containsKey('dialogShown') ||
          !(_prefs.getBool('dialogShown') ?? false)) {
        _prefs.setBool('dialogShown', true);
        _showCustomDialog(context);
      }
    }
  }

  void _showCustomDialog(BuildContext context) {
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
                      'Tack!',
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
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _fetchDonationsAndGoal();
    return const SizedBox(); // Tom widget, då dialogen visas utan att täcka något annat
  }
}
