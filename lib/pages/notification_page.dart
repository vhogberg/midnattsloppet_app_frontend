// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, avoid_print

import 'dart:async';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/custom_colors.dart';
import 'package:flutter_application/components/custom_navigation_bar.dart';
import 'package:iconsax/iconsax.dart';

// Skapa en klass för notifikationen.
class NotificationItem {
  final String title;
  final String message;
  final DateTime timestamp;
  final String? challengeStatus; // Nytt fält

  NotificationItem({
    required this.title,
    required this.message,
    required this.timestamp,
    this.challengeStatus, // Nytt fält
  });
}

class NotificationPage extends StatefulWidget {
  static const routeName = '/notificationPage';
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
          "Tillsammans ska vi göra detta till en oförglömlig upplevelse! \nGlöm inte att hålla ögonen öppna för kommande uppdateringar.\n\nLycka till med din träning och vi ses på startlinjen!",
      timestamp: DateTime.now(),
    ),
  ];

  double donationGoal = 0;
  double totalDonations = 0;
  String? foundStatus;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    dateNotifications(); // Lägg till anropet till metoden som ansvarar för datumsnotiser.
    donationNotifications(); // anrop till metoden som ansvarar för donationsnotiser.
    fetchDonations();
    getChallengeStatus(username);
    challengeNotifications();
    fetchGoal();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDonations();
      fetchGoal();
      getChallengeStatus(username);
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Ta bort TextEditingController
    _timer.cancel();
    super.dispose();
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

    if (percentage >= 100) {
      if (!notificationAlreadyExists("100% av donationsmålet uppnått")) {
        allNotifications.add(
          NotificationItem(
            title: "100% av donationsmålet uppnått",
            message:
                "Ni har uppnått 100% av erat donationsmål!\n\nSUPERBRA JOBBAT!\n\nFantastiskt arbete! Ni har nått ert donationsmål och gör en verklig skillnad. Era generösa donationer gör en enorm skillnad i världen. Varje krona ni har samlat in går till att stödja viktiga välgörenhetsprohekt som förändrar liv till det bättre. Ert engagemang och er insats hjälper till att skapa en bättre framtid för många.\n\nFortsätt springa och inspirera!",
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
                "Ni har uppnått 90% av erat donationsmål!\n\nGrattis och fortsätt!\n\n Ni är så nära att nå ert nål! Visste ni att löpning är en av de mest effektiva aktiviteterna för att förbättre hjärt- och kärnhälsan? Regelbunden löpning kan minska risken för hjärtsjukdomar med upp till 45%. Dessutom ökar det syreupptagningsförmågan och stärker musklerna, vilket gör att ni orkar mer både i och utanför spåret.\n\nFortsätt springa!",
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
                "Ni har uppnått 60% av erat donationsmål!\n\nGrattis och fortsätt!\n\nTänk på detta när ni tränar inför Midnattsloppet: En genomsnittlig löpare tar cirka 1 500 steg per kilometer. Så när du har sprungit 10 km har du tagit ungefär 15 000 steg! Varje steg tar dig närmare dina mål och samtidigt gör ni världen till en bättre plats.\n\nGlöm inte att ha kul!",
            timestamp: DateTime.now(),
          ),
        );
      }
    }
    // Hårdkodade notifikationer baserat på procentandelen av donationsmålet
    if (percentage >= 30) {
      if (!notificationAlreadyExists("30% av donationsmålet uppnått!")) {
        allNotifications.add(
          NotificationItem(
            title: "30% av donationsmålet uppnått!",
            message:
                "Ni har uppnått 30% av erat donationsmål!\n\nGrattis och fortsätt!\n\nEr generösa donation gör också en enorm skillnad i världen. Varje krona ni samlar in hjälper till att finansiera viktiga välgörenhetsprojekt som bidrar till att förbättra livet för de mindre bemedlade. Ert Engagemang och er insats är ovärderlig!\n\nVisste du att löpning inte bara förbättrar din fysiska hälsa utan även din mentala hälsa? Studier har visat att regelbunden löpning kan minska stress, förbättra humöret och öka din koncentration.\n\nFortsätt springa och ha kul!",
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    sortNotificationsByDate();
  }

  void challengeNotifications() async {
    String? test = await getChallengeStatus(username);

    if (test == "PENDING") {
      if (!notificationAlreadyExists(
          "Ni har blivit utmanade eller utmanat ett annat lag!")) {
        allNotifications.add(
          NotificationItem(
            title: "Ni har blivit utmanade eller utmanat ett annat lag!",
            message: "Gör er redo för lagkamp!",
            timestamp: DateTime.now(),
            challengeStatus: "PENDING", // Nytt fält
          ),
        );
      }
    }

    if (test == null) {
      if (!notificationAlreadyExists("Ingen lagkamp påbörjad!")) {
        allNotifications.add(
          NotificationItem(
            title: "Ingen lagkamp påbörjad!",
            message:
                "Ni har ingen påbörjad aktivitet inom lagkamp-sidan.\n\nGå in i lagkampssidan och starta en lagkamp!",
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    if (test == "ACCEPTED") {
      if (!notificationAlreadyExists("Du befinner dig i en lagkamp!")) {
        allNotifications.add(
          NotificationItem(
            title: "Du befinner dig i en lagkamp!",
            message:
                "Du och ditt lag befinner sig nu i en lagkamp!\nGe allt för att vinna och ha kul!\n\nGå in i lagkampssidan och ta reda på mer!",
            timestamp: DateTime.now(),
            challengeStatus: "ACCEPTED", // Nytt fält
          ),
        );
      }
    }

    if (test == "REJECTED") {
      if (!notificationAlreadyExists("Lagkampsförfrågan blev avböjd!")) {
        allNotifications.add(
          NotificationItem(
            title: "Lagkampsförfrågan blev avböjd!",
            message:
                "Ditt lag eller laget ni utmanat har avböjt lagkampsförfrågan!\nGå in i lagkampssidan och utmana ett annat lag!",
            timestamp: DateTime.now(),
            challengeStatus: "REJECTED", // Nytt fält
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
                "Det är 50 dagar kvar till midnattsloppets racestart!\n\nFun fact: Regelbunden löpning kan hjälpa till att förbättra sömnkvaliteten, vilket gör att löpare ofta sover djupare och vaknar mer utvilade.\n\nSpara datumet: 17 Augusti 2024",
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
                "Det är 100 dagar kvar till midnattsloppets racestart!\n\nHirstorisk fun fact: Det första moderna maratonloppet hölls under de olympiska spelen i Aten 1896. Det inspirerades av den mytiska språngmarschen av greken Pheidippides från slaget vid Marathon till Aten.\n\nSpara datumet: 17 Augusti 2024",
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
      backgroundColor: Colors
          .transparent, // gör bakgrunden transparent för att tillämpa anpassad bakgrund
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white, // bakgrundsfärgen för hela fönstret
            borderRadius: BorderRadius.circular(0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                const Text(
                  'Sök notifikation',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // bakgrundsfärgen för sökrutan
                    borderRadius: BorderRadius.circular(0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Ange notifikation',
                      labelStyle: TextStyle(
                        fontFamily: 'Sora',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      filled: true,
                      fillColor: Colors.white, // bakgrundsfärgen för sökrutan
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.midnattsblue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                    ),
                    child: const Text(
                      'Sök',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
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

  // Funktion för att hämta aktuella donationer
  Future<double> fetchDonations() async {
    try {
      double? total = await ApiUtils.fetchDonations(username);
      setState(() {
        totalDonations = total;
      });
      return totalDonations;
    } catch (e) {
      print("Error fetching donations: $e");
    }
    return 0;
  }

  // Funktion för att hämta donationsmål
  Future<double> fetchGoal() async {
    try {
      double goal = await ApiUtils.fetchGoal(username);
      setState(() {
        donationGoal = goal;
      });
      return donationGoal;
    } catch (e) {
      print("Error fetching goal: $e");
    }
    return 0;
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

  Future<String?> getChallengeStatus(String? username) async {
    try {
      var statuses = await ApiUtils.fetchChallengeStatus(username);
      for (String status in statuses) {
        if (status == 'ACCEPTED') {
          foundStatus = status;
          break; // Avbryt loopen när vi hittar ACCEPTED
        }

        if (status == 'PENDING') {
          foundStatus = status;
          break;
        }
      }
      return foundStatus;
    } catch (e) {
      // Hantera eventuella fel vid hämtning av statusen
      print('Error: $e');
      return null; // Default till 'PENDING' om ett fel uppstår
    }
  }

  void sortNotificationsByDate() {
    allNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    sortNotificationsByDate(); // Sortera notiser vid rendering
    return Scaffold(
      appBar: CustomAppBar(
        key: null,
        title: 'Notifikationer',
        showReturnArrow: true,
        useActionButton: true,
        actionIcon: Iconsax.search_normal_1,
        onActionPressed: () {
          _showSearchModal(context);
        },
      ),
      body: Column(
        children: [
          Container(
            color: CustomColors.midnattsblue, // Färgen på strecket
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
            padding: const EdgeInsets.symmetric(
                vertical: 16.0), // Ökad padding för större avstånd
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withOpacity(0.9),
                  width: 0.7,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0, // Ökad textstorlek
                      fontFamily: 'Sora',
                    ),
                  ),
                  subtitle: Text(
                    notification.message,
                    maxLines: 2, // Begränsa till två rader
                    overflow: TextOverflow
                        .ellipsis, // Visa "..." om texten är för lång
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0, // Ökad textstorlek
                      fontFamily: 'Sora',
                    ),
                  ),
                ),
                if (_isTextOverflowing(
                    notification.message)) // Kontrollera om texten är avklippt
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Text(
                      'Klicka för att läsa mer',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                        fontFamily: 'Sora',
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
      text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14.0, fontFamily: 'Sora')),
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
    bool showSaveDateButton =
        notification.message.contains("Spara datumet: 17 Augusti 2024");
    bool showChallengePageButton = notification.title ==
            "Ni har blivit utmanade eller utmanat ett annat lag!" ||
        notification.title == "Ingen lagkamp påbörjad!" ||
        notification.title == "Du befinner dig i en lagkamp!";

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            notification.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'Sora',
            ),
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
                fontFamily: 'Sora',
              ),
            ),
            const SizedBox(height: 16.0),
            if (showSaveDateButton)
              GestureDetector(
                onTap: () {
                  final Event event = Event(
                    title: 'Midnattsloppet',
                    description: 'Distans 10 km',
                    location: 'Södermalm',
                    startDate: DateTime(2024, 8, 17, 21, 45),
                    endDate: DateTime(2024, 8, 17, 24, 00),
                    iosParams: const IOSParams(
                      url:
                          'https://midnattsloppet.com/midnattsloppet-stockholm/',
                    ),
                    androidParams: const AndroidParams(
                      emailInvites: [], // on Android, you can add invite emails to your event.
                    ),
                  );
                  Add2Calendar.addEvent2Cal(event);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13.0),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.calendar_add,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Spara datumet!',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Sora',
                        ),
                      )
                    ],
                  ),
                ),
              ),
            if (showChallengePageButton) ...[
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  // Navigera till Lagkampssidan
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CustomNavigationBar(
                              selectedPage: 1,
                            )),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13.0),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.medal_star,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Gå till lagkampssidan',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
