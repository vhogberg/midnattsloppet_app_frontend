// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool useActionButton;
  final IconData? actionIcon;
  final Function()? onActionPressed;
  final bool showReturnArrow;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.useActionButton,
    this.actionIcon,
    this.onActionPressed,
    this.showReturnArrow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppBar(
        automaticallyImplyLeading:
            false, // tar bort standard-tillbaka knappen som medföljer AppBar
        elevation: 0,
        centerTitle: true, // centrera titeln
        title: Row(
          children: [
            // Visa endast tillbakapil om showReturnArrow är sann
            if (showReturnArrow)
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF4F4F4F), // färg för pilen
                  size: 30,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            else
              const SizedBox(
                  width:
                      48), // Kompensera för saknat avstånd om pilen inte visas
      
            const SizedBox(width: 8), // Padding
            Expanded(
              // titelns egenskaper
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF4F4F4F),
                ),
              ),
            ),
      
            // Den andra knappen till högers implementation nedan
            // Om ActionButton ska användas:
            if (useActionButton)
              if (actionIcon != null && onActionPressed != null)
                IconButton(
                  icon: Icon(
                    actionIcon,
                    size: 30,
                    color: actionIcon != null
                        ? const Color(0xFF4F4F4F)
                        : Colors.transparent,
                  ),
                  onPressed: onActionPressed,
                ),
      
            // Om ActionButton inte ska användas görs den osynlig
            if (!useActionButton)
              IconButton(
                icon: Icon(
                  actionIcon,
                  color: actionIcon != null
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : const Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: onActionPressed,
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  // appbar klass kräver preferredSize sätts
  // preferred size (100) är padding till komponenter under app bar
  @override
  Size get preferredSize => const Size.fromHeight(50);
}

/**
 * Har skapat en appbar som följer stilen i Figma, och har gjort den till en component så att den kan återanvändas enklare. 
 * Som standard har den en titel och en tillbaka knapp på vänster sida. 
 * Sedan kan den kallas med en ytterligare "actionIcon" i de fall i Figma där det behövs en knapp på höger sida av appbar också.

Använda appbar:

1. Importera den i toppen av filen:
import 'package:flutter_application/components/custom_app_bar.dart';

2. Använd den genom att kalla på appBar: CustomAppBar(),

3. Fyll i det som behövs:
- key: null
- titel: 'textsträng'
- useActionButton: fyll i true/false beroende på om actionbutton behövs
- actionIcon: Detta är en alternativ ikon till höger, används när den behövs (useActionButton måste vara true)
- onActionPressed: Funktionalitet till actionIcon (useActionButton måste vara true)

Exempel:

appBar: CustomAppBar(
        key: null,
        title: 'Lagkamp',
        useActionButton: true,
        actionIcon: Iconsax.medal_star5,       
        onActionPressed: () {
            print('Action button pressed!');
          },
      ),
 * 
 * Exempel finns också i challenge_page där denna är implementerad!
 */