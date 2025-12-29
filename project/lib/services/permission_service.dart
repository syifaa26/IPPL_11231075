import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class PermissionService {
  static const _permissionChannel = MethodChannel('nutrix/permissions');

  /// Request camera permission
  static Future<PermissionStatus> requestCameraPermission() async {
    try {
      final result = await _permissionChannel.invokeMethod(
        'requestCameraPermission',
      );
      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      debugPrint('Error requesting camera permission: ${e.message}');
      return PermissionStatus.denied;
    }
  }

  /// Check current camera permission status
  static Future<PermissionStatus> checkCameraPermission() async {
    try {
      final result = await _permissionChannel.invokeMethod(
        'checkCameraPermission',
      );
      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      debugPrint('Error checking camera permission: ${e.message}');
      return PermissionStatus.denied;
    }
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    try {
      final result = await _permissionChannel.invokeMethod('openAppSettings');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error opening app settings: ${e.message}');
      return false;
    }
  }

  static PermissionStatus _parsePermissionStatus(dynamic result) {
    switch (result as String?) {
      case 'granted':
        return PermissionStatus.granted;
      case 'denied':
        return PermissionStatus.denied;
      case 'permanentlyDenied':
        return PermissionStatus.permanentlyDenied;
      case 'restricted':
        return PermissionStatus.restricted;
      default:
        return PermissionStatus.denied;
    }
  }

  /// Show permission dialog with custom messaging
  static Future<bool> showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? positiveButtonText,
    String? negativeButtonText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                negativeButtonText ?? 'Batal',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                positiveButtonText ?? 'Izinkan',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Handle camera permission request with UI feedback
  static Future<bool> handleCameraPermissionRequest(
    BuildContext context,
  ) async {
    // First check current permission status
    final currentStatus = await checkCameraPermission();

    if (currentStatus == PermissionStatus.granted) {
      return true;
    }

    // Show permission rationale dialog
    if (currentStatus == PermissionStatus.denied) {
      final shouldRequest = await showPermissionDialog(
        context: context,
        title: 'Izin Kamera Diperlukan',
        message:
            'Aplikasi Nutrix memerlukan akses kamera untuk mendeteksi makanan secara otomatis. Fitur ini akan membantu Anda mencatat kalori dengan lebih mudah.',
        positiveButtonText: 'Izinkan Kamera',
        negativeButtonText: 'Tidak Sekarang',
      );

      if (!shouldRequest) {
        return false;
      }

      // Request permission
      final requestResult = await requestCameraPermission();
      return requestResult == PermissionStatus.granted;
    }

    // Handle permanently denied case
    if (currentStatus == PermissionStatus.permanentlyDenied) {
      final shouldOpenSettings = await showPermissionDialog(
        context: context,
        title: 'Izin Kamera Diblokir',
        message:
            'Akses kamera telah diblokir. Untuk menggunakan fitur deteksi makanan, silakan buka pengaturan aplikasi dan izinkan akses kamera.',
        positiveButtonText: 'Buka Pengaturan',
        negativeButtonText: 'Nanti Saja',
      );

      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }

    return false;
  }
}

enum PermissionStatus { granted, denied, permanentlyDenied, restricted }
