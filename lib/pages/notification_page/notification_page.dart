import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Skapa en klass för notifikationen
class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  bool isRead; // Spåra om notisen är läst eller inte

  NotificationItem(
      {required this.title,
      required this.message,
      required this.time,
      this.isRead = false});
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

  // simulera notifikationer
  List<NotificationItem> allNotifications = [
    NotificationItem(
      title: "Du har blivit utmanad av {företag} {lagnamn}",
      message: "Gå in i \"lagkamp\"-fliken för att acceptera utmaningen!",
      time: DateTime.now(),
    ),
    NotificationItem(
      title: "30% av donationsmålet uppnått!",
      message:
          "Ni har uppnått 30% av erat donationsmål! \nGrattis och fortsätt!",
      time: DateTime.now(),
    ),
    NotificationItem(
      title: "60% av donationsmålet uppnått!",
      message:
          "Ni har uppnått 60% av erat donationsmål! \nGrattis och fortsätt!",
      time: DateTime.now(),
    ),
    NotificationItem(
      title: "90% av donationsmålet uppnått",
      message:
          "Ni har uppnått 90% av erat donationsmål! \nGrattis och fortsätt!",
      time: DateTime.now(),
    ),
    NotificationItem(
      title: "50 dagar kvar till loppet",
      message:
          "Det är 50 dagar kvar till midnattsloppets racestart! \nSpara datumet: 27 Augusti 2024",
      time: DateTime.now(),
    ),
    NotificationItem(
      title: "100 dagar kvar till loppet",
      message:
          "Det är 100 dagar klvar till midnattsloppets racestart! \nSpara datumet: 27 Augusti 2024",
      time: DateTime.now(),
    ),
    // Andra notifikationer här ...
  ];

  List<NotificationItem> unreadNotifications = [];
  List<NotificationItem> readNotifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this); // Skapa en TabController med 3 flikar
    initializeSharedPreferences();
  }

  @override
  void dispose() {
    _tabController.dispose(); // Ta bort TabController när widgeten förstörs
    _searchController.dispose(); // Ta bort TextEditingController
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

  // Återställ listorna när användaren ändrar fliken
  void resetLists() {
    unreadNotifications.clear();
    readNotifications.clear();
    separateNotifications();
  }

  // Uppdatera notisens lässtatus i SharedPreferences
  void updateNotificationStatus(NotificationItem notification) {
    _prefs.setBool(notification.title, notification.isRead);
  }

  // Funktion för att filtrera notifikationer baserat på söktermen
  List<NotificationItem> filterNotifications(String searchTerm) {
    return allNotifications.where((notification) {
      return notification.title
              .toLowerCase()
              .contains(searchTerm.toLowerCase()) ||
          notification.message.toLowerCase().contains(searchTerm.toLowerCase());
    }).toList();
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
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
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
                decoration: InputDecoration(
                  labelText: 'Sök',
                ),
                onChanged: (value) {
                  setState(() {
                    _searchTerm = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontFamily: 'Nunito'), // Ändra fonten för texten på knappen
                ),
                onPressed: () {
                  Navigator.pop(context); // Stäng modalbottenpanelen
                  // Utför sökningen här om det behövs
                },
                child: Text('Sök'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikationer',
          style: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _showSearchModal(
                    context); // Visa modalbottenpanelen för sökning
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController, // Använd vår TabController
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
              controller: _tabController, // Använd vår TabController
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
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              subtitle: Text(
                notifications[index].message,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
              trailing: Text(
                '${notifications[index].time.hour}:${notifications[index].time.minute}',
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
            fontFamily: 'Sora',
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
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Tid: ${notification.time.hour}:${notification.time.minute}',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




