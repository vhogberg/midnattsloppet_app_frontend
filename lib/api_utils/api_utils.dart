import 'dart:async';
import 'dart:convert';

import 'package:flutter_application/models/team.dart';
import 'package:http/http.dart' as http;

class ApiUtils {
  static const String _apiKeyHeader = 'X-API-KEY';
  static const String _apiKey =
      '8292EB40F91DCF46950913B1ECC1AB22ED3F7C7491186059D7FAF71D161D791F';
  static const String baseURL = 'https://group-15-7.pvt.dsv.su.se/app';

 static Future<http.Response> get(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {_apiKeyHeader: _apiKey},
      );
      return response;
    } catch (e) {
      print("Error making GET request to $url: $e");
      rethrow;
    }
  }

  static Future<http.Response> post(String url, dynamic body) async {
    return await http.post(
      Uri.parse(url),
      headers: {
        _apiKeyHeader: _apiKey,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: utf8.encode(jsonEncode(body)),
    );
  }

  static Future<http.Response> logout(String url,
      {Map<String, String>? headers, dynamic body}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to send request: $e');
    }
  }

  static Map<String, String> _buildHeaders(
      Map<String, String>? additionalHeaders) {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      _apiKeyHeader: _apiKey,
    };
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  static Future<List<String>> fetchCharitiesFromAPI() async {
    final response = await http.get(
      Uri.parse('$baseURL/all/charities'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load charities from API');
    }
  }

  static Future<void> registerTeam(String username, String teamName,
      String charityName, String donationGoal) async {
    final String url = '$baseURL/register/profile/register/team';

    Map<String, String> requestBody = {
      'username': username,
      'teamName': teamName,
      'charityName': charityName,
      'donationGoal': donationGoal,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to register team: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<String>> fetchTeamsFromAPI() async {
    final response = await http.get(
      Uri.parse('$baseURL/all/teams'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load charities from API');
    }
  }

  static Future<void> joinTeam(String username, String teamName) async {
    final String url = '$baseURL/register/profile/join/team';

    Map<String, String> requestBody = {
      'username': username,
      'teamName': teamName,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to join team: ${response.statusCode} ${response.body}');
    }
  }

  static Future<double> fetchDonations(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username/donatedAmount'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        double donations = double.parse(response.body);
        return donations;
      } else {
        throw Exception('Failed to fetch donations');
      }
    } catch (e) {
      print('Error fetching donations: $e');
      rethrow;
    }
  }

  static Future<double> fetchGoal(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username/donationGoal'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        double goal = double.parse(response.body);
        return goal;
      } else {
        throw Exception('Failed to fetch goal');
      }
    } catch (e) {
      print('Error fetching goal: $e');
      rethrow;
    }
  }

  static Future<String?> fetchTeamName(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['name'];
      } else {
        throw Exception('Failed to fetch team name');
      }
    } catch (e) {
      print('Error fetching team name: $e');
      rethrow;
    }
  }

  static Future<String?> fetchCompanyName(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['company']['name'];
      } else {
        throw Exception('Failed to fetch company name');
      }
    } catch (e) {
      print('Error fetching company name: $e');
      rethrow;
    }
  }

  static Future<String?> fetchCharityName(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['charityOrganization']['name'];
      } else {
        throw Exception('Failed to fetch charity name');
      }
    } catch (e) {
      print('Error fetching charity name: $e');
      rethrow;
    }
  }

  static Future<int?> fetchFundraiserBox(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['fundraiserBox'];
      } else {
        throw Exception('Failed to fetch fundraiser box');
      }
    } catch (e) {
      print('Error fetching fundraiser box: $e');
      rethrow;
    }
  }

  static Future<List<String>?> fetchMembers(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> membersData = data['members'];
        List<String> members =
            membersData.map((member) => member['username'].toString()).toList();
        return members;
      } else {
        throw Exception('Failed to fetch members');
      }
    } catch (e) {
      print('Error fetching members: $e');
      rethrow;
    }
  }

  static Future<String?> fetchChallengeStatus(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/$username/challenge'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(utf8.decode(response.bodyBytes));
        var challengeStatus = responseData['status'];
        return challengeStatus;
      } else {
        throw Exception('Failed to fetch challenge status');
      }
    } catch (e) {
      print('Error fetching challenge status: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchChallengeActivity(String? username) async {
  try {
    final response = await http.get(
      Uri.parse('$baseURL/$username/challenge'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      bool challengeSent = data.any((challenge) =>
          challenge['challengerTeamName'] == username && challenge['status'] == 'PENDING');
      bool challengeReceived = data.any((challenge) =>
          challenge['challengedTeamName'] == username && challenge['status'] == 'PENDING');
      
      String senderTeam = '';
      if (challengeReceived) {
        senderTeam = data.firstWhere((challenge) =>
          challenge['challengedTeamName'] == username && challenge['status'] == 'PENDING')['challengerTeamName'];
      }

      return {
        'challengeSent': challengeSent,
        'challengeReceived': challengeReceived,
        'senderTeam': senderTeam,
      };
    } else {
      throw Exception('Failed to fetch challenge status');
    }
  } catch (e) {
    print('Error fetching challenge status: $e');
    rethrow;
  }
}


  static Future<List<Team>> fetchTeamsWithBoxAndCompanyName() async {
    final response = await http.get(
      Uri.parse('$baseURL/all/teamswithbox'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
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

      List<Team> sortTeams(List<Team> teams) {
        teams.sort((a, b) => b.fundraiserBox.compareTo(a.fundraiserBox));
        return teams;
      }

      List<Team> sortedTeams = sortTeams(fetchedTeams);

      return sortedTeams;
    } else {
      throw Exception('Failed to load teams from API');
    }
  }

  //getters för otherteampage som tar info baserat på lagnamn ist. för username
  static const String baseUrl =
      'https://group-15-7.pvt.dsv.su.se/app/team/byTeamName/';

  static Future<String?> fetchOtherTeamName(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['name'];
      } else {
        throw Exception(
            'Failed to fetch team name: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching team name: $e');
      return null;
    }
  }

  static Future<int?> fetchOtherDonationGoal(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['donationGoal'];
      } else {
        throw Exception(
            'Failed to fetch donation goal: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching donation goal: $e');
      return null;
    }
  }

  static Future<int?> fetchOtherFundraiserBox(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['fundraiserBox'];
      } else {
        throw Exception(
            'Failed to fetch fundraiser box: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching fundraiser box: $e');
      return null;
    }
  }

  static Future<String?> fetchOtherCharityOrganization(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['charityOrganization']['name'];
      } else {
        throw Exception(
            'Failed to fetch charity organization: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching charity organization: $e');
      return null;
    }
  }

  static Future<String?> fetchOtherCompanyName(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['company']['name'];
      } else {
        throw Exception(
            'Failed to fetch company name: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching company name: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> fetchOtherMembers(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['members'];
      } else {
        throw Exception(
            'Failed to fetch team members: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching team members: $e');
      return null;
    }
  }
}
