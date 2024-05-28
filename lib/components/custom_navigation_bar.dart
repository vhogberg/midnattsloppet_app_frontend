// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/pages/challenge_pages/active_challenge_page.dart';
import 'package:flutter_application/pages/challenge_pages/challenge_page.dart';
import 'package:flutter_application/pages/homepage.dart';
import 'package:flutter_application/pages/leaderboard_page.dart';
import 'package:flutter_application/pages/team_pages/myteampage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomNavigationBar extends StatefulWidget {
  final int selectedPage;

  const CustomNavigationBar({super.key, required this.selectedPage});

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  String? username;
  String? teamName;
  Color iconColor = const Color.fromARGB(255, 148, 148, 148);
  Color selectedIconColor = const Color(0XFF3C4785);
  bool isChallengeAccepted = false;
  int _selectedPage = 0; // Add state variable for selected page

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      await fetchUsername();
      await fetchTeamName();
      await fetchChallengeStatus(username);
      _selectedPage =
          widget.selectedPage; // Initialize with widget's selectedPage
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  //navigateToPage allows the navigation index to be passed to the pages themselves
  void navigateToPage(int index) {
    setState(() {
      _selectedPage = index; // Use state variable
    });
  }

  Future<void> fetchUsername() async {
    username = SessionManager.instance.username;
  }

  Future<void> fetchTeamName() async {
    try {
      String? fetchedTeamName = await ApiUtils.fetchTeamName(username);
      setState(() {
        teamName = fetchedTeamName;
      });
    } catch (e) {
      print("Error fetching teamname: $e");
    }
  }

  Future<void> fetchChallengeStatus(String? username) async {
    try {
      List<String>? statuses = await ApiUtils.fetchChallengeStatus(username);

      String? challengeStatus;
      for (String status in statuses) {
        if (status == 'ACCEPTED') {
          challengeStatus = status;
          break; // Avbryt loopen när vi hittar ACCEPTED
        }
      }

      setState(() {
        isChallengeAccepted = (challengeStatus == 'ACCEPTED');
      });
    } catch (e) {
      print("Error fetching challenge status: $e");
      setState(() {
        isChallengeAccepted = false; // Standardvärde vid fel
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageOptions = [
      HomePage(navigateToPage: navigateToPage),
      isChallengeAccepted ? const ActiveChallengePage() : ChallengePage(),
      const SizedBox(), //Placeholder to allow index of selection to match with navigation bar destination page
      LeaderboardPage(navigateToPage: navigateToPage),
      MyTeamPage(navigateToPage: navigateToPage),
    ];

    return Scaffold(
        resizeToAvoidBottomInset: false,
        //Swish button in center of navigation bar
        floatingActionButton: FloatingActionButton.large(
          shape: const CircleBorder(),
          backgroundColor: selectedIconColor,
          onPressed: () async {
            try {
              if (teamName == null || teamName!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Team name is not provided'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              // Encode the teamName to make it URL safe
              final encodedTeamName = Uri.encodeComponent(teamName!);
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
          child: const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('images/swishlogo2.png'),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (index) {
            setState(() {
              _selectedPage = index; // Use state variable
            });
          },
          selectedIndex: _selectedPage, // Use state variable
          destinations: [
            NavigationDestination(
              icon: Icon(
                Iconsax.home_2,
                size: 30,
                color: iconColor,
              ),
              selectedIcon: Icon(
                Iconsax.home_25,
                size: 30,
                color: selectedIconColor,
              ),
              label: 'Hem',
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.medal_star,
                size: 30,
                color: iconColor,
              ),
              selectedIcon: Icon(
                Iconsax.medal_star5,
                size: 30,
                color: selectedIconColor,
              ),
              label: 'Lagkamp',
            ),
            const SizedBox(
                width:
                    20), //UI placeholder to create space for center navigation bar Swish button
            NavigationDestination(
              icon: Icon(
                Iconsax.receipt_item,
                size: 30,
                color: iconColor,
              ),
              selectedIcon: Icon(
                Iconsax.receipt_item5,
                size: 30,
                color: selectedIconColor,
              ),
              label: 'Topplista',
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.profile_2user,
                size: 30,
                color: iconColor,
              ),
              selectedIcon: Icon(
                Iconsax.profile_2user5,
                size: 30,
                color: selectedIconColor,
              ),
              label: 'Mitt lag',
            ),
          ],
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          height: 70,
          indicatorColor: Colors.transparent,
          indicatorShape: const CircleBorder(),
        ),
        body: pageOptions[
            _selectedPage]); //Change the body of the app so it displays the desired page
  }
}
