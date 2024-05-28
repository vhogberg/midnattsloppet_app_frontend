// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/components/custom_colors.dart';
import 'package:flutter_application/components/dialog_utils.dart';
import 'package:http/http.dart' as http;

class WizardDialog extends StatefulWidget {
  @override
  _WizardDialogState createState() => _WizardDialogState();
}

class _WizardDialogState extends State<WizardDialog> {
  int _currentPage = 0;
  String? selectedTeam;
  String? userTeam;
  String? username; // plockas från sessionmanager

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<String> teams = [];
  List<String> filteredTeams = [];

  static const String _apiKeyHeader = 'X-API-KEY';
  static const String _apiKey =
      '8292EB40F91DCF46950913B1ECC1AB22ED3F7C7491186059D7FAF71D161D791F';

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    fetchTeams();
    fetchUserTeam(); // används för titel på lagkamp, t.ex "mitt lag vs nordea lag 7", mitt lag ersätts med användarens lag.
  }

  // hämta användarens lag de är med i
  Future<void> fetchUserTeam() async {
    try {
      String? teamName = await ApiUtils.fetchTeamName(username);
      setState(() {
        userTeam = teamName;
      });
    } catch (e) {
      print('Error fetching user team: $e');
    }
  }

  // hantera wizard steg
  void _nextPage() {
    setState(() {
      if (_currentPage == 0 && selectedTeam == null) {
        DialogUtils.showGenericErrorMessage(
            context, 'Fel', 'Du måste välja ett lag!');
        return;
      }
      if (_currentPage == 1 && titleController.text.isEmpty) {
        DialogUtils.showGenericErrorMessage(
            context, 'Fel', 'Du måste ange en titel.');
        return;
      }
      if (_currentPage == 2 && descriptionController.text.isEmpty) {
        DialogUtils.showGenericErrorMessage(
            context, 'Fel', 'Du måste ange egna utmaningar.');
        return;
      }
      if (_currentPage < 3) {
        _currentPage++;
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
  }

  void _previousPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
    });
  }

  void _onSend() async {
    final String url =
        'https://group-15-7.pvt.dsv.su.se/app/$username/createchallenge';

    // hämta data från de tre olika stegen i wizard
    final Map<String, String> requestData = {
      'name': titleController.text,
      'description': descriptionController.text,
      'teamtochallenge': selectedTeam!,
    };
    try {
      // Skicka POST request (try)
      final response = await http.post(
        Uri.parse(url),
        headers: {
          _apiKeyHeader: _apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: utf8.encode(jsonEncode(requestData)),
      );

      // Hantera respons, printar i konsol atm
      if (response.statusCode == 200) {
        // Om lyckat: stäng wizard, kanske ha ett steg 5 som säger lyckat?
        Navigator.pop(context, 'success'); // Return success result
      } else {
        // Hantera error
        print('Failed to send challenge: ${response.body}');
        // Visa error till användare.
        DialogUtils.showGenericErrorMessage(context, 'Fel',
            'Lyckades inte att skicka! Vänligen försök igen senare.');
      }
    } catch (e) {
      print('Error sending challenge: $e');
      // (catch) för felhantering
      DialogUtils.showGenericErrorMessage(context, 'Fel',
          'Lyckades inte att skicka! Vänligen försök igen senare.');
    }
  }

  void _handleGoBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8 + 60, // bredd på wizard
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentPage,
                children: [
                  _buildSearchPage(),
                  _buildTitlePage(),
                  _buildDescriptionPage(context),
                  _buildOverviewPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage == 0)
                    ElevatedButton(
                      onPressed: _handleGoBack,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: Colors.grey, // knappfärg
                      ),
                      child: const Text('Tillbaka'),
                    ),
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: _previousPage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: Colors.grey, // knappfärg
                      ),
                      child: const Text('Tillbaka'),
                    ),
                  if (_currentPage < 3)
                    const Spacer(), // Spacer så att "nästa"-knappen alltid är på höger sida.
                  if (_currentPage < 3)
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: CustomColors.midnattsblue, // knappfärg
                      ),
                      child: const Text('Nästa'),
                    ),
                  if (_currentPage == 3)
                    ElevatedButton(
                      onPressed: _onSend,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: Colors.green, // knappfärg
                      ),
                      child: const Text('Skicka'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wizard steg 1, sök efter ett lag.
  Widget _buildSearchPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            '1. Välj lag:',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Ange lagnamn...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              filterSearchResults(value);
            },
          ),
        ),
        Expanded(
          child: filteredTeams
                  .isEmpty // om det inte finns några lag i challengeable teams API endpoint
              ? const Center(child: Text('Inga lag finns att utmana!'))
              : ListView.builder(
                  itemCount: filteredTeams.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        filteredTeams[index],
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedTeam = filteredTeams[index];
                        });
                      },
                      selected: selectedTeam == filteredTeams[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Hämta team för sökfunktionen för API
  Future<void> fetchTeams() async {
    try {
      final data = await ApiUtils.fetchChallengeableTeams(username!);
      // final data = await ApiUtils.fetchTeamsFromAPI();

      setState(() {
        teams = data;
        filteredTeams.addAll(teams);
      });
    } catch (e) {
      print('Failed to fetch teams: $e');
    }
  }

  // Metod för att filtrera sökresultat
  void filterSearchResults(String query) {
    setState(() {
      filteredTeams = teams
          .where((team) => team.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Wizard steg 2, titel på lagkamp
  Widget _buildTitlePage() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              '2. Ange titel:',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Sora',
              ),
            ),
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: userTeam != null
                  ? '${userTeam!} vs ${selectedTeam ?? ''}' // lokala användarens lag vs valt lag i listan
                  : 'Mitt lag vs ${selectedTeam ?? ''}', // tror inte detta behövs, men används för fall då användare inte är med i ett lag
              border: const OutlineInputBorder(),
            ),
          )
        ],
      ),
    );
  }

Widget _buildDescriptionPage(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            '3. Ange utmaningar',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Ange dina egna utmaningar här...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null, // Gör att textfield kan växa i storlek
                    expands: true, // Expanderar textfield till så stort som går
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top, // text ska starta i topp, per default börjar den i mitten..
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Text(
                    'Exempel på utmaningar:'
                        '\n* Pulsutmaning: Lagen bär pulsmätare under loppet, och laget med den lägsta medelpulsen vid mållinjen vinner.'
                        '\n'
                        '\n* Hoppa på ett ben: Under olika sektioner av loppet måste man hoppa på ett ben'
                        '\n'
                        '\n* Förutsäga resultat: Lag måste förutsäga sin sluttid före loppet. Det lag vars faktiska sluttid är närmast sin beräknade tid vinner'
                        '\n'
                        '\n* Maskerad: Lagen måste springa i maskeradkostymer under loppet'
                        '\n'
                        '\n* Bära ägg: Lagen bär med sig ett ägg under loppet, de som har flest hela ägg i slutet vinner',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Wizard steg 4, översikt och skicka iväg utmaning
  Widget _buildOverviewPage() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Översikt',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildOverviewItem('Valt lag:', selectedTeam ?? 'Inget lag valt'),
          const SizedBox(height: 10),
          _buildOverviewItem('Titel:', titleController.text),
          const SizedBox(height: 10),
          const Text(
            'Egna tävlingar:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Text(
                  descriptionController.text,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
