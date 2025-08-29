import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:travelhelper/FirebaseServices/FirebaseServieces.dart';
import 'package:travelhelper/FirebaseServices/Notification.dart';
import 'package:travelhelper/UI/Auth/loginScreen.dart';
import 'package:travelhelper/UI/Pages/HomePage.dart';
import 'package:travelhelper/UI/splashScreen.dart';

// NotificationService notificationServices = NotificationService();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // NotificationService notificationService = NotificationService();
  // await notificationService.init();
  runApp(MyApp());

  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<bool> isSignedInOrNot() async {
    return await auth.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: isSignedInOrNot(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(); // or a loading spinner
          } else if (snapshot.hasData && snapshot.data == true) {
            return HomePage();
          } else {
            return LoginPage(); // or any auth screen
          }
        },
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   Future<bool> isSignedInOrNot() async {
//     return await auth.currentUser != null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: FutureBuilder<bool>(
//         future: isSignedInOrNot(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return SplashScreen();
//           } else if (snapshot.hasData && snapshot.data == true) {
//             return HomePage();
//           } else {
//             return LoginPage();
//           }
//         },
//       ),
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light(),
//     );
//   }
// }
