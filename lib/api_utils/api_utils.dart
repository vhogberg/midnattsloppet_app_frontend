import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiUtils {
  static Future<double> fetchDonations(String? username) async {
    try {
      var response = await http.get(Uri.parse(
          'https://group-15-7.pvt.dsv.su.se/app/team/$username/donatedAmount'));

      if (response.statusCode == 200) {
        double donations = double.parse(response.body);
        return donations;
      } else {
        throw Exception('Failed to fetch donations');
      }
    } catch (e) {
      print('Error fetching donations: $e');
      rethrow; // Rethrow the exception to handle it in the calling code
    }
  }

  static Future<double> fetchGoal(String? username) async {
    try {
      var response = await http.get(Uri.parse(
          'https://group-15-7.pvt.dsv.su.se/app/team/$username/donationGoal'));

      if (response.statusCode == 200) {
        double goal = double.parse(response.body);
        return goal;
      } else {
        throw Exception('Failed to fetch goal');
      }
    } catch (e) {
      print('Error fetching goal: $e');
      rethrow; // Rethrow the exception to handle it in the calling code
    }
  }
}
