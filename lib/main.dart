import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notifications/myTheme.dart';
import 'package:flutter_notifications/providers/my_theme_provider.dart';
import 'package:flutter_notifications/services/local_notification_service.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/splashscreen/splash_screen.dart';

//global object for accessing device screen size
late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await _initializeFirebase();
  await LocalNotificationService().init();

  //for setting orientation to portrait only
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MyThemeProvider>(
            create: (context) => MyThemeProvider()..getThemeStatus(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Khata Connect',
          debugShowCheckedModeBanner: false,
          theme: MyTheme.themeData(
            isDarkTheme: themeProvider.themeType,
            context: context,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
    
  );

  log('\nNotification Channel Result: $result');
}
