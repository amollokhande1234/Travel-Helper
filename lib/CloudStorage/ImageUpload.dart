import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travelhelper/UI/Pages/HomePage.dart';
import 'package:travelhelper/CloudStorage/CloudPhotoView.dart';
import 'package:travelhelper/CloudStorage/StorageServices.dart';
import 'package:travelhelper/widgets/buildTextFeild.dart';
import 'package:travelhelper/widgets/customButton.dart';

class UploadImagePage extends StatefulWidget {
  FilePickerResult selectedFile;
  String groupId;
  UploadImagePage({
    super.key,
    required this.groupId,
    required this.selectedFile,
  });

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Image Page")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _customTextFeild(
                widget.selectedFile.files.first.name ?? "File Name",
                Icons.file_copy,
              ),
              _customTextFeild(
                widget.selectedFile.files.first.extension ?? "Extension",
                Icons.extension,
              ),
              _customTextFeild(
                "${widget.selectedFile.files.first.size} bytes. " ?? "Size",
                Icons.photo_size_select_actual,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          // crossAxisAlignment: CrossAxisAlignment.,
          children: [
            _customButton("Cancel", () {
              Navigator.pop(context);
            }),
            SizedBox(width: 10),
            _customButton("Upload", () async {
              final success = await CloudinaryServices.uploadFileAndStoreUrl(
                widget.selectedFile,
                widget.groupId,
              );
              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Uploaded Successfully"),backgroundColor: Colors.green,),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CloudPhotoView(groupId: widget.groupId),
                    ),
                  );
                }
              } else {
    if (mounted) {
    ScaffoldMessenger.of(
    context,
    ).showSnackBar(SnackBar(content: Text("Uploading Failed"),backgroundColor: Colors.red,));


    } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permission Decliend"),backgroundColor: Colors.red,));
    }
    }}

            ),
          ],
        ),
      ),
    );
  }

  Widget _customTextFeild(
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType? textInputType,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        readOnly: true,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.black),
        keyboardType: textInputType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _customButton(String btnName, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(btnName, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
