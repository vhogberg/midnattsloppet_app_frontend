import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/models/challenge.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveChallengePage extends StatefulWidget {
  const ActiveChallengePage({Key? key}) : super(key: key);

  @override
  _ActiveChallengePageState createState() => _ActiveChallengePageState();
}

class _ActiveChallengePageState extends State<ActiveChallengePage> {
  String? username;

  String? userTeamName; // MITT LAG NAMN
  String? otherTeamName; // ANDRA LAGETS NAMN

  double? myTeamDonations; // MITT LAG
  double? otherTeamDonations; // ANDRA LAGET

  List<Challenge> challenges = []; // Initiera en lista av challenges

  String? challengeTitle;
  String? challengeDescription;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      await fetchUsername();
      await fetchUserTeam();
      await fetchMyTeamDonations();
      await fetchChallenge();
      await analyseChallenges();
      await fetchOtherTeamDonations();

      timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        fetchOtherTeamDonations();
      });
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> fetchUsername() async {
    username = SessionManager.instance.username;
  }

  // hämta användarens lag de är med i
  Future<void> fetchUserTeam() async {
    try {
      String? teamName = await ApiUtils.fetchTeamName(username);
      setState(() {
        userTeamName = teamName;
      });
    } catch (e) {
      print('Error fetching user team: $e');
    }
  }

  Future<void> fetchMyTeamDonations() async {
    try {
      double total = await ApiUtils.fetchDonations(username);
      setState(() {
        myTeamDonations = total;
      });
    } catch (e) {
      print("Error fetching donations: $e");
    }
  }

  Future<void> fetchOtherTeamDonations() async {
    try {
      double? donations =
          await ApiUtils.fetchOtherFundraiserBox(otherTeamName!);

      setState(() {
        otherTeamDonations = donations;
      });
    } catch (e) {
      print("Error fetching team donationamount: $e");
    }
  }

  // Metod för att hämta andra lagets donationer, tbi
  // fetchOtherTeamDonations();

  Future<void> fetchChallenge() async {
    fetchUserTeam();
    try {
      List<Challenge> fetchedChallenges =
          await ApiUtils.fetchActiveChallenge(username);

      setState(() {
        challenges = fetchedChallenges;
        analyseChallenges();
      });
    } catch (e) {
      // Handle any errors that occur during the fetch
      print('Error fetching teams: $e');
    }
  }

  Future<void> analyseChallenges() async {
    for (Challenge challenge in challenges) {
      challengeTitle = challenge.title;
      challengeDescription = challenge.description;

      if (challenge.challengerName != '$userTeamName') {
        otherTeamName = challenge.challengerName;
      }

      if (challenge.challengedName != '$userTeamName') {
        otherTeamName = challenge.challengedName;
      }

      print(challenges);
    }
  }

  void _editDescription() {
    TextEditingController _controller =
        TextEditingController(text: challengeDescription);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Description'),
          content: TextField(
            controller: _controller,
            onSubmitted: (value) {
              setState(() {
                challengeDescription = value;
              });
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  challengeDescription = _controller.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Lagkamp',
        useActionButton: false,
        showReturnArrow: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
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
                        Center(
                          child: Text(
                            // Titel för challengen
                            '$challengeTitle',
                            style: const TextStyle(
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
                                      '$myTeamDonations kr',
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
                                      '$otherTeamDonations kr',
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
                          constraints: const BoxConstraints(maxHeight: 150),
                          child: SingleChildScrollView(
                            child: Text(
                              '$challengeDescription',
                              style: const TextStyle(
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
                              onPressed: _editDescription,
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
                                launchUrl(Uri.parse(
                                    'https://midnattsloppet.com/resultat/'));
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
      ),
    );
  }
}
