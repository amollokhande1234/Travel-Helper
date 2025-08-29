import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelhelper/FirebaseServices/FirebaseServieces.dart';
import 'package:travelhelper/FirebaseServices/GroupServices.dart';
import 'package:travelhelper/Group/ChatPage.dart';
import 'package:travelhelper/Group/MakeNewGroupPage.dart';
import 'package:travelhelper/Satics/Colors.dart';
import 'package:travelhelper/widgets/buildTextFeild.dart';
import 'package:travelhelper/widgets/customGroupTile.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {



  @override
  Widget build(BuildContext context) {
    // print("Current UID: ${currentUid}");

    return Scaffold(
      body: Column(
        children: [
          // All Groups
          Expanded(
            child: StreamBuilder(
              stream:
                  fireStore
                      .collection('groups')
                      .where('memberIds', arrayContains: currentUid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No groups found."));
                }

                final docs = snapshot.data!.docs;
                // print(" 💀💀💀Docs: ${docs.map((d) => d.data()).toList()}");

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final groupName = data['name'] ?? 'No Name';

                    // final lastMessage = data['lastMessage'];
                    String lastText = 'No messages yet';

                    final groupId = docs[index].id;
                    return customGroupTile(
                      groupName: groupName,
                      backgroundColor: tileColors[index % tileColors.length],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChatPage(
                                  groupId: groupId,
                                  groupName: groupName,
                                ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _floatingActionButtom(),
    );
  }

  Widget _floatingActionButtom() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MakeNewGroupPage()),
        );
      },
      child: Icon(Icons.add),
    );
  }
}
