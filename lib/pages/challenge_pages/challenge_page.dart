// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/custom_colors.dart';
import 'package:flutter_application/components/custom_navigation_bar.dart';
import 'package:flutter_application/components/dialog_utils.dart';
import 'package:flutter_application/models/challenge.dart';
import 'package:flutter_application/pages/challenge_pages/challenge_wizard_dialog.dart';
import 'package:iconsax/iconsax.dart';

class ChallengePage extends StatefulWidget {
  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  List<Challenge> challenges = [];

  bool challengeSent = false;
  bool challengeReceived = false;
  String incomingChallengeTeam =
      ''; // någon har skickat en utmaning till MIG, incomingChallengeTeam är namnet på det laget
  String outgoingChallengeTeam =
      ''; // JAG har skickat en utmaning till ANNAT LAG, outgoingChallengeTeam är namnet på det laget
  String incomingChallengeTitle = '';
  String incomingChallengeDescription = '';

  String? username; // plockas från sessionmanager
  String? userTeam;

  bool isLoading =
      true; // använder isLoading för en loadingcirkel på utmaningssidan pga många API-calls

  late Timer statustimer;
  @override
  void initState() {
    super.initState();
    _initializePage();

    statustimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // Situation när det andra laget har accepterat utmaningen
      //Att lagra statusen i en variabel och sen använda den fungerar
      //men leder till att dialogen poppar up var 3e sekund
      //även på active challenge page
      String status = await getChallengeStatus(username);
      if (status == 'ACCEPTED') {
        statustimer.cancel();
        if (outgoingChallengeTeam != '') {
          String? result = await DialogUtils.showInformationDialog(
              context: context,
              title: '$outgoingChallengeTeam har accepterat er inbjudan',
              description: 'En aktiv lagkamp startar. Lycka till!');

          if (result == 'yes') {
            dispose(); //Fungerar halvt för att stoppa pop-ups?? Orsakar även memoryleak
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomNavigationBar(
                  selectedPage: 1,
                ),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _initializePage() async {
    try {
      await fetchUsername();
      await fetchUserTeam();
      await fetchChallenges();
      await analyseChallenges();
      await getChallengeStatus(username);
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  @override
  void dispose() {
    statustimer.cancel();
    super.dispose();
  }

  Future<void> fetchUsername() async {
    username = SessionManager.instance.username;
  }

  // hämta användarens lag de är med i
  Future<void> fetchUserTeam() async {
    try {
      String? teamName = await ApiUtils.fetchTeamName(username);
      setState(() {
        userTeam = teamName;
      });
    } catch (e) {
      print('Error fetching user team: $e');
    }
  }

  Future<void> fetchChallenges() async {
    fetchUserTeam();
    try {
      List<Challenge> fetchedChallenges =
          await ApiUtils.fetchChallengeActivity(username);

      setState(() {
        challenges = fetchedChallenges;
        isLoading = false;
        analyseChallenges();
      });
    } catch (e) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoading = false;
      });
      print('Error fetching teams: $e');
    }
  }

  Future<void> analyseChallenges() async {
    // for each challenge in challenge, check:

    // Check if there is no activity whatsoever in the challenge page
    // Inbox then says "Inga aktiva inbjudningar eller förfrågningar"

    if (challenges.isEmpty) {
      challengeSent = false;
      challengeReceived = false;
    } else {
      // the list is not empty...

      for (Challenge challenge in challenges) {
        // OM JAG HAR SKICKAT CHALLENGEN
        if (challenge.challengerName == '$userTeam') {
          challengeSent = true;
          outgoingChallengeTeam = challenge.challengedName;
        }

        // OM JAG HAR TAGIT EMOT EN CHALLENGE, I.E JAG HAR INTE SKICKAT DEN.
        if (challenge.challengerName != '$userTeam') {
          challengeReceived = true;
          incomingChallengeTeam = challenge.challengerName;
          incomingChallengeTitle = challenge.title;
          incomingChallengeDescription = challenge.description;
        }
      }
    }

    // JAG SKICKAR EN UTMANING
    // challengerName == my team name, set challengeSent to true, set outgoingChallengeTeam to challengedName

    // JAG TAR EMOT EN UTMANING
    // challengerName != my team name, set incomingChallengeTeam to challengerName, set challengeReceived to true
  }

  Future<String> getChallengeStatus(String? username) async {
    try {
      var statuses = await ApiUtils.fetchChallengeStatus(username);
      for (String status in statuses) {
        if (status == 'ACCEPTED') {
          return 'ACCEPTED';
        } else {
          return '';
        }
      }
      return '';
    } catch (e) {
      // Hantera eventuella fel vid hämtning av statusen
      print('Error: $e');
      return ''; // Default till 'PENDING' om ett fel uppstår
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // egen custom appbar fr klassen "CustomAppBar"
      appBar: const CustomAppBar(
        title: 'Lagkamp',
        useActionButton: false,
        showReturnArrow: false,
      ),

      // Loading skärm pga mycket api calls
      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          // Lägg allt i en ScrollView så att sidan går att skrolla upp och ned, krav för responsive design.
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 20,
                    right: 20,
                    bottom:
                        50), // top-nivå padding, allting på sidan har 20px padding i alla riktningar
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // centrera allt.
                  children: [
                    Image.asset(
                      'images/CompetitionImage.png',
                      fit: BoxFit
                          .fitWidth, //  Anpassa bildens bredd horisontellt
                    ),
                    const SizedBox(
                        height: 16), // lite vertikalt space under bilden
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(bottom: 8.0), // space nedåt
                            child: Text(
                              '1. Sök upp ett lag som ni vill starta lagkamp emot',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(bottom: 8.0), // space nedåt
                            child: Text(
                              '2. Skicka iväg utmaningen och invänta svar från det andra laget',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(bottom: 6.0), // space nedåt
                            child: Text(
                              '3. En aktiv lagkamp startas där ni kan tävla i donationer och skapa egna mini-tävlingar!',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Visa ej "Starta lagkamp"-knapp om användaren redan har skickat en lagkamp.
                    if (!challengeSent)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6), // lite vertikalt space
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final result = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return WizardDialog();
                                    },
                                  );

                                  // Check if the dialog returned a success result and reload the page
                                  if (result == 'success') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CustomNavigationBar(
                                                selectedPage: 1,
                                              )),
                                    );
                                  }
                                },
                                /* onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WizardDialog(
                                        onDialogClose: () {
                                          // Replace the current page with a new instance to reload it
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChallengePage()),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }, */
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CustomColors.midnattsblue,
                                    borderRadius: BorderRadius.circular(
                                        4.0), // Avrunda hörnen
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical:
                                          15), // höjd på skicka-iväg utmaning knapp.
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // centrera allt, viktigt för padding i kanter
                                    children: [
                                      Image.asset(
                                        'images/fire.png',
                                        width: 35,
                                        height: 35,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Starta en lagkamp',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Image.asset(
                                        'images/fire.png',
                                        width: 35,
                                        height: 35,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Padding(
                      padding: EdgeInsets.only(
                          bottom: 2.0, top: 20.0), // space nedåt
                      child: Text(
                        'Inbox',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical:
                              3.0), // maringal vertikalt mellan skicka-iväg knapp och inbox-låda
                      padding: const EdgeInsets.all(
                          20.0), // space-hantering inuti inbox-låda
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.0), // hörn-radie
                      ),

                      // När en lagkampsinbjudan har ankommit till MITT lag från ett ANNAT lag
                      child: challengeReceived
                          ? Column(
                              mainAxisSize: MainAxisSize
                                  .min, // används för att texten kan ha olik storlek
                              children: [
                                Text(
                                  '$incomingChallengeTeam vill starta en lagkamp med er, acceptera?',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Sora',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Titel: $incomingChallengeTitle',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Sora',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Beräkna höjd baserat på textlängd
                                    return ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: constraints.maxHeight *
                                            0.5, // kan behöva justeras
                                      ),
                                      child: SingleChildScrollView(
                                        child: Text(
                                          'Beskrivning: $incomingChallengeDescription',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'Sora',
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      // Acceptera lagkamp logik här
                                      onPressed: () async {
                                        String? result = await DialogUtils
                                            .showConfirmationDialog(
                                          context: context,
                                          title:
                                              'Är du säker på att du vill acceptera?',
                                          description: 'Du kan ej ångra detta',
                                        );
                                        if (result == 'yes') {
                                          try {
                                            final response =
                                                await ApiUtils.acceptChallenge(
                                                    username!,
                                                    incomingChallengeTeam);
                                            if (response.statusCode == 200) {
                                              statustimer.cancel();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const CustomNavigationBar(
                                                            selectedPage: 1)),
                                              );
                                              // Challenge accepted
                                              // Logik för att switcha till active_challenge_page
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const CustomNavigationBar(
                                                          selectedPage: 1,
                                                        )),
                                              );
                                            } else {
                                              // Error hantering
                                              print(
                                                  'Failed to accept challenge: ${response.body}');
                                            }
                                          } catch (e) {
                                            // Exception handling
                                            print(
                                                'Error accepting challenge: $e');
                                          }
                                        }
                                        // If the user presses "No", simply return without doing anything
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Acceptera',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Iconsax.like_1,
                                            size: 24,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    ElevatedButton(
                                      // Avböj lagkamp logik här
                                      onPressed: () async {
                                        String? result = await DialogUtils
                                            .showConfirmationDialog(
                                          context: context,
                                          title:
                                              'Är du säker på att du vill avböja?',
                                          description: 'Du kan ej ångra detta',
                                        );

                                        if (result == 'yes') {
                                          try {
                                            final response =
                                                await ApiUtils.declineChallenge(
                                                    username!,
                                                    incomingChallengeTeam);

                                            if (response.statusCode == 200) {
                                              // Challenge declined successfully
                                              // Run this  again to check if there are any more incoming challenge requests.
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const CustomNavigationBar(
                                                          selectedPage: 1,
                                                        )),
                                              );
                                            } else {
                                              // Handle error response
                                              print(
                                                  'Failed to decline challenge: ${response.body}');
                                            }
                                          } catch (e) {
                                            // Exception handling
                                            print(
                                                'Error declining challenge: $e');
                                          }
                                        }
                                      },

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Avböj',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Iconsax.dislike,
                                            size: 24,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )

                          // När MITT lag har skickat en lagkamp till ett annat lag, inväntar svar
                          : (challengeSent
                              ? Column(
                                  children: [
                                    Text(
                                      'Inväntar svar från lag $outgoingChallengeTeam',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Sora',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                        height:
                                            16), // spacing mellan text och knapp
                                    ElevatedButton(
                                      onPressed: () async {
                                        String? result = await DialogUtils
                                            .showConfirmationDialog(
                                          context: context,
                                          title:
                                              'Är du säker på att du vill avbryta inbjudan?',
                                          description: 'Du kan ej ångra detta',
                                        );

                                        if (result == 'yes') {
                                          try {
                                            final response = await ApiUtils
                                                .takeBackChallenge(
                                              username!,
                                            );
                                            if (response.statusCode == 200) {
                                              // Challenge cancelled successfully
                                              // Run this again to update page
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CustomNavigationBar(
                                                    selectedPage: 1,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // Handle error response
                                              print(
                                                  'Failed to cancel pending challenge: ${response.body}');
                                            }
                                          } catch (e) {
                                            // Exception handling
                                            print(
                                                'Error cancelling pending challenge: $e');
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Avbryt inbjudan',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Iconsax.dislike,
                                            size: 24,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              // När ingen aktivitet har skett på lagkampssidan
                              // både challengeSent och challengeReceived är falskt
                              : const Text(
                                  'Inga aktiva inbjudningar eller förfrågningar',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Sora',
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
