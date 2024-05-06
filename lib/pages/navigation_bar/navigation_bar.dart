import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_application/pages/homepage.dart';
import 'package:flutter_application/pages/searchpage.dart';
import 'package:flutter_application/pages/myteampage.dart';
//import 'package:flutter_application/pages/examplepage1.dart';
//import 'package:flutter_application/pages/examplepage2.dart';
//import 'package:flutter_application/pages/examplepage3.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({super.key});
  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<MyNavigationBar> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    Container(), //ExamplePage1(),
    Container(), //ExamplePage2(),
    const MyTeamPage(),
  ];

  final double _iconSize = 36.0;
  final Uri _url = Uri.parse('https://group-15-7.pvt.dsv.su.se/app/donate');

  List<IconData> _pageIcons = [
    Iconsax.home_2,
    Iconsax.medal_star,
    Iconsax.receipt_item,
    Iconsax.smileys,
  ];

  List<Text> _pageNames = [
    const Text("Hem",
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
        )),
    const Text("Lagkamp",
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
        )),
    const Text("Topplista",
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
        )),
    const Text("Mitt lag",
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
        )),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 120,
          padding:
              const EdgeInsets.only(bottom: 24.0, left: 32, right: 32, top: 20),
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: () => _selectPage(0),
                          icon: Icon(
                            _pageIcons[0],
                            size: _iconSize,
                          ),
                        ),
                        _pageNames[0],
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () => _selectPage(1),
                          icon: Icon(
                            _pageIcons[1],
                            size: _iconSize,
                          ),
                        ),
                        _pageNames[1],
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: () => _selectPage(2),
                          icon: Icon(
                            _pageIcons[2],
                            size: _iconSize,
                          ),
                        ),
                        _pageNames[2],
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () => _selectPage(3),
                          icon: Icon(
                            _pageIcons[3],
                            size: _iconSize,
                          ),
                        ),
                        _pageNames[3],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width / 2 - 50,
          child: GestureDetector(
            onTap: () async {
              if (!await launchUrl(_url)) {
                throw Exception('Could not launch $_url');
              }
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0XFF3C4785),
                  width: 6,
                ),
              ),
              child: const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('images/swishlogo2.jpg.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectPage(int index) {
    setState(() {
      _currentIndex = index;
      _updateIcons();
      _updateNames();
    });
  }

  void _updateIcons() {
    _pageIcons = [
      Iconsax.home_2,
      Iconsax.medal_star,
      Iconsax.receipt_item,
      Iconsax.smileys,
    ];

    switch (_currentIndex) {
      case 0:
        _pageIcons[0] = Iconsax.home_25;
        break;
      case 1:
        _pageIcons[1] = Iconsax.medal_star5;
        break;
      case 2:
        _pageIcons[2] = Iconsax.receipt_item5;
        break;
      case 3:
        _pageIcons[3] = Iconsax.smileys5;
        break;
    }
  }

  void _updateNames() {
    _pageNames = [
      const Text("Hem",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
          )),
      const Text("Lagkamp",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
          )),
      const Text("Topplista",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
          )),
      const Text("Mitt lag",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
          )),
    ];

    switch (_currentIndex) {
      case 0:
        _pageNames[0] = const Text("Hem",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ));
        break;
      case 1:
        _pageNames[1] = const Text("Lagkamp",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ));
        break;
      case 2:
        _pageNames[2] = const Text("Topplista",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ));
        break;
      case 3:
        _pageNames[3] = const Text("Mitt lag",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ));
        break;
    }
  }

  void _goToSearchPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );
  }
    void _goToMyTeamPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyTeamPage()),
    );
  }
}
