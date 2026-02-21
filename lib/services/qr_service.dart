import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class QRService {
  /// Captures the widget as an image and saves it to the gallery
  static Future<bool> saveQrToGallery(GlobalKey key) async {
    try {
      // 1. Request granular permissions for modern Android (13+)
      if (await _requestPermissions()) {
        // 2. Find the RenderObject
        final RenderRepaintBoundary? boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return false;

        // 3. Convert to high-resolution PNG bytes
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return false;
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // 4. Save to gallery
        final result = await ImageGallerySaverPlus.saveImage(
          pngBytes,
          name: "QR_Branded_${DateTime.now().millisecondsSinceEpoch}",
          quality: 100,
        );
        return result['isSuccess'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint("Export Error: $e");
      return false;
    }
  }

  static Future<bool> _requestPermissions() async {
    // Handle permissions based on Android version
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      if (sdkInt >= 33) {
        // Android 13+ (API 33+): Use granular media permissions
        final status = await Permission.photos.request();
        return status.isGranted;
      } else if (sdkInt >= 29) {
        // Android 10-12 (API 29-32): Use photos permission or legacy storage
        final status = await Permission.storage.request();
        return status.isGranted;
      } else {
        // Android 9 and below (API < 29): Use legacy storage permission
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS: Request photos permission
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return false;
  }
}