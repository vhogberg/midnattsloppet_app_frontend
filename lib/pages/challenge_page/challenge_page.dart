import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/models/challenge.dart';
import 'package:flutter_application/pages/challenge_page/active_challenge_page.dart';
import 'package:flutter_application/pages/challenge_page/challenge_wizard_dialog.dart';
import 'package:flutter_application/session_manager.dart';
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

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      setState(() {
        isLoading = true;
      });

      await fetchUsername();
      await fetchUserTeam();
      await fetchChallenges();
      await analyseChallenges();
    } catch (e) {
      print('Initialization error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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
        userTeam = teamName;
      });
    } catch (e) {
      print('Error fetching user team: $e');
    }
  }

  Future<void> fetchChallenges() async {
    fetchUserTeam();
    print('FETCH123');
    try {
      List<Challenge> fetchedChallenges =
          await ApiUtils.fetchChallengeActivity(username);
      print('LISTFETCH: $fetchedChallenges');

      setState(() {
        challenges = fetchedChallenges;
        isLoading = false;
        print('LISTFETCH2: $challenges');
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
    print(isLoading);

    // for each challenge in challenge, check:

    // Check if there is no activity whatsoever in the challenge page
    // Inbox then says "Inga aktiva inbjudningar eller förfrågningar"
    print(challenges);

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

    print('CHALLENGERECEIVEDBOOL: $challengeReceived');
    print('CHALLENGESENTBOOL: $challengeSent');
    print(challenges);

    // JAG SKICKAR EN UTMANING
    // challengerName == my team name, set challengeSent to true, set outgoingChallengeTeam to challengedName

    // JAG TAR EMOT EN UTMANING
    // challengerName != my team name, set incomingChallengeTeam to challengerName, set challengeReceived to true
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // egen custom appbar fr klassen "CustomAppBar"
      appBar: const CustomAppBar(
        key: null,
        title: 'Lagkamp',
        useActionButton: false,
      ),

      // Loading skärm pga mycket api calls
      body: isLoading
          ? Center(child: CircularProgressIndicator())

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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6), // lite vertikalt space
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WizardDialog();
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0XFF3C4785),
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
                              mainAxisSize: MainAxisSize.min, // används för att texten kan ha olik storlek
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
                                        try {
                                          final response =
                                              await ApiUtils.acceptChallenge(
                                                  username!,
                                                  incomingChallengeTeam);

                                          if (response.statusCode == 200) {
                                            // Challenge accepted
                                            print(
                                                'Challenge accepted successfully');

                                            // Logik för att switcha till active_challenge_page
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ActiveChallengePage()),
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
                                        try {
                                          final response =
                                              await ApiUtils.declineChallenge(
                                                  username!,
                                                  incomingChallengeTeam);

                                          if (response.statusCode == 200) {
                                            // Challenge declined successfully
                                            print(
                                                'Challenge declined successfully');

                                            // Run this method again to check if there are any more incoming challenge requests.
                                            analyseChallenges();
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
                              ? Text(
                                  'Inväntar svar från lag $outgoingChallengeTeam',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Sora',
                                  ),
                                  textAlign: TextAlign.center,
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
