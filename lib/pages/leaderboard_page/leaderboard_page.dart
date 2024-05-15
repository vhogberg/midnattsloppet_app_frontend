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
      body: Center(
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
