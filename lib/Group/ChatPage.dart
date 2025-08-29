import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'package:travelhelper/FirebaseServices/FirebaseServieces.dart';
import 'package:travelhelper/CloudStorage/CloudPhotoView.dart';
import 'package:travelhelper/CloudStorage/ImageUpload.dart';
import 'package:travelhelper/ExpenseSplitter/ExpensePage.dart';
import 'package:travelhelper/ExpenseSplitter/EachExpensePage.dart';
import 'package:travelhelper/widgets/buildTextFeild.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  const ChatPage({super.key, required this.groupId, required this.groupName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController sendMessageController = TextEditingController();

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

  void sendMessage() async {
    final text = sendMessageController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .add({
          'text': text,
          'senderId': currentUid,
          'senderName': currentUserName,
          'time': Timestamp.now(),
        });

    sendMessageController.clear();
  }

  FilePickerResult? _filePickerResult;
  void _openFilePicker(String groupId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ["jpg", "jpeg", "png", "mp4"],
      type: FileType.custom,
    );
    setState(() {
      _filePickerResult = result;
    });

    if (_filePickerResult != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => UploadImagePage(
                groupId: groupId,
                selectedFile: _filePickerResult!,
              ),
        ),
      );
    }
  }

  Widget buildMessageInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
        child: Row(
          children: [
            Expanded(
              child: buildTextField(
                sendMessageController,
                "Type a message...",
                Icons.message,
              ),
            ),
            IconButton(
              onPressed: () {
                // var status = await Permission.storage.status;
                // if (!status.isGranted) {
                //   status = await Permission.storage.request();
                // } else {
                //   _openFilePicker(widget.groupId);
                // }

                setState(() {
                  // print("💀💀💀💀${widget.groupId}");
                  _openFilePicker(widget.groupId);
                });
              },
              iconSize: 35,
              icon: Icon(Icons.add),
            ),
            // SizedBox(width: 8),
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.green,
              child: IconButton(
                icon: Icon(Icons.send_rounded, color: Colors.white),
                onPressed: sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cloud Storage
  ///////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new), // Change this to any icon you like
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
        title: Text(widget.groupName,style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpensePage(groupId: widget.groupId),
                  ),
                );
              },
              icon: Icon(Icons.splitscreen_rounded),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CloudPhotoView(groupId: widget.groupId),
                  ),
                );
              },
              icon: Icon(Icons.cloud_circle_rounded),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          Expanded(child: MessagesList(groupId: widget.groupId)),
          buildMessageInput(),
        ],
      ),
    );
  }
}

class MessagesList extends StatefulWidget {
  final String groupId;

  const MessagesList({required this.groupId, Key? key}) : super(key: key);

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('groups')
              .doc(widget.groupId)
              .collection('messages')
              .orderBy('time', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No messages yet."));
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            try {
              final data = messages[index].data() as Map<String, dynamic>;

              final text = data['text']?.toString() ?? 'No message';
              final sender = data['senderName']?.toString() ?? 'Unknown';
              final timestamp = (data['time'] as Timestamp?)?.toDate();
              final isMe = data['senderId'] == FirebaseServices.currentUid;
              final timeString =
                  timestamp != null
                      ? TimeOfDay.fromDateTime(timestamp).format(context)
                      : '';

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // color: Colors.grey[100],
                  color: isMe ? Colors.blue[200] : Colors.grey[300],
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sender,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          timeString,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(text, style: TextStyle(fontSize: 15)),
                  ],
                ),
              );
            } catch (e) {
              // print("💀💀💀💀 : ${e.toString()}");
              return ListTile(
                title: Text("Error"),
                subtitle: Text("Data format error: $e"),
              );
            }
          },
        );
      },
    );
  }
}
