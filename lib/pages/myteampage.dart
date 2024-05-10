import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/donation_progress_bar.dart';
import 'package:flutter_application/pages/navigation_bar/navigation_bar.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/goal_box.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({Key? key}) : super(key: key);

  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  static const List<String> teamMembers = [
    'John Doe',
    'Jane Doe',
    'Adam Doe',
    'James Doe',
    'Carl Doe',
  ];
  String? username;
  double donationGoal = 0;
  double totalDonations = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    fetchGoal();
    fetchDonations();
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchGoal();
      fetchDonations();
    });
  }

  Future<void> fetchDonations() async {
    try {
      double total = await ApiUtils.fetchDonations(username);
      setState(() {
        totalDonations = total;
      });
    } catch (e) {
      print("Error fetching donations: $e");
    }
  }

  Future<void> fetchGoal() async {
    try {
      double goal = await ApiUtils.fetchGoal(username);
      setState(() {
        donationGoal = goal;
      });
    } catch (e) {
      print("Error fetching goal: $e");
    }
  }

  // Method to generate ListTiles dynamically based on team members list
  List<Widget> generateTeamList() {
    List<Widget> listTiles = [];
    for (int i = 0; i < teamMembers.length; i += 2) {
      if (i + 1 < teamMembers.length) {
        listTiles.add(Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text(
                  teamMembers[i],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14, // smaller font size
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  teamMembers[i + 1],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14, // smaller font size
                  ),
                ),
              ),
            ),
          ],
        ));
      } else {
        listTiles.add(ListTile(
          title: Text(
            teamMembers[i],
            style: TextStyle(
              color: Colors.black,
              fontSize: 14, // smaller font size
            ),
          ),
        ));
      }
    }
    return listTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: null,
        title: 'Mitt lag',
        // teampage ska ha en logout-knapp till höger, så detta nedan sätts "true"
        useActionButton: true,
        // logout knapp från Iconsax bilbiotek
        actionIcon: Iconsax.logout_1,
        // kalla på onActionPressed metoden också, använd sessionmanager för att logga ut
        onActionPressed: () {
          SessionManager.instance.signUserOut(context);
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular team picture at the middle top
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0XFF3C4785), // Use the blue color provided
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 74,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      AssetImage('images/stockholm-university.png'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Textbox with the donation pledge name
          // import via API?
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                'Stödjer: Barncancerfonden', // Static text
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Container with team members names
          Container(
            width: double.infinity,
          height: 500,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0XFF3C4785),
              borderRadius: BorderRadius.circular(13.0),
              gradient: const RadialGradient(
                radius: 0.8,
                center: Alignment(-0.5, 0.4),
                colors: [
                  Color.fromARGB(255, 140, 90, 100), // Start color
                  Color(0xFF3C4785), // End color
                ],
                stops: [
                  0.15,
                  1.0,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lagmedlemmar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                // Generate ListTiles dynamically
                ...generateTeamList(),
                SizedBox(height: 20),
                // Display fetched data
                Container(
                  width: 345,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(13.0),
                    border: Border.all(
                      color: Colors.white60, // Border color
                      width: 1.0, // Border width
                    ),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${totalDonations.toStringAsFixed(0)} kr insamlat',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mål: ${donationGoal.toStringAsFixed(0)} kr',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      DonationProgressBar(),
                      Positioned(
                        left: 300,
                        child: SizedBox(width: 50, child: GoalBox(),),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
