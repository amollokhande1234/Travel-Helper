import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:travelhelper/CloudStorage/StorageServices.dart';
import 'package:travelhelper/FirebaseServices/FirebaseServieces.dart';
import 'dart:io';
import 'dart:typed_data'; // Only this is needed for Uint8List

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CloudPhotoView extends StatefulWidget {
  String groupId;

  CloudPhotoView({super.key, required this.groupId});
  @override
  State<CloudPhotoView> createState() => _CloudPhotoViewState();
}

class _CloudPhotoViewState extends State<CloudPhotoView> {
  void initState() {
    super.initState();
    requestStoragePermission(); // Call permission request here
  }

  // Future<void> requestStoragePermission() async {
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     await Permission.storage.request();
  //   }
  // }

  Future<bool> requestStoragePermission() async {
    // For Android 11 and above
    if (await Permission.manageExternalStorage.isGranted &&
        await Permission.storage.isGranted) {
      print("Storage permission already granted");
      return true;
    }

    // Request both permissions
    var storageStatus = await Permission.storage.request();
    var manageStatus = await Permission.manageExternalStorage.request();

    if (storageStatus.isGranted && manageStatus.isGranted) {
      print("Storage permission granted");
      return true;
    } else {
      print("Storage permission denied. Opening settings...");
      return false;
      // await openAppSettings();
    }
  }

  Future<void> downloadAndSaveImage(String imageUrl) async {
    final permission = await Permission.photos.request();
    if (!permission.isGranted) {
      print('Permission denied');
      return;
    }

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        Uint8List imageBytes = response.bodyBytes;

        final directory = await getExternalStorageDirectory();
        final path =
            '${directory!.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(path);
        await file.writeAsBytes(imageBytes);

        final channel = MethodChannel('media_scanner_channel');
        await channel.invokeMethod('scanFile', {'path': file.path});
        await channel.invokeMethod('scanFile', {'path': file.path});

        print("✅ Image saved: $path");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
          ), // Change this to any icon you like
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
        title: Text("Cloud Images"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream:
              fireStore
                  .collection("groups")
                  .doc(widget.groupId)
                  .collection("uploadedFiles")
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              return Center(child: Text("No images found"));

            final imageDocs = snapshot.data!.docs;

            return GridView.builder(
              padding: EdgeInsets.all(8),
              itemCount: imageDocs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final data = imageDocs[index].data() as Map<String, dynamic>;
                final imageUrl = data['url'];
                final imgName = data['name'];

                if (imageUrl == null ||
                    !imageUrl.toString().startsWith('http')) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(child: Text("Invalid Image")),
                  );
                }

                return Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(imageUrl, fit: BoxFit.cover),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              // This allows text to use available space without overflow
                              child: Text(
                                imgName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () async {
                                final result =
                                    await CloudinaryServices.downloadFileFromCloudinary(
                                      imageUrl,
                                      imgName,
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result
                                          ? "File Downloaded"
                                          : "Error in Downloading file",
                                    ),
                                    backgroundColor:
                                        result ? Colors.green : Colors.red,
                                  ),
                                );
                              },
                              child: const Icon(Icons.download),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
