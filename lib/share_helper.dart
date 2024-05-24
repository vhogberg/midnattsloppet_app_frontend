import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareHelper {
  String teamName;

  ShareHelper(this.teamName);

  void shareToTwitter() {
    final url =
        'http://twitter.com/intent/tweet?text=Hjälp%20mitt%20lag%20att%20uppnå%20vårat%20donationsmål%20inför%20midnattsloppets%20race!%20Öppna%20länken%20här%20för%20att%20donera:%20group-15-7.pvt.dsv.su.se/app/donate/$teamName';
    launch(url);
  }

  void shareToFacebook() {
    final url =
        'https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fexample.com&quote=Hjälp%20mitt%20lag%20att%20uppnå%20vårat%20donationsmål%20inför%20midnattsloppets%20race!%20Öppna%20länken%20här%20för%20att%20group-15-7.pvt.dsv.su.se/app/donate/$teamName';
    launch(url);
  }

  void shareToLinkedIn() {
    final url =
        'https://www.linkedin.com/sharing/share-offsite/?url=http%3A%2F%2Fexample.com&summary=Hjälp%20mitt%20lag%20att%20uppnå%20vårat%20donationsmål%20inför%20midnattsloppets%20race!%20Öppna%20länken%20här%20för%20att%20donera:%20group-15-7.pvt.dsv.su.se/app/donate/$teamName';
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

  static void showShareDialog(BuildContext context, String teamName) {
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
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, // Dynamic width
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dela via:',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () =>
                              ShareHelper(teamName).shareToTwitter(),
                          icon: const FaIcon(FontAwesomeIcons.twitter),
                          iconSize: 50,
                        ),
                        IconButton(
                          onPressed: () =>
                              ShareHelper(teamName).shareToFacebook(),
                          icon: const FaIcon(FontAwesomeIcons.facebook),
                          iconSize: 50,
                        ),
                        IconButton(
                          onPressed: () =>
                              ShareHelper(teamName).shareToLinkedIn(),
                          icon: const FaIcon(FontAwesomeIcons.linkedin),
                          iconSize: 50,
                        ),
                        const IconButton(
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
          ),
        );
      },
    );
  }
}
