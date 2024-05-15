import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/api_utils/notification_api.dart';
import 'package:flutter_application/components/donation_progress_bar.dart';
import 'package:flutter_application/components/goal_box.dart';
import 'package:flutter_application/components/gradient_container.dart';
import 'package:flutter_application/pages/notification_page/notification_manager.dart';
import 'package:flutter_application/pages/notification_page/notification_page.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  String? charityName;
  String? teamName;
  double donationGoal = 0;
  double totalDonations = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    NotificationApi.init();
    listenNotifications();
    fetchGoal();
    fetchDonations();
    fetchCharityName();
    fetchTeamName();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchGoal();
      fetchDonations();
      print(NotificationManager.instance.hasUnreadNotifications);
    });
  }

  void listenNotifications() => NotificationApi.onClickNotification.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationPage())); // om payload ska följa med NotificationPage(payload: payload)

  void triggerNotification() {
    bool hasUnread = NotificationManager.instance.hasUnreadNotifications;

    if (hasUnread) {
      NotificationApi.showSimpleNotification(
        title: 'Du har olästa notiser!',
        body: 'Gå in i notis-fliken och upptäck dina nya notiser!',
        payload: 'test',
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
              child: Row(
                children: [
                  const Text(
                    "Godmorgon!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Sora',
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page here
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationPage()),
                      );
                    },
                    child: Stack(
                      children: [
                        const Icon(
                          Iconsax.notification,
                          size: 35,
                          color: Color.fromARGB(255, 113, 113, 113),
                        ),
                        if (1 == 0 /** Denna if-satsen finns om vi hittar något sätt att kontrollera om det finns olästa notifikationer, just nu tar detta för mkt tid*/)
                          Positioned(
                            // position på cirkeln
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1), // Storlek på cirkeln
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 241, 75, 75),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.notification_12,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      SessionManager.instance.signUserOut(context);
                    },
                    child: const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('images/stockholm-university.png'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        height: 320,
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
                              'Insamlingsbössa: $teamName',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '${totalDonations.toStringAsFixed(0)} kr insamlat',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Stödjer: $charityName',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 80,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 30, right: 30),
                                child: DonationProgressBar(),
                              ),
                            ),
                            const SizedBox(
                              height: 80,
                            ),
                            Stack(
                              children: [
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
                                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Sora'),
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
                          ],
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: SizedBox(
                          width: 65,
                          height: 65,
                          child: Image.asset('images/chrome_DmBUq4pVqL-removebg-preview.png'),
                        ),
                      ),
                      const Positioned(
                        top: 140,
                        right: 20,
                        child: GoalBox(height: 50, width: 90),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Container(
                        width: 400,
                        height: 320,
                        decoration: BoxDecoration(
                          color: const Color(0XFF3C4785),
                          borderRadius: BorderRadius.circular(20.0),
                          gradient: const RadialGradient(
                            radius: 0.8,
                            center: Alignment(0.7, -0.3),
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
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(50),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(13.0),
                              border: Border.all(
                                color: Colors.white60, // Border color
                                width: 1.0, // Border width
                              ),
                            ),
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
    );
  }
}

// klass för delning via sociala medier
class ShareHelper {
  static void shareToTwitter() {
    // url är en string, lägg till variabel för lagets personliga teamlänk i slutet.
    const url = 'http://twitter.com/intent/tweet?text=Hjälp%20mitt%20lag%20att%20uppnå%20vårat%20donationsmål%20inför%20midnattsloppets%20race!%20Öppna%20länken%20här%20för%20att%20donera:%20example.com';
    launch(url);
  }

  static void shareToFacebook() {
    // url är en string, lägg till variabel för lagets personliga teamlänk i slutet.
    const url = 'https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fexample.com&quote=Hjälp%20mitt%20lag%20att%20uppnå%20vårat%20donationsmål%20inför%20midnattsloppets%20race!%20Öppna%20länken%20här%20för%20att%20donera:%20example.com';
    launch(url);
  }

  static void shareToLinkedIn() {
    // url är en string, lägg till variabel för lagets personliga teamlänk i slutet.
    const url = 'https://www.linkedin.com/sharing/share-offsite/?url=http%3A%2F%2Fexample.com&summary=Hjälp%20mitt%20lag%20att%20uppnå%20vårat%20donationsmål%20inför%20midnattsloppets%20race!%20Öppna%20länken%20här%20för%20att%20donera:%20example.com';
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

  // ruta som dyker upp
  // Kalla på den via "onPressed: () => ShareHelper.showShareDialog(context)""
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
