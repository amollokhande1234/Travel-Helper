import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelhelper/FirebaseServices/FirebaseServieces.dart';
import 'package:travelhelper/ExpenseSplitter/ExpensePage.dart';
import 'package:travelhelper/widgets/buildTextFeild.dart';
import 'package:travelhelper/widgets/customButton.dart';

class SplitPage extends StatefulWidget {
  String? amount;
  String groupId;
  SplitPage({super.key, this.amount, required this.groupId});

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  List<Map<String, String>> selectedUsers = [];
  List<String> memberIds = [];
  TextEditingController _amountController = TextEditingController();
  TextEditingController _messageController = TextEditingController();

  static String currentUserName = '';

  @override
  void initState() {
    super.initState();
    loadCurrentUserName(); // 👈 this must be called
  }

  // Load current user's name from Firestore
  static Future<void> loadCurrentUserName() async {
    try {
      final doc = await fireStore.collection('users').doc(currentUid).get();
      if (doc.exists) {
        currentUserName = doc['name'] ?? 'No Name';
        // print("User name loaded: $currentUserName");
      } else {
        // print("User document not found for uid: $currentUid");
      }
    } catch (e) {
      print("Error loading user name: $e");
    }
  }

  Future<String?> getUpiIdByUid(String uid) async {
    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        return data?['upiId']; // returns null if not found
      } else {
        print("User not found");
        return null;
      }
    } catch (e) {
      print("Error fetching UPI ID: $e");
      return null;
    }
  }

  Future<void> splitExpense({
    required String groupId,
    required double totalAmount,
    required String paidByUid,
    required String sender,
    String? message,
    required List<Map<String, String>> selectedMembers, // uid & name
  }) async {
    final firestore = FirebaseFirestore.instance;

    double individualAmount = totalAmount / selectedMembers.length;
    int splittedAmount = individualAmount.round();

    List<Map<String, dynamic>> memberData =
        selectedMembers.map((member) {
          return {
            'uid': member['uid'],
            'name': member['name'],
            'amount': splittedAmount,
            'isPaid': member['uid'] == paidByUid, // true if payer
          };
        }).toList();

    final expenseRef =
        firestore
            .collection('groups')
            .doc(groupId)
            .collection('expenses')
            .doc(); // auto ID

    await expenseRef.set({
      'expenseId': expenseRef.id, // store the generated ID inside the document
      'amount': totalAmount,
      'paidBy': paidByUid,
      // 'upiId': getUpiIdByUid(paidByUid),
      'sender': sender,
      'message': message,
      'time': Timestamp.now(),
      'members': memberData,
    });
    print("Expense added successfully.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildTextField(
                  textInputType: TextInputType.number,
                  _amountController,
                  "Enter Amount",
                  Icons.attach_money_rounded,
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildTextField(
                  _messageController,
                  "Enter Message",
                  Icons.messenger_rounded,
                ),
              ),
              Divider(),

              Expanded(
                child: FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('groups')
                          .doc(widget.groupId)
                          .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: Text("No users found"));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final members = List<Map<String, dynamic>>.from(
                      data['members'] ?? [],
                    );

                    return ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final user = members[index];

                        final isSelected = selectedUsers.any(
                          (u) => u['uid'] == user['uid'],
                        );

                        return _customCheckBox(
                          name: user['name'] ?? "No Name",
                          value: isSelected,
                          onChanged: (bool? isChecked) {
                            setState(() {
                              if (isChecked == true) {
                                if (!selectedUsers.any(
                                  (u) => u['uid'] == user['uid'],
                                )) {
                                  selectedUsers.add({
                                    'uid': user['uid'],
                                    'name': user['name'],
                                  });
                                  memberIds.add(user['uid']);
                                }
                              } else {
                                selectedUsers.removeWhere(
                                  (u) => u['uid'] == user['uid'],
                                );
                                memberIds.remove(user['uid']);
                              }
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),

                child: customButton("Split Expense", () async {

                  if(_amountController.text != null) {
                    final amount = double.tryParse(
                        _amountController.text.trim());

                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid amount."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (selectedUsers.length == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Choose Users in Split"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // 🔁 Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (_) =>
                      const Center(child: CircularProgressIndicator()),
                    );

                    // 🔄 Wait for expense to be added
                    await splitExpense(
                      groupId: widget.groupId,
                      sender: currentUserName,
                      totalAmount: amount,
                      message: _messageController.text.trim(),
                      paidByUid: currentUid ?? "No User",

                      selectedMembers: selectedUsers,
                    );

                    // ✅ Dismiss loading
                    Navigator.pop(context); // closes the dialog

                    // ➡️ Navigate to SplitPage
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExpensePage(groupId: widget.groupId),
                      ),
                          (route) => false,
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customCheckBox({
    required String name,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        children: [
          CircleAvatar(child: Icon(Icons.person)),
          SizedBox(width: 18),
          Expanded(child: Text(name, style: TextStyle(fontSize: 16))),
          Checkbox(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
