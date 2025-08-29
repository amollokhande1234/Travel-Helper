import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelhelper/FirebaseServices/FirebaseServieces.dart';
import 'package:travelhelper/UI/Pages/HomePage.dart';
import 'package:travelhelper/UI/splashScreen.dart';
import 'package:travelhelper/widgets/buildTextFeild.dart';

import 'package:travelhelper/widgets/responsiveWrapper.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailCtrl = TextEditingController();

  final TextEditingController passCtrl = TextEditingController();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController upiCtrl = TextEditingController();

  FirebaseServices _firebaseServices = FirebaseServices();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ResponsiveWrapper(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_add,
                      size: 60,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildTextField(nameCtrl, 'Name', Icons.person),
                    const SizedBox(height: 16),
                    buildTextField(emailCtrl, 'Email', Icons.email),
                    const SizedBox(height: 16),
                    buildTextField(
                      passCtrl,
                      'Password',
                      Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(upiCtrl, 'Upi Id', Icons.money_rounded),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        bool isSuccess = await _firebaseServices.signUpUser(
                          nameCtrl.text.trim(),
                          emailCtrl.text.trim(),
                          passCtrl.text.trim(),
                          upiCtrl.text.trim(),
                        );

                        if (isSuccess) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => HomePage()),
                          );
                        }
                        setState(() {
                          isLoading = isSuccess;
                        });
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
