import 'package:flutter/material.dart';
import 'package:flutter_application/models/team.dart';

class LeaderboardPage extends StatefulWidget {  
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();

}

class _LeaderboardPageState extends State<LeaderboardPage> {

  @override
  Widget build(BuildContext context) {
    //List<Team> sortedTeams = sortTeams();

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      /*body: ListView.builder(
        itemCount: sortedTeams.length,
        itemBuilder: (context, index) {
          Team team = sortedTeams[index];
          return ListTile(
            title: Text(Team.name),
            subtitle: Text('Score: ${player.score}'),
          );
        },
      ),*/
    );
  }

  List<Team> sortTeams(List<Team> teams) {
    teams.sort((a, b) => b.fundraiserBox.compareTo(a.fundraiserBox));
    return teams;
  }
}
