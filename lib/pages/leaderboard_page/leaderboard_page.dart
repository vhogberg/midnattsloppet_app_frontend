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

  String getFormattedRanking(int ranking) {
    return ranking.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0), // Rounded corners
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Row(
          children: [
            Text(
              getFormattedRanking(ranking),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8), // Spacing between the avatar and text
            if (team.companyName != null)
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage:
                    AssetImage('images/company_logos/${team.companyName}.png'),
              ),
            const SizedBox(width: 8), // Spacing between the avatar and text
            Expanded(
              child: Text(
                team.name, // Team name
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${team.fundraiserBox}kr',
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
