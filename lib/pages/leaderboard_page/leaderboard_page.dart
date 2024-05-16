import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/models/team.dart';
import 'package:flutter_application/pages/searchpage.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';

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
            buildTopThreeTeams(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background color
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                ),
                child: ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    Team team = teams[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // White background for each item
                        borderRadius:
                            BorderRadius.circular(12.0), // Smooth edges
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ListTile(
                        title:
                            Text(team.name), // Access team name using team.name
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
      return const SizedBox
          .shrink(); // Return an empty widget if there are less than 3 teams
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
                Container(
                    height: 40), // Padding to offset the second place lower
                buildTeamCircle(topThreeTeams[1], Colors.grey, '2'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                buildTeamCircle(topThreeTeams[0], Colors.yellow, '1',
                    isFirstPlace: true),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                    height: 40), // Padding to offset the third place lower
                buildTeamCircle(topThreeTeams[2], Colors.brown, '3'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTeamCircle(Team team, Color color, String rank,
      {bool isFirstPlace = false}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            if (isFirstPlace)
              const Icon(
                Icons.icecream, // Use crown icon to indicate first place
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
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
