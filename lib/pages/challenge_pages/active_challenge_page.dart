// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/custom_colors.dart';
import 'package:flutter_application/models/challenge.dart';
import 'package:iconsax/iconsax.dart';
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

  Future<void> editChallengeDescription(String newDescription) async {
    try {
      await ApiUtils.editChallengeDescription(username!, newDescription);

      setState(() {
        challengeDescription = newDescription;
      });
    } catch (e) {
      print("Error editing challenge description: $e");
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
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _editDescription() {
    TextEditingController controller =
        TextEditingController(text: challengeDescription);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8 + 60,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Text(
                            'Redigera utmaning',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Sora',
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.12,
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: 'Ange dina egna utmaningar här...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines:
                                  null, // Gör att textfield kan växa i storlek
                              expands:
                                  true, // Expanderar textfield till så stort som går
                              keyboardType: TextInputType.multiline,
                              textAlignVertical: TextAlignVertical.top,
                              onSubmitted: (value) async {
                                await editChallengeDescription(value);
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: const Text(
                              'Exempel på utmaningar:'
                              '\n* Pulsutmaning: Lagen bär pulsmätare under loppet, och laget med den lägsta medelpulsen vid mållinjen vinner.'
                              '\n'
                              '\n* Hoppa på ett ben: Under olika sektioner av loppet måste man hoppa på ett ben'
                              '\n'
                              '\n* Förutsäga resultat: Lag måste förutsäga sin sluttid före loppet. Det lag vars faktiska sluttid är närmast sin beräknade tid vinner'
                              '\n'
                              '\n* Maskerad: Lagen måste springa i maskeradkostymer under loppet'
                              '\n'
                              '\n* Bära ägg: Lagen bär med sig ett ägg under loppet, de som har flest hela ägg i slutet vinner',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, // textfärg
                          backgroundColor: Colors.grey, // knappfärg
                        ),
                        child: const Text('Avbryt'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await editChallengeDescription(controller.text);
                            setState(() {
                              challengeDescription = controller.text;
                            });
                            Navigator.of(context).pop();
                          } catch (e) {
                            // Show an error message if needed
                            print('Failed to update challenge description: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, // textfärg
                          backgroundColor:
                              CustomColors.midnattsblue, // knappfärg
                        ),
                        child: const Text('Spara'),
                      ),
                    ],
                  ),
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
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Lagkamp',
        useActionButton: false,
        showReturnArrow: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 50),
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
                    padding: const EdgeInsets.only(
                        top: 15, left: 20, right: 20, bottom: 20),
                    width: MediaQuery.of(context).size.width,
                    height: 470,
                    decoration: BoxDecoration(
                      color: CustomColors.midnattsblue,
                      borderRadius: BorderRadius.circular(12.0),
                      gradient: RadialGradient(
                        radius: 0.8,
                        center: const Alignment(-0.5, 0.4),
                        colors: [
                          const Color.fromARGB(
                              255, 140, 90, 100), // Start color
                          CustomColors.midnattsblue, // End color
                        ],
                        stops: const [
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        '$userTeamName',
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${myTeamDonations?.toStringAsFixed(0)} kr',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                              const VerticalDivider(
                                width: 10,
                                thickness: 2,
                                indent: 0,
                                endIndent: 0,
                                color: Colors.white,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        '$otherTeamName',
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${otherTeamDonations?.toStringAsFixed(0)} kr',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 0,
                          color: Colors.white,
                          thickness: 2,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
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
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: GestureDetector(
                              onTap: () {
                                _editDescription();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Iconsax.edit,
                                      color: CustomColors.midnattsblue,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Redigera utmaning',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Sora',
                                        color: CustomColors.midnattsblue,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7.0),
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
                                          5.0), // För att skapa lite avstånd mellan texterna
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
                                    10.0), // För att skapa lite avstånd mellan kolumnen och knappen
                            GestureDetector(
                              onTap: () {
                                // Knappens funktionalitet ska in här
                                launchUrl(Uri.parse(
                                    'https://midnattsloppet.com/resultat/'));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Hemsida',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Sora',
                                        color: CustomColors.midnattsblue,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Iconsax.export_3,
                                      color: CustomColors.midnattsblue,
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}
