import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/donation_progress_bar.dart';
import 'package:flutter_application/models/team.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/other_goal_box.dart';
import 'package:http/http.dart' as http;
import '../share_helper.dart';


class OtherTeamPage extends StatefulWidget {
  final Team team;

  const OtherTeamPage({Key? key, required this.team}) : super(key: key);

  @override
  _OtherTeamPageState createState() => _OtherTeamPageState();
}

class _OtherTeamPageState extends State<OtherTeamPage> {
  List<String> members = [];
  String? teamName;
  String? companyName;
  String? charityName;
  int donationGoal = 0;
  int totalDonations = 0;
  late Timer timer;
  int teamRank = -1;
  int totalTeams = 0;

  @override
  void initState() {
    super.initState();
    teamName = widget.team.name;
    companyName = widget.team.companyName;
    fetchTeamDetails();
    fetchLeaderboardData();
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDonationGoal();
      fetchDonatedAmount();
    });
  }

  Future<void> fetchTeamDetails() async {
    try {
      String? charity = await ApiUtils.fetchOtherCharityOrganization(teamName!);
      int? goal = await ApiUtils.fetchOtherDonationGoal(teamName!);
      int? donations = await ApiUtils.fetchOtherFundraiserBox(teamName!);
      List<dynamic>? teamMembers = await ApiUtils.fetchOtherMembers(teamName!);

      setState(() {
        charityName = charity;
        donationGoal = goal ?? 0;
        totalDonations = donations ?? 0;
        members = teamMembers?.map((member) => member['username'].toString()).toList() ?? [];
      });
    } catch (e) {
      print("Error fetching team details: $e");
    }
  }


  Future<void> fetchLeaderboardData() async {
  const String url = 'https://group-15-7.pvt.dsv.su.se/app/all/teamswithbox';

  try {
    final response = await ApiUtils.get(url);

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
        teamRank = fetchedTeams.indexWhere((team) => team.name == teamName) + 1;
      });
    } else {
      throw Exception('Failed to load teams from API, status code: ${response.statusCode}');
    }
  } catch (e) {
    print("Error fetching leaderboard data: $e");
  }
}


 Future<void> fetchDonationGoal() async {
    if (teamName != null) {
      try {
        int? goal = await ApiUtils.fetchOtherDonationGoal(teamName!);
        setState(() {
          donationGoal = goal ?? 0;
        });
      } catch (e) {
        print("Error fetching donation goal: $e");
      }
    }
  }

  Future<void> fetchDonatedAmount() async {
    if (teamName != null) {
      try {
        int? donations = await ApiUtils.fetchOtherFundraiserBox(teamName!);
        setState(() {
          totalDonations = donations ?? 0;
        });
      } catch (e) {
        print("Error fetching donations: $e");
      }
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
        title: 'Mitt lag',
        useActionButton: true,
        actionIcon: Iconsax.logout_1,
        onActionPressed: () {
          SessionManager.instance.signUserOut(context);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  '$teamName',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sora',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0XFF3C4785),
                ),
                child: Center(
                  child: companyName != null
                      ? CircleAvatar(
                          radius: 74,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(
                              'images/company_logos/$companyName.png'),
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Företag: $companyName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sora',
                      ),
                    ),
                    Text(
                      'Stödjer: $charityName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                height: 500,
                decoration: BoxDecoration(
                  color: const Color(0XFF3C4785),
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: const RadialGradient(
                    radius: 0.8,
                    center: Alignment(-0.5, 0.4),
                    colors: [
                      Color.fromARGB(255, 140, 90, 100),
                      Color(0xFF3C4785),
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
                    const Text(
                      'Lagmedlemmar',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          fontFamily: 'Sora'),
                    ),
                    const SizedBox(height: 10),
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
                            children: [
                              ...generateTeamList(),
                            ],
                          ),
                    const SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(13.0),
                        border: Border.all(
                          color: Colors.white60,
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${totalDonations.toStringAsFixed(0)} kr insamlat',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 80,
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 35, right: 35),
                                  child: DonationProgressBar(),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 60,
                            right: 1,
                            child: OtherGoalBox(
                              height: 50,
                              width: 90,
                              teamName: teamName!, // Pass team name here
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(13.0),
                        border: Border.all(
                          color: Colors.white60,
                          width: 1.0,
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
                              ShareHelper.showShareDialog(context, teamName!);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              width: 100,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13.0),
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
                    const SizedBox(height: 10),
                    Text(
                      teamRank != -1
                          ? 'Plats: #$teamRank av $totalTeams'
                          : 'Rankning saknas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}