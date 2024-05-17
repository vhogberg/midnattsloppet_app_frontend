import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Skapa en klass för notifikationen.
class NotificationItem {
  final String title;
  final String message;
  bool isRead; // Spåra om notisen är läst eller inte
  final DateTime timestamp; // Lägg till ett timestamp för notisen

  NotificationItem({
    required this.title,
    required this.message,
    this.isRead = false,
    required this.timestamp, // Lägg till timestamp här
  });
}

class NotificationPage extends StatefulWidget {
  static const routeName = '/notificationPage';
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late SharedPreferences _prefs; // SharedPreferences-instans
  final TextEditingController _searchController =
      TextEditingController(); // Controller för sökfältet
  String _searchTerm = ''; // Söktermen
  String? username; // Användarnamn för att hämta mängden insamlat i insamlingbössan och donationsmålet

  // Notifikationslistan.
  List<NotificationItem> allNotifications = [
    NotificationItem(
      title: "Välkommen till Midnattsloppet Fortal!",
      message:
          "Tillsammans ska vi göra detta till en oförglömlig upplevelse! \nGlöm inte att hålla ögonen öppna för kommande uppdateringar.\n\nLycka till med din träning och vi ses på startlinjen!",
      timestamp: DateTime.now(),
    ),
  ];

  double donationGoal = 0;
  double totalDonations = 0;
  String challengeStatus = "";

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    dateNotifications(); // Lägg till anropet till metoden som ansvarar för datumsnotiser.
    donationNotifications(); // anrop till metoden som ansvarar för donationsnotiser.
    fetchDonations();
    fetchGoal();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDonations();
      fetchGoal();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Ta bort TextEditingController
    _timer.cancel();
    super.dispose();
  }

  // Uppdatera notisens lässtatus i SharedPreferences
  void updateNotificationStatus(NotificationItem notification) {
    _prefs.setBool(notification.title, notification.isRead);
  }

  // Funktion för filtrering av notifikationer baserat på söktermen
  List<NotificationItem> filterNotifications(String searchTerm) {
    return allNotifications.where((notification) {
      return notification.title
              .toLowerCase()
              .contains(searchTerm.toLowerCase()) ||
          notification.message.toLowerCase().contains(searchTerm.toLowerCase());
    }).toList();
  }

  Future<void> donationNotifications() async {
    double percentage = await calculateDonationPercentage();

    // Hårdkodade notifikationer baserat på procentandelen av donationsmålet
    if (percentage >= 30) {
      if (!notificationAlreadyExists("30% av donationsmålet uppnått!")) {
        allNotifications.add(
          NotificationItem(
            title: "30% av donationsmålet uppnått!",
            message:
                "Ni har uppnått 30% av erat donationsmål! \nGrattis och fortsätt!",
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    if (percentage >= 60) {
      if (!notificationAlreadyExists("60% av donationsmålet uppnått!")) {
        allNotifications.add(
          NotificationItem(
            title: "60% av donationsmålet uppnått!",
            message:
                "Ni har uppnått 60% av erat donationsmål! \nGrattis och fortsätt!",
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    if (percentage >= 90) {
      if (!notificationAlreadyExists("90% av donationsmålet uppnått")) {
        allNotifications.add(
          NotificationItem(
            title: "90% av donationsmålet uppnått",
            message:
                "Ni har uppnått 90% av erat donationsmål! \nGrattis och fortsätt!",
            timestamp: DateTime.now(),
          ),
        );
      }
    }
    sortNotificationsByDate();
  }

  void challengeNotifications() {
    if (challengeStatus.contains("PENDING")) {
      if (!notificationAlreadyExists("50 dagar kvar till loppet")) {
        allNotifications.add(
          NotificationItem(
            title: "Ni har blivit utmanade eller utmanat ett annat lag!",
            message: "Gör er redo för lagkamp!",
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    if (challengeStatus.contains("ACCEPTED")) {
      if (!notificationAlreadyExists("Du befinner dig i en lagkamp!")) {
        allNotifications.add(
          NotificationItem(
            title: "Du befinner dig i en lagkamp!",
            message:
                "Du och ditt lag befinner sig nu i en lagkamp!\nGe allt för att vinna och ha kul!",
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    if (challengeStatus.contains("REJECTED")) {
      if (!notificationAlreadyExists(
          "{lagnamn} avböjde din inbjudan på att starta lagkamp")) {
        allNotifications.add(
          NotificationItem(
            title: "{lagnamn} avböjde din inbjudan på att starta lagkamp",
            message: "",
            timestamp: DateTime.now(),
          ),
        );
      }
    }
    sortNotificationsByDate();
  }

  void showNotificationIfNeeded(daysLeft) {
    // Kontrollera om det är 50 dagar kvar
    if (daysLeft <= 50) {
      // Kontrollera om notifikationen redan har skapats
      if (!notificationAlreadyExists("50 dagar kvar till loppet")) {
        allNotifications.add(
          NotificationItem(
            title: "50 dagar kvar till loppet",
            message:
                "Det är 50 dagar kvar till midnattsloppets racestart! \nSpara datumet: 17 Augusti 2024",
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    // Kontrollera om det är 100 dagar kvar
    if (daysLeft <= 100) {
      // Kontrollera om notifikationen redan har skapats
      if (!notificationAlreadyExists("100 dagar kvar till loppet")) {
        allNotifications.add(
          NotificationItem(
            title: "100 dagar kvar till loppet",
            message:
                "Det är 100 dagar kvar till midnattsloppets racestart! \nSpara datumet: 17 Augusti 2024",
            timestamp: DateTime.now(),
          ),
        );
      }
    }
    sortNotificationsByDate();
  }

  void dateNotifications() {
    // Datumet att räkna ner till
    DateTime targetDate = DateTime(2024, 8, 17);

    // Beräkna antal dagar kvar
    DateTime now = DateTime.now();
    int daysLeft = targetDate.difference(now).inDays;

    // Visa notifikation om det behövs
    showNotificationIfNeeded(daysLeft);
  }

  // Funktion för att kontrollera om en notifikation redan finns
  bool notificationAlreadyExists(String title) {
    return allNotifications.any((notification) => notification.title == title);
  }

  // Funktion för att visa modalbottenpanelen för sökning
  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                      _searchController.clear();
                      setState(() {
                        _searchTerm = '';
                      });
                    },
                  ),
                ],
              ),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Sök',
                ),
                onChanged: (value) {
                  setState(() {
                    _searchTerm = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Sök'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Funktion för att hämta aktuella donationer
  Future<double> fetchDonations() async {
    try {
      double? total = await ApiUtils.fetchDonations(username);
      if (total == null) {
        throw Exception('Total donations returned null');
      }
      setState(() {
        totalDonations = total;
      });
      return totalDonations;
    } catch (e) {
      print("Error fetching donations: $e");
      rethrow; // Rethrow the caught exception
    }
  }

  // Funktion för att hämta donationsmål
  Future<double> fetchGoal() async {
    try {
      double goal = await ApiUtils.fetchGoal(username);
      if (goal == null) {
        throw Exception('Total donations returned null');
      }
      setState(() {
        donationGoal = goal;
      });
      return donationGoal;
    } catch (e) {
      print("Error fetching goal: $e");
      rethrow;
    }
  }

  //Metod för att använda inhämtae donationsmål och donationsvärde
  Future<double> calculateDonationPercentage() async {
    try {
      // Fetch donations
      double totalDonations = await fetchDonations();

      // Fetch goal
      double donationGoal = await fetchGoal();

      // Calculate percentage
      if (donationGoal == 0) {
        return 0.0; // Avoid division by zero
      }
      double percentage = (totalDonations / donationGoal) * 100;

      return percentage;
    } catch (e) {
      print("Error calculating donation percentage: $e");
      rethrow; // Rethrow the caught exception
    }
  }

  void getChallengeStatus(String? username) async {
    try {
      var status = await ApiUtils.fetchChallengeStatus(username);
      if (status != null) {
        challengeStatus = status;
      } else {
        // Hantera om statusen inte är tillgänglig
        print('Challenge status not available');
      }
    } catch (e) {
      // Hantera eventuella fel vid hämtning av statusen
      print('Error: $e');
    }
  }

  void sortNotificationsByDate() {
    allNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    sortNotificationsByDate(); // Sortera notiser vid rendering
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifikationer',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _showSearchModal(context);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF3C4785), // Färgen på strecket
            height: 4.0, // Tjockleken på strecket
          ),
          Expanded(
            child: NotificationList(
              notifications: _searchTerm.isEmpty
                  ? allNotifications
                  : filterNotifications(_searchTerm),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final List<NotificationItem> notifications;

  const NotificationList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return GestureDetector(
          onTap: () {
            // Markera notisen som läst när den klickas på
            // Uppdatera UI när en notis klickas på
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationDetail(notification: notification),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0), // Ökad padding för större avstånd
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withOpacity(0.9),
                  width: 0.7,
                ),
              ),
            ),
            child: Stack(
              children: [
                ListTile(
                  title: Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0, // Ökad textstorlek
                    ),
                  ),
                  subtitle: Text(
                    notification.message,
                    maxLines: 2, // Begränsa till två rader
                    overflow: TextOverflow.ellipsis, // Visa "..." om texten är för lång
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0, // Ökad textstorlek
                    ),
                  ),
                ),
                if (_isTextOverflowing(notification.message)) // Kontrollera om texten är avklippt
                  Positioned(
                    bottom: 8.0,
                    right: 16.0,
                    child: Text(
                      'Klicka för att läsa mer',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isTextOverflowing(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(fontSize: 14.0)),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 100); // Justera maxWidth till bredden på ListTile
    return textPainter.didExceedMaxLines;
  }
}

class NotificationDetail extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetail({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          notification.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0, // Ökad textstorlek
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
