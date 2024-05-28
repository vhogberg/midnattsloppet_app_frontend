// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/components/custom_colors.dart';


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
                backgroundColor: CustomColors.midnattsblue, // knappfärg
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
                backgroundColor: CustomColors.midnattsblue, // knappfärg
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

  // New method to show sign out dialog
  static void showSignOutDialog(BuildContext context) {
    NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Bekräfta logga ut',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9, // Dynamic width
            child: const Text(
              'Är du säker att du vill logga ut?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Sora',
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // textfärg
                    backgroundColor: CustomColors.midnattsblue, // knappfärg
                  ),
                  onPressed: () {
                    navigator.pop();
                  },
                  child: const Text(
                    'Avbryt',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sora',
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // textfärg
                    backgroundColor: CustomColors.midnattsblue, // knappfärg
                  ),
                  onPressed: () async {
                    navigator.pop();
                    Future.delayed(const Duration(milliseconds: 100), () async {
                      bool signOutSuccess =
                          await SessionManager.instance.signUserOut();
                      if (signOutSuccess) {
                        navigator.pushNamedAndRemoveUntil(
                            '/', (route) => false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to sign out'),
                          ),
                        );
                      }
                    });
                  },
                  child: const Text(
                    'Logga ut',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sora',
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // New method to show a customizable confirmation dialog
  static Future<String?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    return showDialog<String>(
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
          content: SizedBox(
            width: 300,
            child: Text(
              description,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Sora',
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // textfärg
                    backgroundColor: CustomColors.midnattsblue, // knappfärg
                  ),
                  onPressed: () {
                    Navigator.of(context).pop('no');
                  },
                  child: const Text(
                    'Avbryt',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sora',
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // textfärg
                    backgroundColor: CustomColors.midnattsblue, // knappfärg
                  ),
                  onPressed: () {
                    Navigator.of(context).pop('yes');
                  },
                  child: const Text(
                    'Ja',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sora',
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // New method to show a customizable confirmation dialog
  static Future<String?> showInformationDialog({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // man ska inte kunna trycka på utsidan.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
          content: SizedBox(
            width: 300,
            child: Text(
              description,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Sora',
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // textfärg
                    backgroundColor: CustomColors.midnattsblue, // knappfärg
                  ),
                  onPressed: () {
                    Navigator.of(context).pop('yes');
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
            ),
          ],
        );
      },
    );
  }

}
