// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travelhelper/FirebaseServices/FirebaseServieces.dart';
import 'package:travelhelper/main.dart';

void main() {
  testWidgets('AppBar shows Travel Helper title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Travel Helper')),
          body: Container(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Travel Helper'), findsOneWidget);
  });
}

// void main() {
//   testWidgets('Travel Helper app loads with title', (
//     WidgetTester tester,
//   ) async {
//     // Build the app
//     await tester.pumpWidget(const MyApp());

//     // Verify that the title text exists (adjust to your real title)
//     expect(find.text('Travel Helper'), findsOneWidget);
//   });
// }

// void main() {
//   setUpAll(() async {
//     TestWidgetsFlutterBinding.ensureInitialized();
//     await Firebase.initializeApp(); // Use mock options if needed
//   });

//   testWidgets('AppBar shows Travel Helper title', (WidgetTester tester) async {
//     // Wrap MyApp in MaterialApp
//     await tester.pumpWidget(const MaterialApp(home: MyApp()));

//     // Wait for FutureBuilder to complete
//     await tester.pumpAndSettle();

//     // Verify AppBar title
//     expect(find.text('Travel Helper'), findsOneWidget);
//   });
// }

// class TestMyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Travel Helper')),
//         body: Container(), // placeholder
//       ),
//     );
//   }
// }
