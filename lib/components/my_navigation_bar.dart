import 'package:flutter/material.dart';
import 'package:flutter_application/pages/leaderboard_page/leaderboard_page.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_application/pages/challenge_page/challenge_page.dart';
import 'package:flutter_application/pages/homepage.dart';
import 'package:flutter_application/pages/myteampage.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({super.key});

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int selectedPage = 0;

  final _pageOptions = [
    const HomePage(),
    ChallengePage(),
    LeaderboardPage(),
    const MyTeamPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (index) {
            setState(() {
              selectedPage = index;
            });
          },
          selectedIndex: selectedPage,
          destinations: const [
            NavigationDestination(
              icon: Icon(
                Iconsax.home_2,
                size: 30,
                color: Color.fromARGB(255, 148, 148, 148),
              ),
              selectedIcon: Icon(
                Iconsax.home_25,
                size: 30,
                color: Color(0XFF3C4785),
              ),
              label: 'Hem',
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.medal_star,
                size: 30,
                color: Color.fromARGB(255, 148, 148, 148),
              ),
              selectedIcon: Icon(
                Iconsax.medal_star5,
                size: 30,
                color: Color(0XFF3C4785),
              ),
              label: 'Lagkamp',
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.receipt_item,
                size: 30,
                color: Color.fromARGB(255, 148, 148, 148),
              ),
              selectedIcon: Icon(
                Iconsax.receipt_item5,
                size: 30,
                color: Color(0XFF3C4785),
              ),
              label: 'Topplista',
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.smileys,
                size: 30,
                color: Color.fromARGB(255, 148, 148, 148),
              ),
              selectedIcon: Icon(
                Iconsax.smileys5,
                size: 30,
                color: Color(0XFF3C4785),
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
        body: _pageOptions[selectedPage]);
  }
}
