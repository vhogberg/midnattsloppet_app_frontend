import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/top_three_teams.dart'; // Import the new component
import 'package:flutter_application/models/team.dart';
import 'package:flutter_application/pages/searchpage.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Team> teams = [];

  int getTeamRank(String teamName) {
    for (int i = 0; i < teams.length; i++) {
      if (teams[i].name == teamName) {
        return i + 1;
      }
    }
    return -1; // Return -1 if the team is not found
  }

  @override
  void initState() {
    super.initState();
    fetchTeamsFromAPI();
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
      body: Center(
        child: Column(
          children: [
            TopThreeTeams(teams: teams), // Component!
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
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

  Future<void> fetchTeamsFromAPI() async {
    final response = await http.get(
        Uri.parse('https://group-15-7.pvt.dsv.su.se/app/all/teamswithbox'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print(data); // Add this line to print the JSON response

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

      fetchedTeams = sortTeams(fetchedTeams); // Sort the fetched teams
      setState(() {
        teams = fetchedTeams; // Update the state with the sorted teams
      });
    } else {
      throw Exception('Failed to load teams from API');
    }
  }

  List<Team> sortTeams(List<Team> teams) {
    teams.sort((a, b) => b.fundraiserBox.compareTo(a.fundraiserBox));
    return teams;
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
