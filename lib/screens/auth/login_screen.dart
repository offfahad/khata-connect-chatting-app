import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_notifications/helpers/appLocalizations.dart';
import 'package:flutter_notifications/helpers/constants.dart';
import 'package:flutter_notifications/my_home_page.dart';
import 'package:flutter_notifications/providers/my_theme_provider.dart';
import 'package:flutter_notifications/providers/stateNotifier.dart';
import 'package:flutter_notifications/screens/userProfile/setup_profile.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../api/apis.dart';
import '../../helpers/dialogs.dart';
import '../../main.dart';
import '../messages/messages_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState(){
    super.initState();
    //await getTheLocale();
    //for auto triggering animation
    // Future.delayed(const Duration(milliseconds: 500), () {
    //   setState(() => _isAnimate = true);
    // });
  }

  // handles google login button click
  _handleGoogleBtnClick() {
    //for showing progress bar
    Dialogs.showLoading(context);

    _signInWithGoogle().then((user) async {
      //for hiding progress bar
      Navigator.pop(context);

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if (await APIs.userExists() && mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => MyHomePage()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => MyHomePage()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');

      if (mounted) {
        Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet!)');
      }

      return null;
    }
  }

  // Future<void> getTheLocale() async {
  //   await fetchLocale(context);
  // }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.sizeOf(context);
    final currentLocale = Provider.of<AppStateNotifier>(context).appLocale;
    final buttonText = currentLocale == 'en' ? 'اردو' : 'English';
    final themeStatus = Provider.of<MyThemeProvider>(context);

    return Scaffold(
      //body
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 24.0), // Add some horizontal padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(
                    buttonText,
                    style: TextStyle(fontSize: 18, color: themeStatus.themeType ? Colors.white : Colors.black,),
                    
                  ),
                  onPressed: () async {
                    final newLocale = currentLocale == 'en' ? 'ur' : 'en';
                    await changeLanguage(context, newLocale);
                    setState(() {});
                  },
                ),
                IconButton(
                    onPressed: () {
                      themeStatus.setTheme = !themeStatus.themeType;
                    },
                    icon: Icon(themeStatus.themeType
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined))
              ],
            ),
            SizedBox(
              height: mq.height * .04,
            ),
            // App logo
            Image.asset(
              'assets/images/logo2.png',
              width: mq.width * .9, // Adjust the width to make the logo smaller
            ),
            //const SizedBox(height: 30), // Add space between logo and title
            SizedBox(
              height: mq.height * .07,
            ),
            // Title
            Text(
              AppLocalizations.of(context)!.translate('welcomeTitle'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // Add space between title and subtitle

            // Subtitle
            Text(
              AppLocalizations.of(context)!.translate('WeclomeSubtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            SizedBox(
              height: mq.height * .2,
            ),
            // Google login button
            // ElevatedButton.icon(
            //   style: ElevatedButton.styleFrom(
            //     minimumSize: const Size.fromHeight(50),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12.0),
            //     ),
            //   ),

            //   // On tap
            //   onPressed: _handleGoogleBtnClick,

            //   // Google icon
            //   icon: Image.asset(
            //     'assets/images/google.png',
            //     height: mq.height * .04,
            //   ),

            //   // Login with Google label
            //   label: RichText(
            //     text: TextSpan(
            //       style: TextStyle(
            //         //color: Colors.black,
            //         fontSize: 16,
            //       ),
            //       children: [
            //         TextSpan(text:  AppLocalizations.of(context)!.translate('loginWith')),
            //         TextSpan(
            //             text: AppLocalizations.of(context)!.translate('google'),
            //             style: const TextStyle(fontWeight: FontWeight.w500)),
            //       ],
            //     ),
            //   ),
            // ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),

              // On tap
              onPressed: _handleGoogleBtnClick,

              // Google icon
              icon: Image.asset(
                'assets/images/google.png',
                height: mq.height * .04,
              ),

              // Login with Google label
              label: Text(
                AppLocalizations.of(context)!.translate('loginWithGoogle'),
                style: TextStyle(
                  fontSize: 16,
                  color: themeStatus.themeType ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 30), // Add some space at the bottom
          ],
        ),
      ),
    );
  }
}
