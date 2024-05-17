import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/session_manager.dart';

class Notification {
  final String id;
  final String title;
  final String body;
  bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    this.isRead = false,
  });
}

class HardcodedNotifications {
  /* String? username = SessionManager.instance.username;
  double totalDonations = 0;
  double donationGoal = 0;
  String challengeStatus = '';

  bool notificationAlreadyExists(String title) {
    return NotificationProvider()
        ._notifications
        .any((notification) => notification.title == title);
  }

  void showNotificationIfNeeded(daysLeft) {
    // Kontrollera om det är 50 dagar kvar
    if (daysLeft <= 50) {
      // Kontrollera om notifikationen redan har skapats
      if (!notificationAlreadyExists("50 dagar kvar till loppet")) {
        NotificationProvider().addNotification(
          Notification(
            id: '50_dagar',
            title: "50 dagar kvar till loppet",
            body:
                "Det är 50 dagar kvar till midnattsloppets racestart! \nSpara datumet: 17 Augusti 2024",
          ),
        );
      }
    }

    // Kontrollera om det är 100 dagar kvar
    if (daysLeft <= 100) {
      // Kontrollera om notifikationen redan har skapats
      if (!notificationAlreadyExists("100 dagar kvar till loppet")) {
        NotificationProvider().addNotification(
          Notification(
            id: '100_dagar',
            title: "100 dagar kvar till loppet",
            body:
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

  Future<double> fetchDonations() async {
    try {
      double? total = await ApiUtils.fetchDonations(username);
      if (total == null) {
        throw Exception('Total donations returned null');
      }

      totalDonations = total;

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
      donationGoal = goal;
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

  Future<void> donationNotifications() async {
    double percentage = await calculateDonationPercentage();

    // Hårdkodade notifikationer baserat på procentandelen av donationsmålet
    if (percentage >= 30) {
      if (!notificationAlreadyExists("30% av donationsmålet uppnått!")) {
        NotificationProvider().addNotification(
          Notification(
            id: '30%_nått',
            title: "30% av donationsmålet uppnått!",
            body:
                "Ni har uppnått 30% av erat donationsmål! \nGrattis och fortsätt!",
          ),
        );
      }
    }

    if (percentage >= 60) {
      if (!notificationAlreadyExists("60% av donationsmålet uppnått!")) {
        NotificationProvider().addNotification(
          Notification(
            id: '60%_nått',
            title: "60% av donationsmålet uppnått!",
            body:
                "Ni har uppnått 60% av erat donationsmål! \nGrattis och fortsätt!",
          ),
        );
      }
    }

    if (percentage >= 90) {
      if (!notificationAlreadyExists("90% av donationsmålet uppnått")) {
        NotificationProvider().addNotification(
          Notification(
            id: '90%_nått',
            title: "90% av donationsmålet uppnått",
            body:
                "Ni har uppnått 90% av erat donationsmål! \nGrattis och fortsätt!",
          ),
        );
      }
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

  void challengeNotifications() {
    if (challengeStatus.contains("PENDING")) {
      if (!notificationAlreadyExists("50 dagar kvar till loppet")) {
        NotificationProvider().addNotification(
          Notification(
            id: 'PENDING_utmaning',
            title: "Ni har blivit utmanade eller utmanat ett annat lag!",
            body: "Gör er redo för lagkamp!",
          ),
        );
      }
    }

    if (challengeStatus.contains("ACCEPTED")) {
      if (!notificationAlreadyExists("Du befinner dig i en lagkamp!")) {
        NotificationProvider().addNotification(
          Notification(
            id: 'ACCEPTED_utmaning',
            title: "Du befinner dig i en lagkamp!",
            body:
                "Du och ditt lag befinner sig nu i en lagkamp!\nGe allt för att vinna och ha kul!",
          ),
        );
      }
    }

    if (challengeStatus.contains("REJECTED")) {
      if (!notificationAlreadyExists(
          "{lagnamn} avböjde din inbjudan på att starta lagkamp")) {
        NotificationProvider().addNotification(
          Notification(
            id: 'REJECTED_utmaning',
            title: "{lagnamn} avböjde din inbjudan på att starta lagkamp",
            body: "",
          ),
        );
      }
    }
  } */
}

class NotificationProvider with ChangeNotifier {
  final List<Notification> _notifications = [];
  final List<Notification> _read = [];
  final List<Notification> _unread = [];

  String? username = SessionManager.instance.username;
  double totalDonations = 0;
  double donationGoal = 0;
  String challengeStatus = '';

  bool notificationAlreadyExists(String title) {
    return NotificationProvider()
        ._notifications
        .any((notification) => notification.title == title);
  }

  void addWelcomeMessage() {
    _notifications.add(
      Notification(
        id: 'Välkommen',
        title: "Välkommen",
        body: "Välkommen",
      ),
    );
  }

  void showNotificationIfNeeded(daysLeft) {
    // Kontrollera om det är 50 dagar kvar
    if (daysLeft <= 50) {
      // Kontrollera om notifikationen redan har skapats
      if (!notificationAlreadyExists("50 dagar kvar till loppet")) {
        NotificationProvider().addNotification(
          Notification(
            id: '50_dagar',
            title: "50 dagar kvar till loppet",
            body:
                "Det är 50 dagar kvar till midnattsloppets racestart! \nSpara datumet: 17 Augusti 2024",
          ),
        );
      }
    }

    // Kontrollera om det är 100 dagar kvar
    if (daysLeft <= 100) {
      // Kontrollera om notifikationen redan har skapats
      if (!notificationAlreadyExists("100 dagar kvar till loppet")) {
        NotificationProvider().addNotification(
          Notification(
            id: '100_dagar',
            title: "100 dagar kvar till loppet",
            body:
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

  Future<double> fetchDonations() async {
    try {
      double? total = await ApiUtils.fetchDonations(username);
      if (total == null) {
        throw Exception('Total donations returned null');
      }

      totalDonations = total;

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
      donationGoal = goal;
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

  Future<void> donationNotifications() async {
    double percentage = await calculateDonationPercentage();

    // Hårdkodade notifikationer baserat på procentandelen av donationsmålet
    if (percentage >= 30) {
      if (!notificationAlreadyExists("30% av donationsmålet uppnått!")) {
        NotificationProvider().addNotification(
          Notification(
            id: '30%_nått',
            title: "30% av donationsmålet uppnått!",
            body:
                "Ni har uppnått 30% av erat donationsmål! \nGrattis och fortsätt!",
          ),
        );
      }
    }

    if (percentage >= 60) {
      if (!notificationAlreadyExists("60% av donationsmålet uppnått!")) {
        NotificationProvider().addNotification(
          Notification(
            id: '60%_nått',
            title: "60% av donationsmålet uppnått!",
            body:
                "Ni har uppnått 60% av erat donationsmål! \nGrattis och fortsätt!",
          ),
        );
      }
    }

    if (percentage >= 90) {
      if (!notificationAlreadyExists("90% av donationsmålet uppnått")) {
        NotificationProvider().addNotification(
          Notification(
            id: '90%_nått',
            title: "90% av donationsmålet uppnått",
            body:
                "Ni har uppnått 90% av erat donationsmål! \nGrattis och fortsätt!",
          ),
        );
      }
    }
  }

  Future<void> getChallengeStatus() async {
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

  void challengeNotifications() {
    if (challengeStatus.contains("PENDING")) {
      if (!notificationAlreadyExists("50 dagar kvar till loppet")) {
        NotificationProvider().addNotification(
          Notification(
            id: 'PENDING_utmaning',
            title: "Ni har blivit utmanade eller utmanat ett annat lag!",
            body: "Gör er redo för lagkamp!",
          ),
        );
      }
    }

    if (challengeStatus.contains("ACCEPTED")) {
      if (!notificationAlreadyExists("Du befinner dig i en lagkamp!")) {
        NotificationProvider().addNotification(
          Notification(
            id: 'ACCEPTED_utmaning',
            title: "Du befinner dig i en lagkamp!",
            body:
                "Du och ditt lag befinner sig nu i en lagkamp!\nGe allt för att vinna och ha kul!",
          ),
        );
      }
    }

    if (challengeStatus.contains("REJECTED")) {
      if (!notificationAlreadyExists(
          "{lagnamn} avböjde din inbjudan på att starta lagkamp")) {
        NotificationProvider().addNotification(
          Notification(
            id: 'REJECTED_utmaning',
            title: "{lagnamn} avböjde din inbjudan på att starta lagkamp",
            body: "",
          ),
        );
      }
    }
  }

  List<Notification> get unreadNotifications =>
      _notifications.where((notification) => !notification.isRead).toList();

  List<Notification> get readNotifications =>
      _notifications.where((notification) => notification.isRead).toList();

  void addNotification(Notification notification) {
    _notifications.add(notification);
    notifyListeners();
  }

  void markAsRead(String id) {
    final notification = _notifications.firstWhere((notif) => notif.id == id);
    notification.isRead = true;
    notifyListeners();
  }
}

class NotificationPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('hej');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .addWelcomeMessage();
    });
    print(NotificationProvider()._notifications);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Unread',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...notificationProvider.unreadNotifications
                  .map((notif) => ListTile(
                        title: Text(notif.title),
                        subtitle: Text(notif.body),
                        onTap: () {
                          notificationProvider.markAsRead(notif.id);
                          notificationProvider.unreadNotifications
                              .remove(notif.id);
                        },
                      )),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Read',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...notificationProvider.readNotifications.map((notif) => ListTile(
                    title: Text(notif.title),
                    subtitle: Text(notif.body),
                  )),
            ],
          );
        },
      ),
    );
  }
}
