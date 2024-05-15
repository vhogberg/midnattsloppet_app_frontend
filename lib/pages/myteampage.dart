import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/donation_progress_bar.dart';
import 'package:flutter_application/pages/navigation_bar/navigation_bar.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/goal_box.dart';
import 'package:url_launcher/url_launcher.dart';

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
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDonationGoal();
      fetchDonatedAmount();
    });
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sora', // smaller font size
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  members[i + 1],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sora', // smaller font size
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora', // smaller font size
            ),
          ),
        ));
      }
    }
    return listTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: null,
        title: 'Mitt lag',
        // teampage ska ha en logout-knapp till höger, så detta nedan sätts "true"
        useActionButton: true,
        // logout knapp från Iconsax bilbiotek
        actionIcon: Iconsax.logout_1,
        // kalla på onActionPressed metoden också, använd sessionmanager för att logga ut
        onActionPressed: () {
          SessionManager.instance.signUserOut(context);
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display team name above the circular team picture
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                '$teamName',
                style: TextStyle(
                  fontSize: 20, // Adjust font size
                  color: Colors.black, // Set color to black
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Sora',
                ),
              ),
            ),
          ),
          SizedBox(
              height: 10), // Add some spacing between teamName and the picture
          // Circular team picture at the middle top
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0XFF3C4785), // Use the blue color provided
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 74,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      AssetImage('images/stockholm-university.png'),
                ),
              ),
            ),
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
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sora',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Container with team members name
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
                  Text(
                    'Lagmedlemmar',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        fontFamily: 'Sora'),
                  ),
                  SizedBox(height: 10),
                  // Check if members list is empty
                  members.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(10),
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
                  SizedBox(height: 10),
                  // Display fetched data
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(13.0),
                      border: Border.all(
                        color: Colors.white60, // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${totalDonations.toStringAsFixed(0)} kr insamlat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
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
                          child: GoalBox(height: 50, width: 90),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Sharing button
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(13.0),
                      border: Border.all(
                        color: Colors.white60, // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Dela bössan med vänner och familj!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Sora'),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ShareHelper.showShareDialog(context);
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShareHelper {
  static void shareToTwitter() {
    // url är en string, lägg till variabel för lagets personliga teamlänk i slutet.
    const url =
        'http://twitter.com/intent/tweet?text=Hjälp%20mitt%20lag%20att%20uppnå%20vårat%20donationsmål%20inför%20midnattsloppets%20race!%20Öppna%20länken%20här%20för%20att%20donera:%20example.com';
    launch(url);
  }

  static void shareToFacebook() {
    // url är en string, lägg till variabel för lagets personliga teamlänk i slutet.
    const url =
        'https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fexample.com&quote=Hjälp%20mitt%20lag%20att%20uppnå%20vårat%20donationsmål%20inför%20midnattsloppets%20race!%20Öppna%20länken%20här%20för%20att%20donera:%20example.com';
    launch(url);
  }

  static void shareToLinkedIn() {
    // url är en string, lägg till variabel för lagets personliga teamlänk i slutet.
    const url =
        'https://www.linkedin.com/sharing/share-offsite/?url=http%3A%2F%2Fexample.com&summary=Hjälp%20mitt%20lag%20att%20uppnå%20vårat%20donationsmål%20inför%20midnattsloppets%20race!%20Öppna%20länken%20här%20för%20att%20donera:%20example.com';
    launch(url);
  }

  static void openMail() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'recipient@example.com',
      query: 'subject=Your%20Subject&body=Your%20Body',
    );
    String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static void showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.easeInOut,
            ),
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dela via:',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: shareToTwitter,
                        icon: FaIcon(FontAwesomeIcons.twitter),
                        iconSize: 50,
                      ),
                      IconButton(
                        onPressed: shareToFacebook,
                        icon: FaIcon(FontAwesomeIcons.facebook),
                        iconSize: 50,
                      ),
                      IconButton(
                        onPressed: shareToLinkedIn,
                        icon: FaIcon(FontAwesomeIcons.linkedin),
                        iconSize: 50,
                      ),
                      IconButton(
                        onPressed: openMail,
                        icon: Icon(Icons.email),
                        iconSize: 50,
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
}
