// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/custom_colors.dart';
import 'package:flutter_application/components/dialog_utils.dart';
import 'package:flutter_application/components/donation_progress_bar.dart';
import 'package:flutter_application/components/team_goal_box.dart';
import 'package:flutter_application/models/team.dart';
import 'package:iconsax/iconsax.dart';

class MyTeamPage extends StatefulWidget {
  final Function(int) navigateToPage;
  const MyTeamPage({Key? key, required this.navigateToPage}) : super(key: key);

  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  static List<String> members = [];
  String? username;
  String? teamName;
  String? companyName;
  String? charityName;
  double donationGoal = 0;
  double totalDonations = 0;
  late Timer timer;
  int teamRank = -1;
  int totalTeams = 0;
  int daysLeft = 0;

  @override
  void initState() {
    super.initState();
    _initializePage();

    calculateDaysLeft();
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDonationGoal();
      fetchDonatedAmount();
    });
  }

  Future<void> _initializePage() async {
    try {
      await fetchUsername();
      await fetchTeamName();
      await fetchDonationGoal();
      await fetchMembers();
      await fetchDonatedAmount();
      await fetchCompanyName();
      await fetchCharityName();
      await fetchLeaderboardData();
      await calculateDaysLeft();
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> fetchUsername() async {
    username = SessionManager.instance.username;
  }

  Future<void> calculateDaysLeft() async {
    DateTime targetDate = DateTime(2024, 8, 17);
    DateTime now = DateTime.now();
    setState(() {
      daysLeft = targetDate.difference(now).inDays;
    });
  }

  Future<void> fetchLeaderboardData() async {
    try {
      final response = await ApiUtils.get(
          ('https://group-15-7.pvt.dsv.su.se/app/all/teamswithbox'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        List<Team> fetchedTeams = [];

        for (var item in data) {
          String name = item['name'];
          double fundraiserBox = item['fundraiserBox'];
          String? companyName;

          if (item['company'] != null) {
            companyName = item['company']['name'];
          }

          fetchedTeams.add(Team(
            name: name,
            fundraiserBox: fundraiserBox,
            companyName: companyName,
          ));
        }

        fetchedTeams.sort((a, b) => b.fundraiserBox.compareTo(a.fundraiserBox));
        setState(() {
          totalTeams = fetchedTeams.length;
          teamRank =
              fetchedTeams.indexWhere((team) => team.name == teamName) + 1;
        });
      } else {
        throw Exception('Failed to load teams from API');
      }
    } catch (e) {
      print("Error fetching leaderboard data: $e");
    }
  }

  Future<void> fetchDonatedAmount() async {
    try {
      double total = await ApiUtils.fetchDonations(username);
      setState(() {
        totalDonations = total;
      });
    } catch (e) {
      print("Error fetching donations: $e");
    }
  }

  Future<void> fetchDonationGoal() async {
    try {
      double goal = await ApiUtils.fetchGoal(username);
      setState(() {
        donationGoal = goal;
      });
    } catch (e) {
      print("Error fetching goal: $e");
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

  Future<void> fetchCompanyName() async {
    try {
      String? coName = await ApiUtils.fetchCompanyName(username);
      setState(() {
        companyName = coName;
      });
    } catch (e) {
      print("Error fetching company name: $e");
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

  Future<void> fetchMembers() async {
    try {
      List<String>? teamMembers = await ApiUtils.fetchMembers(username);
      setState(() {
        members = teamMembers ?? []; // handle null case
      });
    } catch (e) {
      print("Error fetching charity name: $e");
    }
  }

  List<Widget> generateTeamList() {
    List<Widget> listTiles = [];
    for (int i = 0; i < members.length; i += 2) {
      if (i + 1 < members.length) {
        listTiles.add(Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text(
                  members[i],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sora',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  members[i + 1],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sora',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ));
      } else {
        listTiles.add(ListTile(
          title: Text(
            members[i],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
            textAlign: TextAlign.center,
          ),
        ));
      }
    }
    return listTiles;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: null,
        title: '$teamName',
        // teampage ska ha en logout-knapp till höger, så detta nedan sätts "true"
        useActionButton: true,
        // logout knapp från Iconsax bilbiotek
        actionIcon: Iconsax.logout_1,
        // kalla på onActionPressed metoden också, använd sessionmanager för att logga ut
        onActionPressed: () {
          DialogUtils.showSignOutDialog(context);
        },
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                  height:
                      10), // Add some spacing between teamName and the picture
              // Circular team picture at the middle top
              Center(
                child: Container(
                    width: 150,
                    height: 150,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          colors: [
                            CustomColors.midnattsblue,
                            CustomColors.midnattsorange
                          ],
                        ),
                        shape: BoxShape.circle),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: companyName != null
                          ? CircleAvatar(
                              radius: 74,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(
                                  'images/company_logos/$companyName.png'),
                            )
                          : const CircularProgressIndicator(), // Show a loading indicator
                    )),
              ),
              const SizedBox(height: 10),
              // Textbox with the donation pledge name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Företag: $companyName', // Display the company name
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Sora',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Stödjer: $charityName', // Display the charity name
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Sora',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Container with team members name
              Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 15, bottom: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: CustomColors.midnattsblue,
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: RadialGradient(
                    radius: 0.8,
                    center: const Alignment(-0.5, 0.4),
                    colors: [
                      const Color.fromARGB(255, 140, 90, 100), // Start color
                      CustomColors.midnattsblue, // End color
                    ],
                    stops: const [
                      0.15,
                      1.0,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    members.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Inga lagmedlemmar än!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontFamily: 'Sora'),
                            ),
                          )
                        : Column(
                            // Generate ListTiles dynamically
                            children: [
                              const Text(
                                'Lagmedlemmar',
                                style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 22,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              ...generateTeamList(),
                            ],
                          ),
                    const SizedBox(height: 10),
                    // Combined container
                    Container(
                      padding: const EdgeInsets.only(
                          top: 10, left: 15, right: 15, bottom: 20),
                      width: MediaQuery.of(context).size.width,
                      height: 310,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(13.0),
                        border: Border.all(
                          color: Colors.white60, // Border color
                          width: 1.0, // Border width
                        ),
                      ),
                      child: Column(
                        children: [
                          // Donation information
                          Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          //toStringAsFixed removes decimal point in donation amount displayed
                                          text:
                                              // ignore: unnecessary_string_interpolations
                                              '${totalDonations.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontFamily: 'Sora',
                                            color: Colors.white,
                                            fontSize:
                                                30, //Larger font size for the donation amount
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: ' kr insamlat',
                                          style: TextStyle(
                                            fontFamily: 'Sora',
                                            color: Colors.white,
                                            fontSize:
                                                24, //Default font size for the rest of the text
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Stödjer: $charityName',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 155,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 33),
                                      child: DonationProgressBar(
                                          username: username),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.topRight,
                            child: GoalBox(
                              height: 50,
                              width: 85,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Divider(
                            height: 0,
                            color: Colors.white,
                            thickness: 2,
                            indent: 0,
                            endIndent: 0,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      teamRank != -1
                                          ? 'Plats: #$teamRank av $totalTeams'
                                          : 'Rankning saknas',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Sora'),
                                    ),
                                    Text(
                                      '$daysLeft dagar kvar till Midnattsloppet!',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          fontFamily: 'Sora'),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Knappens funktionalitet ska in här
                                  widget.navigateToPage(3);
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
                                        'Topplista',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Sora',
                                          color: CustomColors.midnattsblue,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Icon(
                                        Iconsax.receipt_item,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
