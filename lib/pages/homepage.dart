import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/api_utils/local_notifications.dart';
import 'package:flutter_application/components/donation_progress_bar.dart';
import 'package:flutter_application/components/goal_box.dart';
import 'package:flutter_application/main.dart';
import 'package:flutter_application/pages/notification_page/notification_page.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:flutter_application/share_helper.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  String? charityName;
  String? teamName;
  double donationGoal = 0;
  double totalDonations = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    //LocalNotifications.init();
    fetchGoal();
    fetchDonations();
    fetchCharityName();
    fetchTeamName();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchGoal();
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

  Future<void> fetchTeamName() async {
    try {
      String? teName = await ApiUtils.fetchTeamName(username);
      setState(() {
        teamName = teName;
      });
    } catch (e) {
      print("Error fetching teamname: $e");
    }
  }

  Future<void> fetchCharityName() async {
    try {
      String? chaName = await ApiUtils.fetchCharityName(username);
      setState(() {
        charityName = chaName;
      });
    } catch (e) {
      print("Error fetching charity name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
              child: Row(
                children: [
                  const Text(
                    "Godmorgon!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Sora',
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page here
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationPage()),
                      );
                    },
                    child: Stack(
                      children: [
                        const Icon(
                          Iconsax.notification,
                          size: 35,
                          color: Color.fromARGB(255, 113, 113, 113),
                        ),
                        if (1 ==
                            0 /** Denna if-satsen finns om vi hittar något sätt att kontrollera om det finns olästa notifikationer, just nu tar detta för mkt tid*/)
                          Positioned(
                            // position på cirkeln
                            top: 0,
                            right: 0,
                            child: Container(
                              padding:
                                  const EdgeInsets.all(1), // Storlek på cirkeln
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 241, 75, 75),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.notification_12,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      SessionManager.instance.signUserOut(context);
                    },
                    child: const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage('images/stockholm-university.png'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        height: 320,
                        decoration: BoxDecoration(
                          color: const Color(0XFF3C4785),
                          borderRadius: BorderRadius.circular(12.0),
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
                              'Insamlingsbössa: $teamName',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '${totalDonations.toStringAsFixed(0)} kr insamlat',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Stödjer: $charityName',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 80,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 30, right: 30),
                                child: DonationProgressBar(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Align(
                                alignment: Alignment.topRight,
                                child: GoalBox(height: 50, width: 75)),
                            const SizedBox(height: 10),
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  width: MediaQuery.of(context).size.width,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(13.0),
                                    border: Border.all(
                                      color: Colors.white60, // Border color
                                      width: 1.0, // Border width
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Dela bössan med vänner och familj!',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Sora'),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          ShareHelper.showShareDialog(
                                              context, teamName!);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          width: 100,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(13.0),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Iconsax.export_1,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'Dela',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'Sora',
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: SizedBox(
                          width: 65,
                          height: 65,
                          child: Image.asset(
                              'images/chrome_DmBUq4pVqL-removebg-preview.png'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Container(
                        width: 400,
                        height: 320,
                        decoration: BoxDecoration(
                          color: const Color(0XFF3C4785),
                          borderRadius: BorderRadius.circular(20.0),
                          gradient: const RadialGradient(
                            radius: 0.8,
                            center: Alignment(0.2, 0.6),
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
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(50),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(13.0),
                              border: Border.all(
                                color: Colors.white60, // Border color
                                width: 1.0, // Border width
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
