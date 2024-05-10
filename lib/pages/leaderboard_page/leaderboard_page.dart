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
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          Team team = teams[index];
          return ListTile(
            title: Text(team.name), // Access team name using team.name
            subtitle: Text('Fundraiser Box: ${team.fundraiserBox}'),
          );
        },
      ),
    );
  }

  Future<void> fetchTeamsFromAPI() async {
    final response = await http.get(Uri.parse('https://group-15-7.pvt.dsv.su.se/app/all/teamswithbox'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<Team> fetchedTeams = []; // Create a temporary list to hold Team objects
      for (var item in data) {
        fetchedTeams.add(Team(
          name: item['name'],
          fundraiserBox: item['fundraiserBox'],
        ));
      }
      fetchedTeams = sortTeams(fetchedTeams); // Sort the fetched teams
      setState(() {
        teams = fetchedTeams; // Update the state with the sorted teams
        debugPrint('teams: $teams');
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
