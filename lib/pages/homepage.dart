import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/custom_colors.dart';
import 'package:flutter_application/components/donation_progress_bar.dart';
import 'package:flutter_application/components/goal_box.dart';
import 'package:flutter_application/components/top_three_teams.dart';
import 'package:flutter_application/models/team.dart';
import 'package:flutter_application/pages/notification_page/notification_page.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:flutter_application/share_helper.dart';
import 'package:iconsax/iconsax.dart';

class HomePage extends StatefulWidget {
  final Function(int) navigateToPage;
  const HomePage({Key? key, required this.navigateToPage}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  String? charityName;
  String? teamName;
  String? companyName;
  int teamRank = -1;
  int totalTeams = 0;
  double donationGoal = 0;
  double totalDonations = 0;
  late Timer _timer;
  int daysLeft = 0;
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    fetchCompanyName();
    fetchGoal();
    fetchDonations();
    fetchCharityName();
    fetchTeamName();
    fetchLeaderboardData();
    calculateDaysLeft();

    //Periodically check the donation goal, donation amount and number of days remaining to race
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchGoal();
      fetchDonations();
      calculateDaysLeft();
    });

    updateGreeting();
    // Update the greeting every minute
    Timer.periodic(Duration(minutes: 1), (timer) {
      updateGreeting();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  Future<void> fetchDonations() async {
    try {
      double total = await ApiUtils.fetchDonations(username);
      setState(() {
        totalDonations = total;
      });
    } catch (e) {
      print("Error");
    }
  }

  Future<void> fetchGoal() async {
    try {
      double goal = await ApiUtils.fetchGoal(username);
      setState(() {
        donationGoal = goal;
      });
    } catch (e) {
      print("Error");
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

  //Calculates amount of days left until midnattsloppet
  void calculateDaysLeft() {
    DateTime targetDate = DateTime(2024, 8, 17);
    DateTime now = DateTime.now();
    setState(() {
      daysLeft = targetDate.difference(now).inDays;
    });
  }

  void updateGreeting() {
    final now = DateTime.now();
    setState(() {
      if (now.hour < 12) {
        _greeting = 'Godmorgon!';
      } else if (now.hour < 18 || (now.hour == 18 && now.minute < 30)) {
        _greeting = 'Goddag!';
      } else {
        _greeting = 'Godkväll!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                children: [
                  Row(
                    children: [
                      //Top left welcoming text
                       Text(
                        _greeting,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Sora',
                        ),
                      ),
                      const Spacer(),
                      //Top right notification bell button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationPage()),
                          );
                        },
                        child: const Stack(
                          children: [
                            Icon(
                              Iconsax.notification,
                              size: 35,
                              color: Color.fromARGB(255, 113, 113, 113),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      //Top right profile avatar button
                      GestureDetector(
                        onTap: () {
                          widget.navigateToPage(4);
                        },
                        child: companyName != null
                            ? Container(
                                padding: const EdgeInsets.all(2),
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
                                      companyName == "Null"
                                          ? 'images/company_logos/DefaultTeamPicture.png'
                                          : 'images/company_logos/$companyName.png',
                                    ),
                                  ),
                                ),
                              )
                            : const CircularProgressIndicator(), //Show a loading indicator
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      Stack(
                        children: [
                          //Upper blue/orange gradient box
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: MediaQuery.of(context).size.width,
                            height: 320,
                            decoration: BoxDecoration(
                              color: CustomColors.midnattsblue,
                              borderRadius: BorderRadius.circular(12.0),
                              gradient: RadialGradient(
                                radius: 0.8,
                                center: const Alignment(-0.5, 0.4),
                                colors: [
                                  //Darkened start color for improved visuals
                                  const Color.fromARGB(
                                      255, 140, 90, 100), //Start color
                                  CustomColors.midnattsblue, //End color
                                ],
                                stops: const [
                                  0.15,
                                  1.0,
                                ],
                              ),
                            ),
                            //Content of upper blue/orange gradient box placed in column
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Constrained box preventing longer team names from overlapping other content
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              155),
                                  //Scroll view allows longer team names to be scrolled
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      'Insamlingsbössa: $teamName',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                //Same logic as with team names
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              155),
                                  //Same logic as with team names
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    //Rich text allows donation amount to have a different font size
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            //toStringAsFixed removes decimal point in donation amount displayed
                                            text:
                                                '${totalDonations.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  40, //Larger font size for the donation amount
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: ' kr insamlat',
                                            style: TextStyle(
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
                                ),

                                //Same logic as with team names
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              85),
                                  //Same logic as with team names
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      'Stödjer: $charityName',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                //Donation progress bar
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 92,
                                  child: const Padding(
                                      padding:
                                          EdgeInsets.only(left: 30, right: 30),
                                      child: DonationProgressBar()),
                                ),
                                const SizedBox(height: 13),
                                //Goal box displaying donation goal
                                const Align(
                                    alignment: Alignment.topRight,
                                    child: GoalBox(height: 50, width: 85)),
                                const Spacer(),
                                //Semi-transparent white box
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      width: MediaQuery.of(context).size.width,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.white30,
                                        borderRadius:
                                            BorderRadius.circular(13.0),
                                        border: Border.all(
                                          color: Colors.white60, // Border color
                                          width: 1.0, // Border width
                                        ),
                                      ),
                                      //Row containing contents of white box
                                      child: Row(
                                        children: [
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxHeight: 50, maxWidth: 160),
                                            child: const AutoSizeText(
                                              'Dela bössan med vänner och familj!',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  fontFamily: 'Sora'),
                                              maxLines: 2,
                                            ),
                                          ),
                                          const Spacer(),
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
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Iconsax.export_1,
                                                    color: CustomColors
                                                        .midnattsblue,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    'Dela',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontFamily: 'Sora',
                                                      color: CustomColors
                                                          .midnattsblue,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          //Top right image
                          Positioned(
                            top: 20,
                            right: 20,
                            child: SizedBox(
                                width: 65,
                                height: 65,
                                child: Image.asset('images/Present.png')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          //Lower blue/orange gradient box
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 320,
                            decoration: BoxDecoration(
                              color: CustomColors.midnattsblue,
                              borderRadius: BorderRadius.circular(12.0),
                              gradient: RadialGradient(
                                radius: 0.8,
                                center: const Alignment(0.2, 0.6),
                                colors: [
                                  //Darkened start color for improved visuals
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
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              //Inner white box
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 10),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                decoration: BoxDecoration(
                                  color: Colors.white30,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Colors.white60, // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                //Transform moves the content of the white box up by 8 pixels
                                child: Column(
                                  children: [
                                    TopThreeTeams(
                                      smallCircleColor: Colors.white,
                                      smallCircleTextColor:
                                          CustomColors.midnattsblue,
                                      crownColor: const Color.fromARGB(
                                          255, 247, 214, 72),
                                      teamNameColor: Colors.white,
                                    ),
                                    const Spacer(),
                                    const Divider(
                                      height: 0,
                                      color: Colors.white,
                                      thickness: 2,
                                      indent: 0,
                                      endIndent: 0,
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                '$daysLeft Dagar till lopp',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14.0,
                                                    fontFamily: 'Sora'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            widget.navigateToPage(3);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                          ),
                                          child: Text(
                                            'Topplista',
                                            style: TextStyle(
                                                color:
                                                    CustomColors.midnattsblue,
                                                fontSize: 18.0,
                                                fontFamily: 'Sora'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
