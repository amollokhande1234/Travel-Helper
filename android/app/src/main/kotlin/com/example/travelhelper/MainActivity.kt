package com.example.travelhelper

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()


////package your.package.name
//
//import android.os.Bundle
//import android.media.MediaScannerConnection
//import android.content.Context
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//
//class MainActivity: FlutterActivity() {
//    private val CHANNEL = "media_scanner_channel"
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
//                call, result ->
//            if (call.method == "scanFile") {
//                val path = call.argument<String>("path")
//                if (path != null) {
//                    MediaScannerConnection.scanFile(
//                        context,
//                        arrayOf(path),
//                        null,
//                        null
//                    )
//                    result.success(null)
//                } else {
//                    result.error("INVALID_PATH", "Path is null", null)
//                }
//            } else {
//                result.notImplemented()
//            }
//        }
//    }
//}
