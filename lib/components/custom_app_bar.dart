import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool useActionButton;
  final IconData? actionIcon;
  final Function()? onActionPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.useActionButton,
    this.actionIcon,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(top: 50), // padding i topp
        child: AppBar(
          automaticallyImplyLeading:
              false, // tar bort standard-tillbaka knappen som medföljer AppBar
          elevation: 0,
          centerTitle: true, // centrera titeln
          title: Row(
            children: [
              // IconButton är tillbaka-pilen till vänster om titeln
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF4F4F4F),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 8), // Padding
              Expanded(
                // titelns egenskaper
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                      color: actionIcon != null
                          ? Color(0xFF4F4F4F)
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
                        ? Color.fromARGB(255, 255, 255, 255)
                        : Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: onActionPressed,
                ),
            ],
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  // appbar klass kräver preferredSize sätts
  // preferred size (100) är padding till komponenter under app bar
  @override
  Size get preferredSize => const Size.fromHeight(100);
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