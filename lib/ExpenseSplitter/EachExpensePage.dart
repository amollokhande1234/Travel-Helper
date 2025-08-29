import 'package:flutter/material.dart';
import 'package:travelhelper/FirebaseServices/FirebaseServieces.dart';

import 'package:travelhelper/UPIServices/UpiPayment.dart';
import 'package:travelhelper/widgets/customButton.dart';

class EachExpensePage extends StatefulWidget {
  String amount;
  String groupId;
  String message;
  String expenseId;
  String sender;
  String senderName;
  String dividedAmount;

  EachExpensePage({
    super.key,
    required this.amount,
    required this.message,
    required this.groupId,
    required this.expenseId,
    required this.sender,
    required this.senderName,
    required this.dividedAmount,
  });

  @override
  State<EachExpensePage> createState() => _EachExpensePageState();
}

class _EachExpensePageState extends State<EachExpensePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          // AMol LOkhande
          widget.senderName,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black),
        actions: const [
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: summaryTile(
                      widget.amount,
                      widget.message,
                      Colors.greenAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expense list
          Expanded(
            child: StreamBuilder(
              stream:
                  fireStore
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('expenses')
                      .doc(widget.expenseId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text("Expense not found");
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final List members = data['members'] ?? [];
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index] as Map<String, dynamic>;
                    return expenseTile(
                      name: member['name'],
                      subtitle: member['isPaid'] ? "Paid": "Not Paid",
                      amount: member['amount'].toString(),
                      textcolor: member['isPaid'] ? Colors.green: Colors.red,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: customButton("Pay  : ${widget.dividedAmount} ", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UpiIntegration(
                            sender: widget.sender,
                            dividedAmount: widget.dividedAmount,
                            amount: widget.amount,
                          ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget summaryTile(String amount, String? label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            "\$${amount} ",
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label ?? "",
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget expenseTile({
    required String name,
    required String subtitle,
    required String amount,
    String? avatarText,
    String? imageUrl,
    Color? textcolor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading:
          imageUrl != null
              ? CircleAvatar(backgroundImage: NetworkImage(imageUrl))
              : CircleAvatar(
                backgroundColor: Colors.grey[700],
                child: Text(
                  avatarText ?? name[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
      title: Text(name, style: const TextStyle(color: Colors.black)),
      subtitle: Text(subtitle, style: TextStyle(color: textcolor)),
      trailing: Text(
        amount,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
