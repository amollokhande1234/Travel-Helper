import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelhelper/UI/Auth/loginScreen.dart';
import 'package:travelhelper/widgets/customButton.dart';
import 'package:travelhelper/widgets/editableTextFeild.dart';

final fireStore = FirebaseFirestore.instance;

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

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

  final fireStore = FirebaseFirestore.instance;

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueAccent,
                    child: ClipOval(
                      child: Image.asset(
                        "assets/profile.jpg",
                        width: 60, // match diameter (radius * 2)
                        height: 60,
                        fit: BoxFit.cover, // ensures the image fills the circle
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Editable Fields or Info Cards
                  isEditing
                      ? Column(
                        children: [
                          _editableField("Name", nameController),
                          _editableField(
                            "Email",
                            emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _editableField("UPI ID", upiController),
                        ],
                      )
                      : Column(
                        children: [
                          _infoCard("Name", data['name']),
                          _infoCard("Email", data['email']),
                          _infoCard("UPI ID", data['upiId']),
                        ],
                      ),
                  const SizedBox(height: 30),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Edit Button
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(
                            () => isEditing = !isEditing,
                          ); // toggle edit mode
                        },
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        label: Text(
                          isEditing ? "Cancel" : "Edit",
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: const BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Sign Out Button
                      ElevatedButton.icon(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Sign Out",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                          shadowColor: Colors.redAccent.withOpacity(0.5),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Editable Text Field
  Widget _editableField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Info Card
  Widget _infoCard(String label, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label, style: TextStyle(fontSize: 10)),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        // trailing: const Icon(Icons.info_outline, color: Colors.blueAccent),
      ),
    );
  }
}
