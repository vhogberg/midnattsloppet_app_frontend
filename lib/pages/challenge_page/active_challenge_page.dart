import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:iconsax/iconsax.dart';

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
                Container(
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: 470,
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
                    children: [
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
                      IntrinsicHeight(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Insamlat',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${totalDonations.toStringAsFixed(0)} kr',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                              const VerticalDivider(
                                width: 60,
                                thickness: 2,
                                indent: 0,
                                endIndent: 0,
                                color: Colors.white,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Insamlat',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${totalDonations.toStringAsFixed(0)} kr',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                      const Divider(
                        height: 0,
                        color: Colors.white,
                        thickness: 2,
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 170),
                        child: const SingleChildScrollView(
                          child: Text(
                            'Egen tävling: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor inciLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmodLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmodLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmodLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmodLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmoddidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Knappens funktionalitet ska in här
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Redigera utmaning',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Sora',
                                  ),
                                ),
                                Icon(
                                  Icons.create,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.white,
                        thickness: 2,
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height:
                                        8.0), // För att skapa lite avstånd mellan texterna
                                Text(
                                  'Tidsresultat publiceras på\nMidnattsloppets hemsida:',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Sora'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                              width:
                                  14.0), // För att skapa lite avstånd mellan kolumnen och knappen
                          ElevatedButton(
                            onPressed: () {
                              // Knappens funktionalitet ska in här
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'Hemsida',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Sora'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
