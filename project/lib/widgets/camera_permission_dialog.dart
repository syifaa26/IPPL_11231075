import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';

class CameraPermissionDialog {
  static Future<bool> requestPermission(BuildContext context) async {
    // Check current permission status
    final status = await PermissionService.checkCameraPermission();

    if (status == PermissionStatus.granted) {
      return true;
    }

    // Show explanation dialog for new users
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.camera_alt, color: AppColors.primary, size: 28),
              const SizedBox(width: 10),
              const Text('Izin Kamera'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nutrix memerlukan akses kamera untuk:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 15),
              _buildPermissionReason(
                Icons.restaurant_menu,
                'Mendeteksi makanan secara otomatis',
              ),
              const SizedBox(height: 10),
              _buildPermissionReason(
                Icons.analytics_outlined,
                'Menganalisis nutrisi makanan',
              ),
              const SizedBox(height: 10),
              _buildPermissionReason(
                Icons.photo_library_outlined,
                'Mengambil foto makanan Anda',
              ),
              const SizedBox(height: 15),
              Text(
                'Kami tidak akan menggunakan kamera untuk tujuan lain.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Nanti', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Izinkan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (shouldRequest != true) {
      return false;
    }

    // Request permission
    final result = await PermissionService.requestCameraPermission();

    if (result == PermissionStatus.granted) {
      return true;
    } else if (result == PermissionStatus.permanentlyDenied) {
      // Show dialog to open settings
      await _showOpenSettingsDialog(context);
      return false;
    } else {
      // Permission denied
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin kamera diperlukan untuk mendeteksi makanan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    }
  }

  static Widget _buildPermissionReason(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  static Future<void> _showOpenSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Izin Kamera Diblokir'),
          content: const Text(
            'Izin kamera telah diblokir. Silakan buka pengaturan aplikasi untuk mengaktifkan izin kamera.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await PermissionService.openAppSettings();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Buka Pengaturan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
