import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:travelhelper/CloudStorage/StorageServices.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore fireStore = FirebaseFirestore.instance;
final currentUid = auth.currentUser?.uid;

class FirebaseServices {
  // Optional: Add other reusable Firebase methods here
  static User? get currentUser => auth.currentUser;

  static String get currentUid => auth.currentUser?.uid ?? '';

  // Current user's name (after loaded)

  static Future<void> signOut() async {
    await auth.signOut();
  }

  // Sign In User
  Future<bool> signInUser(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Email and password are required.");
      return false;
    }

    if (!email.contains("@")) {
      Fluttertoast.showToast(msg: "Enter a valid email.");
      return false;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Fluttertoast.showToast(msg: "Sign-in successful!");
      return true;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? "Sign-in failed.");
      return false;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      return false;
    }
  }

  // SIgn Up User
  Future<bool> signUpUser(
    String name,
    String email,
    String password,
    String upiId,
  ) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "All fields are required.");
      return false;
    }

    if (!email.contains("@")) {
      Fluttertoast.showToast(msg: "Invalid email.");
      return false;
    }

    if (password.length < 6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 characters.");
      return false;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
            "uid": userCredential.user!.uid,
            "name": name,
            "email": email,
            "createdAt": Timestamp.now(),
            "upiId": upiId,
          });

      Fluttertoast.showToast(msg: "Sign-up successful!");
      return true;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? "Authentication failed.");
      return false;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      return false;
    }
  }

  // Cloud Fire Store

  static Future<void> saveUploadedFilesData(
    Map<String, String> data,
    String groupId,
  ) async {
    return FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .collection("uploads")
        .doc()
        .set(data);
  }

  // read all uploaded files
  Stream<QuerySnapshot> readUploadedFiles(String groupId) {
    return FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .collection("uploads")
        .snapshots();
  }

  // delete a specific document
  Future<bool> deleteFile(String docId, String publicId, String groupId) async {
    // delete file from cloudinary
    final result = await CloudinaryServices.deleteFromCloudinary(publicId);

    if (result) {
      await FirebaseFirestore.instance
          .collection("groups")
          .doc(groupId)
          .collection("uploads")
          .doc(docId)
          .delete();
      return true;
    }
    return false;
  }
}
