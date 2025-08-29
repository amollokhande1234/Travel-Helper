import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelhelper/UI/Auth/loginScreen.dart';
import 'package:travelhelper/widgets/customButton.dart';
import 'package:travelhelper/widgets/editableTextFeild.dart';

final fireStore = FirebaseFirestore.instance;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  bool isEditing = false;
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController upiController = TextEditingController();

  void updateProfile() async {
    await fireStore.collection("users").doc(currentUser!.uid).update({
      "name": nameController.text,
      "email": emailController.text,
      "upiId": upiController.text,
    });

    setState(() => isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream:
          fireStore.collection("users").doc(currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("No Profile Data Found"));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            nameController.text = data['name'];
            emailController.text = data['email'];
            upiController.text = data['upiId'];

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 26,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "My Profile",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  isEditing
                      ? Column(
                    children: [
                      EditableTextField(
                        label: "Name",
                        controller: nameController,
                      ),
                      EditableTextField(
                        label: "Email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      EditableTextField(
                        label: "Upi Id",
                        controller: upiController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  )
                      : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _customText("Name", data['name']),
                          SizedBox(height: 10),
                          _customText("Email", data['email']),
                          SizedBox(height: 10),
                          _customText("Upi Id ", data['upiId']),
                        ],
                      ),
                    ),
                  ),
                  Row(
  mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(onPressed:  () {
                          if (isEditing) {
                            updateProfile();
                          } else {
                            setState(() => isEditing = true);
                          }
                        },child: Text(isEditing ? "Save" : "Edit")),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          child: Text(
                            "Sing Out",
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),

                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                                  (route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  )


                ],
              ),
            );
          },
        ),
      ),

    );
  }

  Widget _customText(String label, String text) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey), // Outline border effect
      ),
      child: Center(
        child: Text(
          "$label : $text",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}