import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestMyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Travel Helper')),
        body: Center(child: Text('Test Body')),
      ),
    );
  }
}

void main() {
  testWidgets('AppBar shows Travel Helper title', (WidgetTester tester) async {
    await tester.pumpWidget(TestMyApp());
    await tester.pumpAndSettle();

    expect(find.text('Travel Helper'), findsOneWidget);
  });
}
