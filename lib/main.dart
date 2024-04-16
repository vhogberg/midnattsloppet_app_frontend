import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _response = []; // Variable to store API response

  Future<void> fetchData() async {
    // Your API endpoint URL
    final String apiUrl = 'https://group-15-7.pvt.dsv.su.se/app/all';

    try {
      // Making GET request
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final jsonData = json.decode(response.body);
        setState(() {
          // Update the UI with the response data
          _response = List<Map<String, dynamic>>.from(jsonData);
        });
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Catching any error that might occur during the request
      setState(() {
        _response = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Test of listing users'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Response:',
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _response.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_response[index]['name']),
                    subtitle: Text(_response[index]['company']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Call the fetchData function when the button is pressed
          fetchData();
        },
        tooltip: 'Fetch Data',
        child: Icon(Icons.refresh),
      ),
    );
  }
}