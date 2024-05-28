// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/custom_colors.dart';
import 'package:flutter_application/components/donation_progress_bar.dart';
import 'package:flutter_application/components/other_team_goal_box.dart';
import 'package:flutter_application/components/return_arrow_argument.dart';
import 'package:flutter_application/models/team.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
  double donationGoal = 0;
  double totalDonations = 0;
  late Timer timer;
  int teamRank = -1;
  int totalTeams = 0;

  @override
  void initState() {
    super.initState();
    teamName = widget.team.name;
    companyName = widget.team.companyName;
    _initializePage();
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchTeamDetails();
      fetchLeaderboardData();
    });
  }

  Future<void> _initializePage() async {
    try {
      await fetchTeamDetails();
      await fetchLeaderboardData();
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> fetchTeamDetails() async {
    try {
      String? charity = await ApiUtils.fetchOtherCharityOrganization(teamName!);
      double? goal = await ApiUtils.fetchOtherDonationGoal(teamName!);
      double? donations = await ApiUtils.fetchOtherFundraiserBox(teamName!);
      List<dynamic>? teamMembers = await ApiUtils.fetchOtherMembers(teamName!);

      setState(() {
        charityName = charity;
        donationGoal = goal ?? 0;
        totalDonations = donations ?? 0;
        members =
            teamMembers?.map((member) => member['name'].toString()).toList() ??
                [];
      });
    } catch (e) {
      print("Error fetching team details: $e");
    }
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

  // Används ej??
  Future<void> fetchDonationGoal() async {
    if (teamName != null) {
      try {
        double? goal = await ApiUtils.fetchOtherDonationGoal(teamName!);
        setState(() {
          donationGoal = goal ?? 0;
        });
      } catch (e) {
        print("Error fetching donation goal: $e");
      }
    }
  }

  // Används ej??
  Future<void> fetchDonatedAmount() async {
    if (teamName != null) {
      try {
        double? donations = await ApiUtils.fetchOtherFundraiserBox(teamName!);
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
    //Extract argument and set boolean based on where user navigated from
    final ReturnArrowArgument args =
        ModalRoute.of(context)!.settings.arguments as ReturnArrowArgument;

    return Scaffold(
      appBar: CustomAppBar(
        key: null,
        title: 'Lagöversikt',
        showReturnArrow: args.showReturnArrow,
        useActionButton: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 150,
                  width: 150,
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
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(
                        companyName == "null"
                            ? 'images/company_logos/DefaultTeamPicture.png'
                            : 'images/company_logos/$companyName.png',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  Text(
                    '$teamName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sora',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Stödjer: $charityName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Sora',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 15, bottom: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: CustomColors.midnattsblue,
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: RadialGradient(
                    radius: 0.8,
                    center: const Alignment(0.5, -0.4),
                    colors: [
                      const Color.fromARGB(255, 140, 90, 100),
                      CustomColors.midnattsblue,
                    ],
                    stops: const [
                      0.15,
                      1.0,
                    ],
                  ),
                ),
                child: Column(
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
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(13.0),
                        border: Border.all(
                          color: Colors.white60,
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.only(
                          top: 10, left: 15, right: 15, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  //toStringAsFixed removes decimal point in donation amount displayed
                                  // ignore: unnecessary_string_interpolations
                                  text: '${totalDonations.toStringAsFixed(0)}',
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
                          const SizedBox(height: 15),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 155,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 33),
                              child: DonationProgressBar(teamName: teamName),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.topRight,
                            child: OtherGoalBox(
                              height: 50,
                              width: 85,
                              teamName: teamName!, // Pass team name here
                            ),
                          ),
                          const Spacer(),
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
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                if (teamName == null || teamName!.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Team name is not provided'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                // Encode the teamName to make it URL safe
                                final encodedTeamName =
                                    Uri.encodeComponent(teamName!);
                                final url =
                                    'https://group-15-7.pvt.dsv.su.se/app/donate/$encodedTeamName';
                                if (!await launchUrlString(url)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Could not launch URL'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('An error occurred: $e'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              fixedSize: const Size.fromHeight(50),
                              shadowColor: Colors.transparent,
                              backgroundColor:
                                  const Color.fromARGB(255, 241, 156, 125),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: IntrinsicWidth(
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Image.asset('images/swishlogo.png'),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Stöd insamlingen',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Sora'),
                                  ),
                                ],
                              ),
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
