import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelhelper/FirebaseServices/GroupServices.dart';
import 'package:travelhelper/UI/Pages/HomePage.dart';
import 'package:travelhelper/widgets/buildTextFeild.dart';
import 'package:travelhelper/widgets/customButton.dart';

class MakeNewGroupPage extends StatefulWidget {
  const MakeNewGroupPage({super.key});

  @override
  State<MakeNewGroupPage> createState() => _MakeNewGroupPageState();
}

class _MakeNewGroupPageState extends State<MakeNewGroupPage> {
  TextEditingController _groupName = TextEditingController();
  // List<String> selectedUserIds = [];
  List<Map<String, String>> selectedUsers = [];
  List<String> memberIds = [];
  bool isLoading = false;
  String? _uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> handleCreateGroup() async {
    setState(() => isLoading = true);

    try {
      await Groupservices.createGroup(
        name: _groupName.text.trim(),
        createdBy: _uid ?? "Null",
        members: selectedUsers,
        memberIds: memberIds,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Group Created')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Failed to create group')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Make New Group"), centerTitle: true),
        body: Column(
          children: [
            // Search Members
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: buildTextField(
                _groupName,
                'Group Name',
                Icons.group_add_outlined,
              ),
            ),

            SizedBox(height: 10),

            // Members With
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No users found"));
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      final isSelected = selectedUsers.any(
                        (u) => u['uid'] == user['uid'],
                      );

                      return _customCheckBox(
                        name: user['name'] ?? "NO Name",
                        value: isSelected,
                        onChanged: (bool? isChecked) {
                          setState(() {
                            if (isChecked == true) {
                              // Add if not already selected
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
                              // Remove by uid
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
              child: Center(
                child:
                    isLoading
                        ? CircularProgressIndicator()
                        : customButton("Create Group", () async {
                          setState(() => isLoading = true); // Optional safety
                          await handleCreateGroup(); // ✅ Call it
                          setState(() => isLoading = false); // Optional

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        }),
              ),
            ),
          ],
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
