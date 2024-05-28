// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/components/custom_colors.dart';
import 'package:flutter_application/components/custom_navigation_bar.dart';
import 'package:flutter_application/components/dialog_utils.dart';
import 'package:flutter_application/components/search_popup.dart';
import 'package:flutter_application/models/registration.dart';

class RegistrationWizardDialog extends StatefulWidget {
  @override
  _RegistrationWizardDialogState createState() =>
      _RegistrationWizardDialogState();
}

class _RegistrationWizardDialogState extends State<RegistrationWizardDialog> {
  int _currentPage = 0;
  bool newTeam = false;
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final companyVoucherCodeController = TextEditingController();
  final teamNameController = TextEditingController();
  final charityController = TextEditingController();
  final donationGoalController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<String> teams = [];
  List<String> filteredTeams = [];
  List<String> charities = [];
  List<String> filteredCharities = [];
  String? selectedTeam;
  String? selectedCharity;
  String? companyName;
  String? username;

  @override
  void initState() {
    super.initState();
  }

  bool isValidEmail(String email) {
    // Define the email pattern
    String emailRegex = r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$';
    RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }

  Future<void> initialize() async {
    await fetchCompanyName();
    if (companyName != null) {
      await fetchTeams();
      filteredTeams.addAll(teams);
    }
    await fetchCharities();
    filteredCharities.addAll(charities);
  }

  Future<void> fetchCompanyName() async {
    String voucherCode = companyVoucherCodeController.text;
    try {
      companyName = await ApiUtils.getCompanyNameByVoucherCode(voucherCode);
    } catch (e) {
      print('Failed to fetch company name: $e');
    }
  }

  Future<void> fetchTeams() async {
    if (companyName != null) {
      try {
        teams = await ApiUtils.fetchTeamsByCompany(companyName!);
      } catch (e) {
        print('Failed to fetch teams: $e');
      }
    }
  }

  void filterSearchResults(String query) {
    setState(() {
      filteredTeams = teams
          .where((team) => team.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> fetchCharities() async {
    try {
      final data = await ApiUtils.fetchCharities();
      setState(() {
        charities = data;
        filteredCharities.addAll(charities);
      });
    } catch (e) {
      print('Failed to fetch entities: $e');
    }
  }

  void filterCharitySearchResults(String query) {
    List<String> searchResults = [];
    if (query.isNotEmpty) {
      for (String charity in charities) {
        if (charity.toLowerCase().contains(query.toLowerCase())) {
          searchResults.add(charity);
        }
      }
    } else {
      searchResults.addAll(charities);
    }
    setState(() {
      filteredCharities = searchResults;
    });
  }

  // hantera wizard steg
  void _nextPage() async {
    if (_currentPage == 0) {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        DialogUtils().showGenericErrorMessageNonStatic(
            context, "Fel", 'Vänligen ange både e-postadress och lösenord.');
        return;
      }

      if (!isValidEmail(emailController.text)) {
        DialogUtils().showGenericErrorMessageNonStatic(
            context, "Fel", 'Vänligen ange en giltig e-postadress.');
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        DialogUtils().showGenericErrorMessageNonStatic(
            context, "Fel", 'Lösenorden matchar inte.');
        return;
      }

      bool userExists = await ApiUtils.doesUserExist(emailController.text);
      if (userExists) {
        DialogUtils().showGenericErrorMessageNonStatic(
            context, "Fel", "E-postadressen är redan kopplat till ett konto.");
        return;
      }

      username = emailController.text;
    }

    if (_currentPage == 1) {
      if (nameController.text.isEmpty ||
          companyVoucherCodeController.text.isEmpty) {
        DialogUtils().showGenericErrorMessageNonStatic(context, "Fel",
            "Vänligen ange ett användarnamn och företagskod för att fortsätta.");
        return;
      }

      companyName = await ApiUtils.getCompanyNameByVoucherCode(
          companyVoucherCodeController.text);
      if (companyName == null) {
        DialogUtils().showGenericErrorMessageNonStatic(
            context, "Fel", "Ingen företag hittades för den här koden.");
        return;
      }
      await initialize();
    }

    if (_currentPage == 2) {
      if (searchController.text.isEmpty) {
        DialogUtils().showGenericErrorMessageNonStatic(context, "Fel",
            "Vänligen välj ett lag eller skapa ett nytt för att fortsätta.");
        return;
      }

      setState(() {
        FocusManager.instance.primaryFocus?.unfocus();
        _currentPage = 4; // Navigate directly to the overview page
      });
      return;
    }

    if (_currentPage == 3) {
      if (teamNameController.text.isEmpty ||
          charityController.text.isEmpty ||
          donationGoalController.text.isEmpty) {
        DialogUtils().showGenericErrorMessageNonStatic(context, "Fel",
            "Vänligen fyll i alla uppgifter för att fortsätta.");
        return;
      }
      bool teamNameExists =
          await ApiUtils.doesTeamNameExist(teamNameController.text);
      if (teamNameExists) {
        DialogUtils().showGenericErrorMessageNonStatic(
            context, "Fel", "Lagnamnet är upptaget.");
        return;
      }
      FocusManager.instance.primaryFocus?.unfocus();
      newTeam = true;
    }

    setState(() {
      if (_currentPage < 4) {
        _currentPage++;
      }
    });
  }

  void _previousPage() {
    setState(() {
      if (_currentPage == 4) {
        // If we're on the overview page, go back to the team selection page (2)
        _currentPage = 2;
      } else if (_currentPage == 3) {
        // If we're on the create team page, go back to the team selection page (2)
        _currentPage = 2;
      } else if (_currentPage > 0) {
        // Otherwise, go back to the previous page
        _currentPage--;
      }
    });
  }

  void _handleGoBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8 + 60, // bredd på wizard
        height: MediaQuery.of(context).size.height * 0.53, // höjd på wizard
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentPage,
                children: [
                  _buildRegisterAccountPage(),
                  _buildCompleteProfilePage(),
                  _buildRegisterTeamPage(),
                  _buildCreateTeamPage(),
                  _buildOverviewPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, left: 20.0, right: 20, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage == 0)
                    ElevatedButton(
                      onPressed: _handleGoBack,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: Colors.grey, // knappfärg
                      ),
                      child: const Text('Tillbaka'),
                    ),
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: _previousPage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: Colors.grey, // knappfärg
                      ),
                      child: const Text('Tillbaka'),
                    ),
                  if (_currentPage < 4)
                    const Spacer(), // Spacer så att "nästa"-knappen alltid är på höger sida.
                  if (_currentPage < 3)
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: CustomColors.midnattsblue, // knappfärg
                      ),
                      child: const Text('Nästa'),
                    ),

                  if (_currentPage == 3)
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: CustomColors.midnattsblue, // knappfärg
                      ),
                      child: const Text('Nästa'),
                    ),
                  if (_currentPage == 4)
                    ElevatedButton(
                      onPressed: _onSend,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: Colors.green, // knappfärg
                      ),
                      child: const Text('Slutför'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wizard steg 1, sök efter ett lag.
  Widget _buildRegisterAccountPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10.0, left: 20, right: 20, bottom: 10),
          child: Text(
            '1. Skapa konto:',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              hintText: 'E-postadress',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              hintText: 'Lösenord',
              border: OutlineInputBorder(),
            ),
            obscureText: true, // To hide the password input
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: confirmPasswordController,
            decoration: const InputDecoration(
              hintText: 'Bekräfta lösenord',
              border: OutlineInputBorder(),
            ),
            obscureText: true, // To hide the password input
          ),
        ),
      ],
    );
  }

  // Wizard steg 2, färdigställa din profil
  Widget _buildCompleteProfilePage() {
    return Padding(
      padding:
          const EdgeInsets.only(top: 10, bottom: 20.0, left: 20, right: 20),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Text(
              '2. Färdigställ din profil',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Sora',
              ),
            ),
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Användarnamn',
              border: OutlineInputBorder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextField(
              controller: companyVoucherCodeController,
              decoration: const InputDecoration(
                hintText: 'Företagskod',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Wizard steg 3, välj eller skapa nytt lag
  Widget _buildRegisterTeamPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 15),
          child: Text(
            '3. Välj ett befintligt lag eller skapa ett nytt',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              filterSearchResults(value);
            },
            onTap: () async {
              String? selectedValue = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SearchPopup(
                    filteredEntities: filteredTeams,
                    hintText: 'Välj ett lag',
                  );
                },
              );
              if (selectedValue != null) {
                setState(() {
                  searchController.text = selectedValue;
                });
              }
            },
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
              hintText: 'Välj ett lag att ansluta till',
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              20.0, 20.0, 20.0, 0), // Adjusted top padding for more space
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentPage = 3; // Navigate to _buildCreateTeamPage
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: CustomColors.midnattsblue,
                ),
                child: const Text('Skapa ett nytt lag'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Wizard steg 4
  Widget _buildCreateTeamPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 10),
          child: Text(
            '4. Skapa ett nytt lag',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: teamNameController,
            decoration: const InputDecoration(
              hintText: 'Vänligen ange ett lagnamn',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: TextField(
            controller: charityController,
            onChanged: (value) {
              filterSearchResults(value);
            },
            onTap: () async {
              String? selectedValue = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SearchPopup(
                    filteredEntities: filteredCharities,
                    hintText: 'Välj en välgörenhetsorganisation',
                  );
                },
              );
              if (selectedValue != null) {
                setState(() {
                  charityController.text = selectedValue;
                });
              }
            },
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
              hintText: 'Välj en välgörenhetsorganisation',
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: donationGoalController,
            decoration: const InputDecoration(
              hintText: 'Vänligen ange ett donationsmål i SEK',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Översikt',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildOverviewItem('E-mail:', emailController.text),
              const SizedBox(height: 10),
              _buildOverviewItem('Företag:', companyName ?? 'Inget företag'),
              const SizedBox(height: 10),
              _buildOverviewItem(
                  'Lag:', teamNameController.text + searchController.text),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  void _onSend() async {
    setState(() {
      isLoading = true;
    });

    // Collect the necessary data
    String username = emailController.text;
    String password = passwordController.text;
    String name = nameController.text;
    String voucherCode = companyVoucherCodeController.text;
    String teamName;
    if (newTeam == true) {
      teamName = teamNameController.text;
    } else {
      teamName = searchController.text;
    }
    String charityName = charityController.text;
    String donationGoal = donationGoalController.text.trim().replaceAll(' ', '');

    // Create the registration request object
    RegistrationRequest request = RegistrationRequest(
      username: username,
      password: password,
      name: name,
      voucherCode: voucherCode,
      teamName: teamName,
      charityName: charityName,
      donationGoal: donationGoal,
      createNewTeam: newTeam,
    );

    try {
      // Send the request
      final response = await ApiUtils.post(
        'https://group-15-7.pvt.dsv.su.se/app/registerUser',
        request.toJson(),
      );

      // Handle the registration response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // User registered successfully
        DialogUtils().showGenericErrorMessageNonStatic(
            context, "", "Registreringen lyckades.");

        // Log in the user
        await SessionManager.instance.loginUser(username, password).then((_) {
          // Navigate to the homepage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const CustomNavigationBar(selectedPage: 0)),
          );
        }).catchError((e) {
          // Handle login error
          DialogUtils().showGenericErrorMessageNonStatic(
              context, "Error", "Login failed: $e");
        });
      } else {
        // Show error message from the server
        DialogUtils()
            .showGenericErrorMessageNonStatic(context, "Error", response.body);
      }
    } catch (e) {
      // Handle any exceptions
      DialogUtils().showGenericErrorMessageNonStatic(
          context, "Error", "An error occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
