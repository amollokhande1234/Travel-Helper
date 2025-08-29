// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:travelhelper/Group/ChatPage.dart';

// // class NotificationServices {
// //   FirebaseMessaging messenging = FirebaseMessaging.instance;
// //   void firebaseInit() {
// //     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
// //       if (message.notification != null) {
// //         print("📩 Title: ${message.notification!.title}");
// //         print("📝 Body: ${message.notification!.body}");
// //       }
// //     });
// //   }

// //   // Permission Request
// //   void requestNotificationPermission() async {
// //     NotificationSettings settings = await messenging.requestPermission(
// //       alert: true,
// //       announcement: true,
// //       badge: true,
// //       carPlay: true,
// //       criticalAlert: true,
// //       provisional: true,
// //       sound: true,
// //     );

// //     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
// //       print("User granted Permissio");
// //     } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
// //       print("User granted provisional permission");
// //     } else {
// //       print("declined");
// //     }
// //   }

// //   // Device Token
// //   Future<String> getDeviceToken() async {
// //     try {
// //       String? token = await FirebaseMessaging.instance.getToken();
// //       if (token != null) {
// //         print("✅ Device Token: $token");
// //         return token;
// //       } else {
// //         print("❌ Device token is null");
// //         return "Token not available";
// //       }
// //     } catch (e) {
// //       print("❌ Error getting device token: $e");
// //       return "Error";
// //     }
// //   }
// // }

// class NotificationService {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _local =
//       FlutterLocalNotificationsPlugin();

//   Future<void> init() async {
//     await _requestPermission();
//     await _initLocalNotification();
//     _getFCMToken();
//     _onMessageListener();
//   }

//   Future<void> _requestPermission() async {
//     await _messaging.requestPermission();
//   }

//   void _getFCMToken() async {
//     String? token = await _messaging.getToken();
//     print("FCM Token: $token");

//     // Save to Firestore if needed
//     await FirebaseFirestore.instance
//         .collection("users")
//         .doc("userId") // replace with current user id
//         .set({"token": token}, SetOptions(merge: true));
//   }

//   Future<void> _initLocalNotification() async {
//     const AndroidInitializationSettings androidInit =
//         AndroidInitializationSettings("@mipmap/ic_launcher");

//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidInit,
//     );
//     await _local.initialize(initSettings);
//   }

//   void _onMessageListener() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         _showLocalNotification(
//           message.notification!.title ?? "",
//           message.notification!.body ?? "",
//         );
//       }
//     });
//   }

//   void _showLocalNotification(String title, String body) {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//           "channelId",
//           "channelName",
//           importance: Importance.high,
//           priority: Priority.high,
//         );

//     const NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//     );

//     _local.show(0, title, body, details);
//   }
// }
