import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class DonationProgressBar extends StatefulWidget {
  final double goal;

  const DonationProgressBar({Key? key, required this.goal}) : super(key: key);

  @override
  _DonationProgressBarState createState() => _DonationProgressBarState();
}

class _DonationProgressBarState extends State<DonationProgressBar> {
  double totalDonations = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState(); //Initial donation fetch
    fetchDonations();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDonations();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchDonations() async {
    try {
      // Make HTTP GET request to fetch donation amounts from the API
      var response =
          await http.get(Uri.parse('https://your-api.com/donations'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        var data = json.decode(response.body);

        // Calculate total donations
        double total = 0;
        for (var donation in data['donations']) {
          total += donation['amount'];
        }

        // Update the totalDonations variable and rebuild the widget
        setState(() {
          totalDonations = total;
        });
      } else {
        throw Exception('Failed to fetch donations');
      }
    } catch (e) {
      print('Error fetching donations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the percentage of donations raised
    double percentage = totalDonations / widget.goal;

    return LinearProgressIndicator(
      value: percentage,
      backgroundColor: Colors.grey[300],
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
      borderRadius: BorderRadius.circular(20),
    );
  }
}
