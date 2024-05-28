// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';

class DonationProgressBar extends StatefulWidget {
  final String? username;
  final String? teamName;

  const DonationProgressBar({Key? key, this.username, this.teamName})
      : assert(username != null || teamName != null,
            'Either username or teamName must be provided'),
        super(key: key);

  @override
  _DonationProgressBarState createState() => _DonationProgressBarState();
}

class _DonationProgressBarState extends State<DonationProgressBar> {
  double? totalDonations = 0;
  double? donationGoal = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
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
      double? total;
      if (widget.username != null) {
        total = await ApiUtils.fetchDonations(widget.username!);
      } else {
        total = await ApiUtils.fetchOtherFundraiserBox(widget.teamName!);
      }
      setState(() {
        totalDonations = total;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchGoal() async {
    try {
      double? goal;
      if (widget.username != null) {
        goal = await ApiUtils.fetchGoal(widget.username!);
      } else {
        goal = await ApiUtils.fetchOtherDonationGoal(widget.teamName!);
      }
      setState(() {
        donationGoal = goal;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double percentage =
        donationGoal != 0 ? totalDonations! / donationGoal! : 0.0;

    return LinearProgressIndicator(
      value: percentage,
      backgroundColor: Colors.white,
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
      borderRadius: BorderRadius.circular(20),
    );
  }
}
