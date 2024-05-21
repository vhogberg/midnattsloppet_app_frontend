import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/pages/challenge_page/challenge_wizard_dialog.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:iconsax/iconsax.dart';

class ChallengePage extends StatefulWidget {
  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  bool challengeSent = false;
  bool challengeReceived = true;
  String senderTeam = 'Nordea lag 3';

  TextEditingController searchController = TextEditingController();
  List<String> teams = [];
  List<String> filteredTeams = [];
  String? selectedTeam;
  String? username; // plockas från sessionmanager
  String? challengeFate; // 'ACCEPTED' el. 'DECLINED', används för

  @override
  void initState() {
    super.initState();
    filteredTeams.addAll(teams);
    fetchTeams();
    username = SessionManager.instance.username;
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
      // Lägg allt i en ScrollView så att sidan går att skrolla upp och ned, krav för responsive design.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
              20.0), // top-nivå padding, allting på sidan har 20px padding i alla riktningar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // centrera allt.
            children: [
              Image.asset(
                'images/CompetitionImage.png',
                fit: BoxFit.fitWidth, //  Anpassa bildens bredd horisontellt
              ),
              const SizedBox(height: 16), // lite vertikalt space under bilden
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0), // space nedåt
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
                      padding: EdgeInsets.only(bottom: 8.0), // space nedåt
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
                      padding: EdgeInsets.only(bottom: 6.0), // space nedåt
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
                            borderRadius:
                                BorderRadius.circular(4.0), // Avrunda hörnen
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
                padding: EdgeInsets.only(bottom: 2.0, top: 20.0), // space nedåt
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
                        children: [
                          Text(
                            '$senderTeam vill starta en lagkamp med er, acceptera?',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Sora',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                // Acceptera lagkamp logik här
                                onPressed: () async {
                                  challengeFate = 'ACCEPTED';
                                  final String url =
                                      'https://group-15-7.pvt.dsv.su.se/app/${username}/acceptchallenge/${challengeFate}';
                                  //anropa ApiUtils här, alla api anrop skall ske därifrån f r o m nu
                                  final response = await http.post(
                                    Uri.parse(url),
                                    // ytterligare data?
                                  );

                                  if (response.statusCode == 200) {
                                    // Challenge accepterad
                                    print('Challenge accepted successfully');
                                  } else {
                                    // Error hantering
                                    print(
                                        'Failed to accept challenge: ${response.body}');
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
                                  challengeFate = 'DECLINED';
                                  final String url =
                                      'https://group-15-7.pvt.dsv.su.se/app/${username}/acceptchallenge/${challengeFate}';
                                  //anropa ApiUtils här, alla api anrop skall ske därifrån f r o m nu
                                  final response = await http.post(
                                    Uri.parse(url),
                                    // ytterligare data?
                                  );

                                  if (response.statusCode == 200) {
                                    // Challenge avböjd lyckat
                                    print('Challenge declined successfully');
                                  } else {
                                    // Handle error response
                                    print(
                                        'Failed to accept challenge: ${response.body}');
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
                            'Inväntar svar från lag $senderTeam',
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

  // Sökresultat pop-up ruta när man klickar sökfältet.
  // challenge_page.dart (add this method inside _ChallengePageState)
  void _showSearchResultsPopup(BuildContext context,
      {Function(String)? onTeamSelected}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(20.0),
              child: WillPopScope(
                onWillPop: () async {
                  searchController.clear();
                  return true;
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8 + 45,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Ange lagnamn...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              filterSearchResults(value);
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredTeams.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                filteredTeams[index],
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedTeam = filteredTeams[index];
                                  if (onTeamSelected != null) {
                                    onTeamSelected!(selectedTeam!);
                                  }
                                });
                                Navigator.pop(context);
                              },
                              selected: selectedTeam == filteredTeams[index],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      searchController.clear();
    });
  }

// Metod för att filtrera sökresultat
  void filterSearchResults(String query) {
    List<String> searchResults = [];
    if (query.isNotEmpty) {
      for (String team in teams) {
        if (team.toLowerCase().contains(query.toLowerCase())) {
          searchResults.add(team);
        }
      }
    } else {
      searchResults.addAll(teams);
    }
    setState(() {
      filteredTeams = searchResults;
    });
  }

// Hämta lag från API
  Future<void> fetchTeams() async {
    try {
      final data = await ApiUtils.fetchTeamsFromAPI();
      setState(() {
        teams = data;
        filteredTeams.addAll(teams);
      });
    } catch (e) {
      print('Failed to fetch teams: $e');
    }
  }
}




/**
 * 
 * // Skicka iväg utmaningslogik nedan
                        onTap: () async {
                          final String url =
                              'https://group-15-7.pvt.dsv.su.se/app/${username}/createchallenge';
                          final Map<String, String> requestData = {
                            'name': 'Mitt challenge namn', // namn
                            'description':
                                'Min challenge beskrivning', // beskrivning
                            'challenger':
                                selectedTeam!, // Antar att man har ett selected team
                          };

                          final response = await http.post(
                            Uri.parse(url),
                            body: jsonEncode(requestData),
                            headers: {'Content-Type': 'application/json'},
                          );

                          // error hantering
                          if (response.statusCode == 200) {
                            // Challenge created successfully, handle response if needed
                            print('Challenge sent successfully');
                          } else {
                            // Handle error response
                            print('Failed to send challenge: ${response.body}');
                          }
                        },
 */