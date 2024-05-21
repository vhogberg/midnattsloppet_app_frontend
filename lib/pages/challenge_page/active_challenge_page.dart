import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/gradient_container.dart';
import 'package:flutter_application/session_manager.dart';

class ActiveChallengePage extends StatefulWidget {
  const ActiveChallengePage({Key? key}) : super(key: key);

  @override
  _ActiveChallengePageState createState() => _ActiveChallengePageState();
}

class _ActiveChallengePageState extends State<ActiveChallengePage> {
  String? username;
  String? charityName;
  String? teamName;
  String? companyName;
  int teamRank = -1;
  int totalTeams = 0;
  double donationGoal = 0;
  double totalDonations = 0;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    fetchDonations();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lagkamp'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'images/CompetitionImage.png',
              fit: BoxFit.fitWidth,
            ),
            const SizedBox(height: 10),
            const Text(
              'Aktiv utmaning',
              style: TextStyle(
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Sora',
              ),
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                GradientContainer(
                  width: MediaQuery.of(context).size.width,
                  height: 460,
                  gradientAlignment: Alignment(0.4, 0.5),
                ),
                Column(
                  children: [
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Nordea lag 5 vs. Nordea lag 7',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Insamlat',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 60),
                        Text(
                          'Insamlat',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${totalDonations.toStringAsFixed(0)} kr insamlat',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 60),
                        Text(
                          '${totalDonations.toStringAsFixed(0)} kr insamlat',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(
                      color: Colors.white,
                      thickness: 2,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Egen tävling: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(
                      color: Colors.white,
                      thickness: 2,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(
                      color: Colors.white,
                      thickness: 2,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
