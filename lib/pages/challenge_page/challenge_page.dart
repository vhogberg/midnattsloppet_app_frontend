import 'package:flutter/material.dart';
import 'package:flutter_application/pages/homepage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_application/pages/navigation_bar/navigation_bar.dart';
import 'package:flutter_application/components/custom_app_bar.dart';

class ChallengePage extends StatelessWidget {
  String test2 = 'test';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: null,
        title: 'Lagkamp',
        // lagkampssidan ska inte ha någon ActionButton till höger, så detta nedan sätts "false"
        useActionButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'images/CompetitionImage.png',
              fit: BoxFit.fitWidth,
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Sök upp lag att utmana...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '1. Sök upp ett lag som ni vill starta lagkamp emot',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '2. Skicka iväg utmaningen och invänta svar från det andra laget',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
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
            Stack(
              children: [
                Container(
                  width: 400,
                  height: 65,
                  decoration: BoxDecoration(
                    color: const Color(0XFF3C4785),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                Positioned(
                  top: 5,
                  left: 10,
                  right: 10,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/fire.png',
                          width: 35,
                          height: 35,
                        ),
                        SizedBox(width: 15),
                        const Text(
                          'Skicka iväg utmaningen!',
                          style: TextStyle(
                            color: Colors.white,
                            
                            fontSize: 22,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                        SizedBox(width: 15),
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
          ],
        ),
      ),
      bottomNavigationBar: const MyNavigationBar(),
    );
  }
}
