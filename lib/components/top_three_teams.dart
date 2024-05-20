import 'package:flutter/material.dart';
import 'package:flutter_application/models/team.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:iconsax/iconsax.dart';

class TopThreeTeams extends StatefulWidget {
  const TopThreeTeams({Key? key}) : super(key: key);

  @override
  _TopThreeTeamsState createState() => _TopThreeTeamsState();
}

class _TopThreeTeamsState extends State<TopThreeTeams> {
  List<Team> teams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                    height: 50), // Padding to offset the second place lower
                buildTeamCircle(topThreeTeams[1], Colors.grey),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                buildTeamCircle(topThreeTeams[0], Colors.yellow,
                    isFirstPlace: true),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                    height: 50), // Padding to offset the third place lower
                buildTeamCircle(topThreeTeams[2], Colors.brown),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTeamCircle(Team team, Color color, {bool isFirstPlace = false}) {
    double circleSize = isFirstPlace ? 80.0 : 60.0; 

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isFirstPlace)
          const Icon(
            Iconsax.crown,
            color: Color.fromRGBO(200, 200, 39, 1),
            size: 40.0,
          ),
        if (isFirstPlace)
          const SizedBox(height: 1.0), 
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.indigo,
              width: 3.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0), // Padding around the image
            child: Image(
              image: AssetImage('images/company_logos/${team.companyName}.png'),
              width: circleSize - 20,
              height: circleSize - 20,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Text(
          team.name,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.coin,
              color: Color.fromRGBO(200, 200, 39, 1),
              size: 12.0,
            ),
            const SizedBox(width: 4.0),
            Text(
              '${team.fundraiserBox}kr',
              style: const TextStyle(fontSize: 14.0),
            ),
          ],
        ),
      ],
    );
  }
}
