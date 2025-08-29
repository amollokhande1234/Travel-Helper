import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travelhelper/FirebaseServices/FirebaseServieces.dart';
import 'package:travelhelper/ExpenseSplitter/EachExpensePage.dart';
import 'package:travelhelper/ExpenseSplitter/SplitPage.dart';
import 'package:travelhelper/widgets/customButton.dart';
import 'package:travelhelper/widgets/customGroupTile.dart';

class ExpensePage extends StatefulWidget {
  String groupId;
  ExpensePage({super.key, required this.groupId});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  Future<String> _getUserNameByUid(String uid) async {
    try {
      final doc = await fireStore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['name'] ?? 'No Name';
      } else {
        return 'User not found';
      }
    } catch (e) {
      print('Error getting user name: $e');
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      appBar: AppBar(

        backgroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All Expenses', style: TextStyle(color: Colors.black)),
            // Text(style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new), // Change this to any icon you like
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
        // actions: const [
        //   Icon(Icons.receipt_long_outlined, color: Colors.black),
        //   SizedBox(width: 12),
        //   Icon(Icons.more_vert, color: Colors.black),
        //   SizedBox(width: 8),
        // ],
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  fireStore
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('expenses')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No expenses found."));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return FutureBuilder<String>(
                      future: _getUserNameByUid(data['paidBy']),
                      builder: (context, userSnapshot) {
                        final senderName = userSnapshot.data ?? "Loading...";

                        return _customExpenseTile(
                          sender: data['sender'] ?? "No Name",
                          message: data['message'] ?? "No Message",
                          amount: data['amount'].toString(),
                          showDate: data['time'], // should be Timestamp
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EachExpensePage(
                                      expenseId: data['expenseId'],
                                      amount: data['amount'].toString(),
                                      message: data['message'] ?? "No Message",
                                      sender: data['paidBy'] ?? "NA",
                                      groupId: widget.groupId,
                                      dividedAmount:
                                          data['members'][0]['amount']
                                              .toString(),
                                      senderName: data['sender'] ?? "NA",
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: customButton("Split Expense", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SplitPage(groupId: widget.groupId),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _customExpenseTile({
    required String sender,
    required String amount,
    required String message,
    required dynamic showDate,
    VoidCallback? onTap,
  }) {
    DateTime dateTime;
    if (showDate is String) {
      // Try to parse if it's a string
      dateTime = DateTime.tryParse(showDate) ?? DateTime.now();
    } else if (showDate != null && showDate is! DateTime) {
      // Assume it's a Timestamp (from Firestore)
      dateTime = showDate.toDate();
    } else if (showDate is DateTime) {
      dateTime = showDate;
    } else {
      dateTime = DateTime.now();
    }
    final String time = DateFormat('hh:mm a').format(dateTime);
    final String date = DateFormat('dd MMM yyyy').format(dateTime);

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDate != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ),

          Container(
            margin: const EdgeInsets.only(left: 40),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      sender,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 5),
                    Text("-"),
                    SizedBox(width: 5),
                    Text(
                      message,
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
                Text(
                  "\$ ${amount}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                    fontSize: 25,
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
