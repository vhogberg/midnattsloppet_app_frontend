import 'package:flutter/material.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:iconsax/iconsax.dart';

class ChallengePage extends StatelessWidget {
  // Dessa variabler bör ju sättas nån annanstans
  bool challengeSent =
      false; // Bool för ifall en användare har skickat en inbjudan till ett annat team
  bool challengeReceived =
      true; // Bool för ifall ett annat team har skickat en inbjudan till användaren
  String senderTeam = 'Nordea lag 3'; // Namnet på teamet som skicka inbjudan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        key: null,
        title: 'Lagkamp',
        useActionButton: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'images/CompetitionImage.png',
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 6), // space mellan nedkant av bild och sökfält
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10), // space i topkant och nedkant av sökfält
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Sök upp lag att utmana...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 4), // space under sökfält och mellan textinstruktionerna
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0), // space mellan punkt 1-2
                      child: Text(
                        '1. Sök upp ett lag som ni vill starta lagkamp emot',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0), // space mellan punkt 2-3
                      child: Text(
                        '2. Skicka iväg utmaningen och invänta svar från det andra laget',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.0), // space mellan punkt 3 och skicka-knapp
                      child: Text(
                        '3. En aktiv lagkamp startas där ni kan tävla i donationer och skapa egna mini-tävlingar!',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Skicka iväg utmaning-knapp
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6), // igen, space ovanför skicka-knapp, lite dubbelfunktion här.
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 65,
                        decoration: BoxDecoration(
                          color: const Color(0XFF3C4785),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/fire.png',
                              width: 35,
                              height: 35,
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              'Skicka iväg utmaningen!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Image.asset(
                              'images/fire.png',
                              width: 35,
                              height: 35,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

// test 2

              // Inboxlåda för utmaningar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: challengeReceived
                    ? Column(
                        children: [
                          Text(
                            // senderTeam byts ut baserat på variabeln längst upp
                            '$senderTeam vill starta en lagkamp med er, acceptera?',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Sora',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Acceptera lagkamp knapp
                              ElevatedButton(
                                onPressed: () {
                                  // Acceptera lagkamp logik här
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Acceptera',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black, // Black text color
                                      ),
                                    ),
                                    SizedBox(
                                        width: 8), // Space mellan text och ikon
                                    Icon(
                                      Iconsax.like_1,
                                      size: 24,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),

                              // Avböj lagkamp knapp
                              ElevatedButton(
                                onPressed: () {
                                  // Avböj lagkamp logik här
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Avböj',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                        width: 8), // space mellan text och ikon
                                    Icon(
                                      Iconsax.dislike,
                                      size: 24,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )

                    // om användaren har skickat challenge, visa detta
                    : (challengeSent
                        ? Text(
                            'Inväntar svar från lag $senderTeam',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Sora',
                            ),
                            textAlign: TextAlign.center,
                          )

                        // Om användaren inte har skickat challenge, och ingen challenge har blivit skickat till dem, visa detta:
                        : const Text(
                            'Inga aktiva inbjudningar eller förfrågningar',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Sora',
                            ),
                            textAlign: TextAlign.center,
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
