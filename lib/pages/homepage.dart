import 'package:flutter/material.dart';
import 'package:flutter_application/pages/login_page/login_widget.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application/pages/navigation_bar/navigation_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;

  @override
  void initState() {
    super.initState();
    getUsernameFromSession();
  }

  Future<void> getUsernameFromSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');
    if (sessionToken != null) {
      // Extract username from session token
      final List<String> parts = sessionToken.split(':');
      if (parts.length == 2) {
        setState(() {
          username = parts[0];
        });
      }
    }
  }

  // method to sign the user out TODO: move to session manager(?)
  void signUserOut(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? sessionToken = prefs.getString('session_token');
      if (sessionToken != null) {
        // Call logout endpoint on the backend
        final url = Uri.parse('https://group-15-7.pvt.dsv.su.se/app/logout');
        final response = await http.post(
          url,
          headers: <String, String>{
            'Authorization':
                'Bearer $sessionToken', // Include session token in the request header
          },
        );
        if (response.statusCode == 200) {
          // Clear session token from local storage
          prefs.remove('session_token');
          // Navigate back to the login screen
          Navigator.popUntil(context, ModalRoute.withName('/'));
        } else {
          throw Exception('Failed to logout: ${response.statusCode}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () =>
                signUserOut(context), // Call signUserOut method on press
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Good morning $username!",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    Iconsax.notification,
                    size: 35,
                    color: Color.fromARGB(255, 113, 113, 113),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        AssetImage('images/stockholm-university.png'),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 400,
                            height: 230,
                            decoration: BoxDecoration(
                              color: const Color(0XFF3C4785),
                              borderRadius: BorderRadius.circular(20.0),
                              gradient: const RadialGradient(
                                radius: 0.8,
                                center: Alignment(-0.5, 0.4),
                                colors: [
                                  Color.fromARGB(
                                      255, 140, 90, 100), // Start color
                                  Color(0xFF3C4785), // End color
                                ],
                                stops: [
                                  0.15,
                                  1.0,
                                ],
                              ),
                            ),
                          ),
                          const Positioned(
                            top: 10,
                            left: 10,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lag 1',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '675 kr',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Donate to support Barncancerfonden.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              width: 65,
                              height: 65,
                              child: Image.asset(
                                  'images/chrome_DmBUq4pVqL-removebg-preview.png'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          Container(
                            width: 400,
                            height: 230,
                            decoration: BoxDecoration(
                              color: const Color(0XFF3C4785),
                              borderRadius: BorderRadius.circular(20.0),
                              gradient: const RadialGradient(
                                radius: 0.8,
                                center: Alignment(0.7, -0.3),
                                colors: [
                                  Color.fromARGB(
                                      255, 140, 90, 100), // Start color
                                  Color(0xFF3C4785), // End color
                                ],
                                stops: [
                                  0.15,
                                  1.0,
                                ],
                              ),
                            ),
                          ),
                          const Positioned(
                            top: 10,
                            left: 10,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lag 1',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '45:59',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Midnattsloppet race distance 10 km',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              width: 65,
                              height: 65,
                              child: Image.asset('images/Gold-Trophy-PNG.png'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 400,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0XFF3C4785),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'images/fire.png',
                                      width: 50,
                                      height: 50,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Start a challenge',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Image.asset(
                                      'images/fire.png',
                                      width: 50,
                                      height: 50,
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
          ],
      ),
      bottomNavigationBar: const MyNavigationBar(),
    );
  }
}

// klass för delning via sociala medier
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

  // ruta som dyker upp
  // Kalla på den via "onPressed: () => ShareHelper.showShareDialog(context)""
  static void showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: ShareHelper.shareToTwitter,
                      icon: FaIcon(FontAwesomeIcons.twitter),
                      iconSize: 50,
                    ),
                    IconButton(
                      onPressed: ShareHelper.shareToFacebook,
                      icon: FaIcon(FontAwesomeIcons.facebook),
                      iconSize: 50,
                    ),
                    IconButton(
                      onPressed: ShareHelper.shareToLinkedIn,
                      icon: FaIcon(FontAwesomeIcons.linkedin),
                      iconSize: 50,
                    ),
                    IconButton(
                      onPressed: ShareHelper.openMail,
                      icon: FaIcon(FontAwesomeIcons.envelope),
                      iconSize: 50,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}