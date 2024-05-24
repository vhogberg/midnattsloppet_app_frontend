import 'package:flutter/material.dart';

// importeras i filer på detta sätt: import 'package:flutter_application/components/dialog_utils.dart';

class DialogUtils {
  // kallas på detta sätt: DialogUtils.showGenericErrorMessage(context, 'Fel', 'Du måste välja ett lag!');
  static void showGenericErrorMessage(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // textfärg
                backgroundColor: const Color(0XFF3C4785), // knappfärg
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Ok',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Sora',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // fler metoder om behövs...

  void showGenericErrorMessageNonStatic(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // textfärg
                backgroundColor: const Color(0XFF3C4785), // knappfärg
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Ok',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Sora',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
