import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Groupservices {
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  static Future<void> createGroup({
    required String name,
    required String createdBy,
    required List<Map<String, String>> members,
    required List<String> memberIds,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('groups').doc();

    await docRef.set({
      'name': name,
      'createdBy': createdBy,
      'lastMessage': '',
      'lastMessageTime': null,
      'members': members,
      'memberIds': memberIds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
