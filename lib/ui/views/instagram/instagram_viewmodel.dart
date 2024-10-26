import 'dart:developer';
import 'dart:io';

import 'package:all_in_one/services/snak_bar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:device_info_plus/device_info_plus.dart';

class InstagramViewModel extends BaseViewModel {
  final TextEditingController urlCtrl =
      TextEditingController(text: "https://www.instagram.com/reel/C50tBLjsxo3");

  Stream<List<SharedMediaFile>> sharedMediaFileStream =
      ReceiveSharingIntent.instance.getMediaStream();
  Future<List<SharedMediaFile>> sharedMediaFileFuture =
      ReceiveSharingIntent.instance.getInitialMedia();

  void onViewModelReady() {
    sharedMediaFileStream.listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        urlCtrl.text = value.first.path;
      } else {
        log("No shared media files available.");
      }
    }, onError: (err) {
      log("getLinkStream error: $err");
    });
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      if (await _requireManageExternalStoragePermission())
        Permission.manageExternalStorage,
      if (await _isAndroid33OrAbove()) Permission.photos,
    ].request();

    // Check if any permission is denied
    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      showErrorSnake('Storage or Photos permission denied. Please enable them in the app settings.');
      openAppSettings();
    }
  }

  Future<bool> _isAndroid33OrAbove() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }

  Future<bool> _requireManageExternalStoragePermission() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 30; // Android 11 and above
  }

  Future<void> downloadVideo() async {
    setBusy(true);
    await requestPermissions();

    if (urlCtrl.text.trim().isEmpty) {
      showErrorSnake('No URL provided for download.');
      setBusy(false);
      return;
    }

    try {
      final response = await http.get(Uri.parse(urlCtrl.text.trim()));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/instagram_video.mp4';
        final file = File(filePath);

        // Write bytes to the file and handle potential errors
        await file.writeAsBytes(response.bodyBytes).catchError((error) {
          showErrorSnake('File write error: $error');
        });

        // Check if the file exists
        if (await file.exists()) {
          final result = await GallerySaver.saveVideo(filePath);
          if (result == true) {
            showSucessSnake('Video downloaded to gallery');
            log('Video file saved at $filePath');
          } else {
            showErrorSnake('Failed to save video to gallery');
          }
        } else {
          showErrorSnake('Failed to write video file');
        }
      } else {
        showErrorSnake('Failed to download video: ${response.statusCode}');
      }
    } catch (e) {
      showErrorSnake('Error: $e');
    } finally {
      setBusy(false);
    }
  }
}
