import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travelhelper/FirebaseServices/FirebaseServieces.dart';

import 'dart:io';
import 'dart:typed_data'; // Only this is needed for Uint8List

import 'package:flutter/services.dart';

class CloudinaryServices {
  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  // Replace with your Cloudinary details
  static String cloudName = 'doldqo1ot';
  static String apiKey = '299434668383851';
  static String apiSecret = 'Qdveq92S1R-FQ8hCXAOosv0eOtc';
  static String preset = 'ktjqccyw';

  static Future<bool> uploadFileAndStoreUrl(
    FilePickerResult? filePickerResult,
    String groupId,
  ) async {
    if (filePickerResult == null || filePickerResult.files.isEmpty) {
      return false;
    }

    final filePath = filePickerResult.files.single.path;
    if (filePath == null) return false;

    final file = File(filePath);

    // Prepare Cloudinary URL
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/raw/upload",
    );
    final request = http.MultipartRequest("POST", uri);

    final fileBytes = await file.readAsBytes();

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: file.path.split('/').last,
    );

    request.files.add(multipartFile);
    request.fields['upload_preset'] = preset;

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print("Cloudinary Response: $responseBody");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(responseBody);

      final uploadedData = {
        "name": filePickerResult.files.first.name,
        "id": jsonResponse["public_id"],
        "extension": filePickerResult.files.first.extension ?? '',
        "size": jsonResponse["bytes"].toString(),
        "url": jsonResponse["secure_url"],
        "created_at": jsonResponse["created_at"],
        "uploaded_on": FieldValue.serverTimestamp(),
      };

      // Store in Firestore under: groups > groupId > uploadedFiles
      await fireStore
          .collection("groups")
          .doc(groupId)
          .collection("uploadedFiles")
          .add(uploadedData);

      print("Upload and Firestore save successful!");
      return true;
    } else {
      print("Upload failed with status: ${response.statusCode}");
      return false;
    }
  }

  // static Future<bool> downloadFileFromCloudinary(String url, String fileName) async {
  //   try {
  //     var status = await Permission.storage.request();
  //     var manageStatus = await Permission.manageExternalStorage.request();
  //     if (status == PermissionStatus.granted &&
  //         manageStatus == PermissionStatus.granted) {
  //       print("Storage permission granted");
  //     } else {
  //       await openAppSettings();
  //     }
  //
  //     Directory? downloadDir = Directory('/storage/emulated/0/Download');
  //     if (!downloadDir.existsSync()) {
  //       print("Download directory not found");
  //       return false;
  //     }
  //
  //     // create the file path
  //     String filePath = '${downloadDir.path}/$fileName';
  //     var response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       File file = File(filePath);
  //       await file.writeAsBytes(response.bodyBytes);
  //       print("File Downloaded Successfully ! Saved at : $filePath");
  //       return true;
  //     } else {
  //       print("Failed to download file. Status Code : ${response.statusCode}");
  //       return false;
  //     }
  //   } catch (e) {
  //   print("Error downloading file : $e");
  //   return false;
  //   }
  // }
  //

  static Future<bool> downloadFileFromCloudinary(String url, String fileName) async {
    try {
      var status = await Permission.storage.request();

      if (!status.isGranted) {
        await openAppSettings();
        return false;
      }

      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        print("Directory not found");
        return false;
      }

      String filePath = '${directory.path}/$fileName';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print("✅ File downloaded at: $filePath");
        return true;
      } else {
        print("❌ Failed to download. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error: $e");
      return false;
    }
  }


  static Future<bool> deleteFromCloudinary(String publicId) async {
    // Generate the timestamp
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Prepare the string for signature generation
    String toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';

    // Generate the signature using SHA1
    var bytes = utf8.encode(toSign);
    var digest = sha1.convert(bytes);
    String signature = digest.toString();
    // Prepare the request URL
    var uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/raw/destroy/',
    );

    // Create the request
    var response = await http.post(
      uri,
      body: {
        'public_id': publicId,
        'timestamp': timestamp.toString(),
        'api_key': apiKey,
        'signature': signature,
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      print(responseBody);
      if (responseBody['result'] == 'ok') {
        print("File deleted successfully.");
        return true;
      } else {
        print("Failed to delete the file.");
        return false;
      }
    } else {
      print(
        "Failed to delete the file, status: ${response.statusCode} : ${response.reasonPhrase}",
      );
      return false;
    }
  }
}
