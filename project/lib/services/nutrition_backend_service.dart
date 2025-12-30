import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class NutritionBackendService {
  // Untuk Android emulator gunakan 10.0.2.2. Jika pakai device fisik,
  // ganti dengan IP laptop, misalnya: http://192.168.1.10:5000.
  static const String _baseUrl =
      'https://ippl11231075-production.up.railway.app';

  static Future<Map<String, dynamic>?> analyzeImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final imageData = base64Encode(bytes);

      final uri = Uri.parse('$_baseUrl/api/ai');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageData': imageData, 'mimeType': 'image/jpeg'}),
      );

      // Log status dan body untuk debugging integrasi
      // (bisa dihapus lagi nanti jika sudah stabil)
      // ignore: avoid_print
      print('Backend status: ${resp.statusCode} ${resp.body}');

      if (resp.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      // ignore: avoid_print
      print('Backend error: $e');
      return null;
    }
  }
}
