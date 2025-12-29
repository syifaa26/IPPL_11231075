import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

/// Fallback pencarian nutrisi via Gemini (approximate per 100g).
/// Mengembalikan map {calories, protein, carbs, fat} atau null jika gagal.
class NutritionApiService {
  static final Map<String, Map<String, dynamic>> _cache = {};
  static GenerativeModel? _model;
  static bool _ready = false;

  static Future<void> _ensureModel() async {
    if (_ready) return;
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      debugPrint('NutritionApiService: API key kosong.');
      return;
    }
    // Pakai model ringan agar cepat.
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(temperature: 0.2),
    );
    _ready = true;
  }

  static Future<Map<String, dynamic>?> searchNutrition(String name) async {
    final key = name.toLowerCase().trim();
    if (_cache.containsKey(key)) return _cache[key];
    await _ensureModel();
    if (_model == null) return null;

    final prompt = 'Provide approximate nutrition per 100g for food item: "$name". Respond ONLY JSON: {"calories": number, "protein": number, "carbs": number, "fat": number}. No text outside JSON.';
    try {
      final resp = await _model!.generateContent([Content.text(prompt)]);
      final txt = resp.text?.trim() ?? '';
      String jsonStr = txt;
      if (jsonStr.startsWith('```')) {
        final start = jsonStr.indexOf('{');
        final end = jsonStr.lastIndexOf('}');
        if (start != -1 && end != -1 && end > start) {
          jsonStr = jsonStr.substring(start, end + 1);
        }
      }
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      // Validasi minimal
      if (!data.containsKey('calories')) return null;
      final cleaned = {
        'calories': (data['calories'] is num) ? (data['calories'] as num).round() : 0,
        'protein': (data['protein'] is num) ? (data['protein'] as num).toDouble() : 0.0,
        'carbs': (data['carbs'] is num) ? (data['carbs'] as num).toDouble() : 0.0,
        'fat': (data['fat'] is num) ? (data['fat'] as num).toDouble() : 0.0,
        'source': 'gemini'
      };
      _cache[key] = cleaned;
      return cleaned;
    } catch (e) {
      debugPrint('NutritionApiService error: $e');
      return null;
    }
  }
}
