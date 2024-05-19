// leaderboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/top_three_teams.dart'; // Import the new component
import 'package:flutter_application/models/team.dart';
import 'package:flutter_application/pages/searchpage.dart';
import 'package:iconsax/iconsax.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Team> teams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeamsFromAPI();
  }

  Future<void> fetchTeamsFromAPI() async {
    try {
      List<Team> fetchedTeams =
          await ApiUtils.fetchTeamsWithBoxAndCompanyName();
      setState(() {
        teams = fetchedTeams;
        isLoading = false;
      });
    } catch (e) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoading = false;
      });
      print('Error fetching teams: $e');
    }
  }

  int getTeamRank(String teamName) {
    for (int i = 0; i < teams.length; i++) {
      if (teams[i].name == teamName) {
        return i + 1;
      }
    }
    return -1; // Return -1 if the team is not found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: null,
        title: 'Topplista',
        useActionButton: true,
        actionIcon: Iconsax.search_normal,
        onActionPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                children: [
                  const TopThreeTeams(), // Component!
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:
                            BorderRadius.circular(16.0), // Rounded corners
                      ),
                      child: ListView.builder(
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          return TeamListItem(
                            ranking: index + 1,
                            team: teams[index],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class TeamListItem extends StatelessWidget {
  final int ranking;
  final Team team;

  const TeamListItem({super.key, required this.ranking, required this.team});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(
            '$ranking. ', // Ranking position
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              team.name, // Team name
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${team.fundraiserBox}', // Fundraiser box number
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}
