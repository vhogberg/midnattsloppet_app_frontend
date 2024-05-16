import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/team.dart';
import 'package:http/http.dart' as http;

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Team> teams = []; // Define a list to hold Team objects

  @override
  void initState() {
    super.initState();
    fetchTeamsFromAPI(); // Call the method to fetch teams from API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      //  title: Text('Leaderboard'),
      //),
      body: Center(
        child: Column(
          children: [
            buildTopThreeTeams(),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background color
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                ),
                child: ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    Team team = teams[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // White background for each item
                        borderRadius: BorderRadius.circular(12.0), // Smooth edges
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(team.name), // Access team name using team.name
                        subtitle: Text('Fundraiser Box: ${team.fundraiserBox}'),
                      ),
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

  Widget buildTopThreeTeams() {
    if (teams.length < 3) {
      return SizedBox.shrink(); // Return an empty widget if there are less than 3 teams
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
                Icons.chair,
                color: Colors.amber,
                size: 30.0,
              ),
            Container(
              width: isFirstPlace ? 60.0 : 50.0,
              height: isFirstPlace ? 60.0 : 50.0,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue,
                  width: 3.0,
                ),
              ),
              child: Center(
                child: Text(
                  rank,
                  style: TextStyle(
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
              'Score: ${team.fundraiserBox}',
              style: const TextStyle(fontSize: 14.0),
            ),
          ],
        ),
        Positioned(
          bottom: -10.0,
          child: Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
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

  Future<void> fetchTeamsFromAPI() async {
    final response = await http.get(Uri.parse('https://group-15-7.pvt.dsv.su.se/app/all/teamswithbox'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<Team> fetchedTeams = []; // Create a temporary list to hold Team objects
      data.forEach((key, value) {
        fetchedTeams.add(Team(
          name: key,
          fundraiserBox: value,
        ));
      });
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
