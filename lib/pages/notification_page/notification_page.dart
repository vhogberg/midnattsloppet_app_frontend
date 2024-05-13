import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

// Skapa en klass för notifikationen
class NotificationItem {
  final String title;
  final String message;
  bool isRead; // Spåra om notisen är läst eller inte

  NotificationItem(
      {required this.title, required this.message, this.isRead = false});
}

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late SharedPreferences _prefs; // SharedPreferences-instans
  late TabController
      _tabController; // TabController för att hantera TabBar och TabBarView
  final TextEditingController _searchController =
      TextEditingController(); // Controller för sökfältet
  String _searchTerm = ''; // Söktermen
  String?
      username; // Användarnamn för att hämta mängden insamlat i insamlingbössan och donationsmålet

  // Notifikationslistan.
  List<NotificationItem> allNotifications = [
    NotificationItem(
      title: "Välkommen till Midnattsloppet Fortal!",
      message:
          "Tillsammans ska vi göra detta till en oförglömlig upplevelse! Glöm inte att hålla ögonen öppna för kommande uppdateringar och spännande nyheter.\n\nLycka till med din träning och vi ses på startlinjen!",
    ),
  ];

  List<NotificationItem> unreadNotifications = [];
  List<NotificationItem> readNotifications = [];

  double donationGoal = 0;
  double totalDonations = 0;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this); // Skapa en TabController med 3 flikar
    initializeSharedPreferences();
    username = SessionManager.instance.username;
    dateNotifications(); // Lägg till anropet till metoden som ansvarar för datumsnotiser.
    donationNotifications(); // anrop till metoden som ansvarar för donationsnotiser.
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDonations();
      fetchGoal();
    });
  }

  void resetLists() {
    setState(() {
      unreadNotifications.clear();
      readNotifications.clear();
      separateNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Ta bort TabController när widgeten förstörs
    _searchController.dispose(); // Ta bort TextEditingController
    _timer.cancel();
    super.dispose();
  }

  // Hämta SharedPreferences-instans och notisstatus
  void initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    fetchNotificationStatus(); // Hämta notisstatus från SharedPreferences
    separateNotifications();
  }

  // Hämta och uppdatera notisernas lässtatus från SharedPreferences
  void fetchNotificationStatus() {
    for (var notification in allNotifications) {
      bool isRead = _prefs.getBool(notification.title) ?? false;
      notification.isRead = isRead;
    }
  }

  // Separera notifikationer baserat på om de är lästa eller olästa
  void separateNotifications() {
    for (var notification in allNotifications) {
      if (notification.isRead) {
        readNotifications.add(notification);
      } else {
        unreadNotifications.add(notification);
      }
    }
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

  void donationNotifications() {
    // Hårdkodade notifikationer baserat på procentandelen av donationsmålet
    if (calculatePercentage() >= 30) {
      allNotifications.add(
        NotificationItem(
          title: "30% av donationsmålet uppnått!",
          message:
              "Ni har uppnått 30% av erat donationsmål! \nGrattis och fortsätt!",
        ),
      );
    }

    if (calculatePercentage() >= 60) {
      allNotifications.add(
        NotificationItem(
          title: "60% av donationsmålet uppnått!",
          message:
              "Ni har uppnått 60% av erat donationsmål! \nGrattis och fortsätt!",
        ),
      );
    }

    if (calculatePercentage() >= 90) {
      allNotifications.add(
        NotificationItem(
          title: "90% av donationsmålet uppnått",
          message:
              "Ni har uppnått 90% av erat donationsmål! \nGrattis och fortsätt!",
        ),
      );
    }
  }

  void challengeNotifications() {


    


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
          ),
        );
      }
    }
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
  Future<void> fetchDonations() async {
    try {
      double total = await ApiUtils.fetchDonations(username);
      setState(() {
        totalDonations = total;
      });
    } catch (e) {
      print("Error fetching donations: $e");
    }
  }

  // Funktion för att hämta donationsmål
  Future<void> fetchGoal() async {
    try {
      double goal = await ApiUtils.fetchGoal(username);
      setState(() {
        donationGoal = goal;
      });
    } catch (e) {
      print("Error fetching goal: $e");
    }
  }

  double calculatePercentage() {
    if (donationGoal == 0) {
      return 0.0; // Undvik division med noll
    } else {
      return (totalDonations / donationGoal) * 100;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Alla'),
            Tab(text: 'Olästa'),
            Tab(text: 'Lästa'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                NotificationList(
                  notifications: _searchTerm.isEmpty
                      ? allNotifications
                      : filterNotifications(_searchTerm),
                  updateStatus: updateNotificationStatus,
                ),
                NotificationList(
                  notifications: _searchTerm.isEmpty
                      ? unreadNotifications
                      : filterNotifications(_searchTerm),
                  updateStatus: updateNotificationStatus,
                ),
                NotificationList(
                  notifications: _searchTerm.isEmpty
                      ? readNotifications
                      : filterNotifications(_searchTerm),
                  updateStatus: updateNotificationStatus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final List<NotificationItem> notifications;
  final Function(NotificationItem)
      updateStatus; // Funktion för att uppdatera notisstatus

  const NotificationList(
      {required this.notifications, required this.updateStatus});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Markera notisen som läst när den klickas på
            notifications[index].isRead = true;
            // Uppdatera notisens status i SharedPreferences
            updateStatus(notifications[index]);
            // Uppdatera UI när en notis klickas på
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationDetail(notification: notifications[index]),
              ),
            ).then((value) {
              // Återställ listorna när användaren återvänder från notisdetaljsidan
              _NotificationPageState notificationPageState =
                  context.findAncestorStateOfType<_NotificationPageState>()!;
              notificationPageState.resetLists();
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withOpacity(0.1),
                  width: 0.7,
                ),
              ),
            ),
            child: ListTile(
              title: Text(
                notifications[index].title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              subtitle: Text(
                notifications[index].message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
        );
      },
    );
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
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
