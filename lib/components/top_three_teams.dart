import 'package:flutter/material.dart';
import 'package:flutter_application/models/team.dart';
import 'package:iconsax/iconsax.dart';

class TopThreeTeams extends StatelessWidget {
  final List<Team> teams;

  const TopThreeTeams({super.key, required this.teams});

  @override
  Widget build(BuildContext context) {
    if (teams.length < 3) {
      return const SizedBox.shrink(); // Return an empty widget if there are less than 3 teams
    }

    List<Team> topThreeTeams = teams.take(3).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                Container(height: 40), // Padding to offset the second place lower
                buildTeamCircle(topThreeTeams[1], Colors.grey, '2'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                buildTeamCircle(topThreeTeams[0], Colors.yellow, '1', isFirstPlace: true),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(height: 40), // Padding to offset the third place lower
                buildTeamCircle(topThreeTeams[2], Colors.brown, '3'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTeamCircle(Team team, Color color, String rank, {bool isFirstPlace = false}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            if (isFirstPlace)
              const Icon(
                Iconsax.crown2,
                color: Colors.deepPurple,
                size: 40.0,
              ),
            Container(
              width: isFirstPlace ? 60.0 : 50.0,
              height: isFirstPlace ? 60.0 : 50.0,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.deepPurple,
                  width: 3.0,
                ),
              ),
              child: Center(
                child: Text(
                  rank,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Text(
              team.name,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '${team.fundraiserBox} kr', // Ska ha en myntikon
              style: const TextStyle(fontSize: 14.0),
            ),
          ],
        ),
        Positioned(
          bottom: 30.0,
          child: Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.deepPurple,
                width: 2.0,
              ),
            ),
            child: Center(
              child: Text(
                rank,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
