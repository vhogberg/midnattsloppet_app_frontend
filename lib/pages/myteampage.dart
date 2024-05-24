import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/donation_progress_bar.dart';
import 'package:flutter_application/components/logout_dialog.dart';
import 'package:flutter_application/models/team.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/goal_box.dart';
import '../share_helper.dart';
import 'package:flutter_application/components/custom_colors.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({Key? key}) : super(key: key);

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
    username = SessionManager.instance.username;
    fetchDonationGoal();
    fetchDonatedAmount();
    fetchCharityName();
    fetchTeamName();
    fetchCompanyName();
    fetchMembers();
    fetchLeaderboardData();
    calculateDaysLeft();
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDonationGoal();
      fetchDonatedAmount();
      calculateDaysLeft();
    });
  }

  void calculateDaysLeft() {
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
        final List<dynamic> data = jsonDecode(response.body);

        List<Team> fetchedTeams = [];

        for (var item in data) {
          String name = item['name'];
          int fundraiserBox = item['fundraiserBox'];
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

  // Method to generate ListTiles dynamically based on team members list
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
                    fontSize: 16, // smaller font size
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sora',
                  ),
                  overflow: TextOverflow.ellipsis, // prevents wrapping
                  maxLines: 1, // ensures single line text
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  members[i + 1],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16, // smaller font size
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sora',
                  ),
                  overflow: TextOverflow.ellipsis, // prevents wrapping
                  maxLines: 1, // ensures single line text
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
              fontSize: 16, // smaller font size
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
            overflow: TextOverflow.ellipsis, // prevents wrapping
            maxLines: 1, // ensures single line text
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
          SignOutDialog.show(context); // Call the sign-out dialog
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
                      ),
                      Text(
                        'Stödjer: $charityName', // Display the charity name
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Container with team members name
              Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                height: 520,
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
                              ...generateTeamList(),
                            ],
                          ),
                    const SizedBox(height: 10),
                    // Combined container
                    Container(
                      padding: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      height: 320,
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
                                  Transform.translate(
                                    offset: const Offset(0, -10),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            //toStringAsFixed removes decimal point in donation amount displayed
                                            text:
                                                '${totalDonations.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontFamily: 'Sora',
                                              color: Colors.white,
                                              fontSize:
                                                  40, //Larger font size for the donation amount
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: ' kr insamlat',
                                            style: TextStyle(
                                              fontFamily: 'Sora',
                                              color: Colors.white,
                                              fontSize:
                                                  28, //Default font size for the rest of the text
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Stödjer: $charityName',
                                    maxLines: 1, // ensures single line text
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 80,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 43, right: 43),
                                      child: DonationProgressBar(
                                          username: username),
                                    ),
                                  ),
                                ],
                              ),
                              const Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: 1,
                                      top: 98), // Adjust padding as needed
                                  child: GoalBox(height: 50, width: 90),
                                ),
                              ),
                            ],
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
                          // Sharing button
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Dela bössan med\nvänner och familj!',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
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
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Iconsax.export_1,
                                        color: CustomColors.midnattsblue,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Dela',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Sora',
                                          color: CustomColors.midnattsblue,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Add the leaderboard rank display
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teamRank != -1
                                      ? 'Plats: #$teamRank av $totalTeams'
                                      : 'Rankning saknas',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Sora',
                                  ),
                                ),
                                Text(
                                  '$daysLeft dagar kvar till Midnattsloppet!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontFamily: 'Sora',
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
