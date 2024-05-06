import 'package:flutter/material.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'dart:async';

class DonationProgressBar extends StatefulWidget {
  const DonationProgressBar({Key? key}) : super(key: key);

  @override
  _DonationProgressBarState createState() => _DonationProgressBarState();
}

class _DonationProgressBarState extends State<DonationProgressBar> {
  double totalDonations = 0;
  double donationGoal = 0;
  String? username;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    fetchDonations();
    fetchGoal();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDonations();
      fetchGoal();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchDonations() async {
    try {
      double total = await ApiUtils.fetchDonations(username);
      setState(() {
        totalDonations = total;
      });
    } catch (e) {
      print("Error");
    }
  }

  Future<void> fetchGoal() async {
    try {
      double goal = await ApiUtils.fetchGoal(username);
      setState(() {
        donationGoal = goal;
      });
    } catch (e) {
      print("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    double percentage = donationGoal != 0 ? totalDonations / donationGoal : 0.0;

    return LinearProgressIndicator(
      value: percentage,
      backgroundColor: Colors.grey[300],
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
      borderRadius: BorderRadius.circular(20),
    );
  }
}
