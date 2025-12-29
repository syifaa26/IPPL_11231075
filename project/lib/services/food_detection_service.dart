import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class FoodDetectionService {
  static bool _isInitialized = false;
  static GenerativeModel? _model;
  static bool _geminiEnabled = false;
  static String? _activeModelName;
  static DateTime? _initializedAt;
  static String? _apiKey;

  // Daftar model fallback statis (urutkan dari yang ringan ke yang lebih besar)
  static const List<String> _staticFallback = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-pro',
    'gemini-pro-vision',
  ];
  static List<String> _modelCandidates = List.from(_staticFallback);

  static Future<void> _discoverModels(String apiKey) async {
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) {
        debugPrint('ℹ️ Gagal list models: ${resp.statusCode} ${resp.body}');
        return;
      }
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final models = (data['models'] as List?) ?? [];
      final visionish = <String>[];
      for (final m in models) {
        if (m is Map) {
          String name = m['name']?.toString() ?? '';
          if (name.startsWith('models/')) {
            name = name.substring('models/'.length);
          }
          final methods = (m['supportedGenerationMethods'] as List?)?.map((e) => e.toString()).toList() ?? [];
          if (methods.contains('generateContent')) {
            // Prioritaskan yang mengandung kata vision / flash
            if (name.contains('vision') || name.contains('flash')) {
              visionish.add(name);
            }
          }
        }
      }
      if (visionish.isNotEmpty) {
        // Susun kandidat: hasil discovery + fallback statis (hindari duplikasi)
        final merged = <String>[];
        for (final v in visionish) {
          if (!merged.contains(v)) merged.add(v);
        }
        for (final s in _staticFallback) {
          if (!merged.contains(s)) merged.add(s);
        }
        _modelCandidates = merged;
        debugPrint('🔍 Discovered models: ${_modelCandidates.join(', ')}');
      }
    } catch (e) {
      debugPrint('⚠️ Error discovery models: $e');
    }
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      // Tidak melempar error agar aplikasi tetap bisa jalan dengan fallback lain nantinya.
      debugPrint('⚠️ GEMINI_API_KEY tidak diset. Deteksi hanya akan gagal / butuh model lokal.');
      _geminiEnabled = false;
      _isInitialized = true;
      _initializedAt = DateTime.now();
      return;
    }

    _apiKey = apiKey;
    // Auto-discovery dulu
    await _discoverModels(apiKey);

    // Coba instantiate beberapa model hasil discovery + fallback sampai ada yang berhasil.
    for (final candidate in _modelCandidates) {
      try {
        final testModel = GenerativeModel(
          model: candidate,
          apiKey: apiKey,
          generationConfig: GenerationConfig(temperature: 0.2),
        );
        // Panggilan ringan untuk verifikasi (tanpa gambar) agar cepat.
        final ping = await testModel.generateContent([
          Content.text('ping'),
        ]);
        if ((ping.text ?? '').isNotEmpty) {
          _model = testModel;
          _activeModelName = candidate;
          _geminiEnabled = true;
          debugPrint('✅ Gemini model aktif: $candidate');
          break;
        }
      } catch (e) {
        debugPrint('➡️ Model "$candidate" gagal digunakan: $e');
        continue;
      }
    }

    if (_model == null) {
      debugPrint('❌ Semua kandidat model Gemini gagal diinisialisasi.');
      _geminiEnabled = false;
    }
    _isInitialized = true;
    _initializedAt = DateTime.now();
    debugPrint('🟢 FoodDetectionService initialized: activeModel=${_activeModelName ?? '-'} geminiEnabled=$_geminiEnabled at=$_initializedAt');
  }

  /// Helper untuk memastikan service sudah ter-initialize dan me-log status jika belum.
  static Future<void> ensureInitialized({bool verbose = false}) async {
    if (!_isInitialized) {
      if (verbose) debugPrint('ℹ️ ensureInitialized memanggil initialize()');
      await initialize();
    } else if (verbose) {
      debugPrint('ℹ️ Service sudah initialized: model=${_activeModelName ?? '-'} enabled=$_geminiEnabled');
    }
  }

  // Detect food from image using Gemini Vision
  static Future<Map<String, dynamic>> detectFood(File imageFile) async {
    if (!_isInitialized) await initialize();

    if (!_geminiEnabled || _model == null) {
      return {
        'success': false,
        'error': 'Gemini tidak aktif (API key kosong atau model gagal diinisialisasi).',
        'suggestion': 'Jalankan dengan --dart-define=GEMINI_API_KEY=YOUR_KEY atau cek nama model.',
      };
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final imagePart = DataPart('image/jpeg', bytes);
      final instructions = TextPart(
        'Detect visible foods in this image (max 5 distinct items). '
        'Reply ONLY as pure compact JSON array (no markdown, no text): '
        '[{"name": string_lowercase_underscore, "confidence": number 0..1, "portion_grams_estimate": number}]. '
        'If only one food is visible, return an array with a single object. '
        'If unsure about any item, include it with lower confidence and reasonable portion estimate.'
      );

      Future<GenerateContentResponse> _attempt(GenerativeModel model) async {
        // Simple retry with backoff for transient 503s
        const delays = [
          Duration(milliseconds: 400),
          Duration(milliseconds: 800),
          Duration(milliseconds: 1400),
        ];
        int tries = 0;
        while (true) {
          tries++;
          try {
            return await model.generateContent([
              Content.multi([instructions, imagePart])
            ]);
          } catch (e) {
            final es = e.toString();
            final transient = es.contains('503') || es.contains('UNAVAILABLE') || es.contains('overloaded');
            if (transient && tries <= delays.length) {
              final d = delays[tries - 1];
              debugPrint('⏳ 503/UNAVAILABLE, retry $tries after ${d.inMilliseconds}ms');
              await Future.delayed(d);
              continue;
            }
            rethrow;
          }
        }
      }

      // First try with the active model
      GenerateContentResponse response;
      try {
        response = await _attempt(_model!);
      } catch (e) {
        final es = e.toString();
        final transient = es.contains('503') || es.contains('UNAVAILABLE') || es.contains('overloaded');
        if (!transient || _apiKey == null) rethrow;

        // Rotate through other candidates
        debugPrint('🔁 Model ${_activeModelName} mengalami 503, mencoba kandidat lain...');
        final tried = <String>{ if (_activeModelName != null) _activeModelName! };
        bool switched = false;
        GenerateContentResponse? ok;
        for (final cand in _modelCandidates) {
          if (tried.contains(cand)) continue;
          try {
            final candidateModel = GenerativeModel(
              model: cand,
              apiKey: _apiKey!,
              generationConfig: GenerationConfig(temperature: 0.2),
            );
            // quick ping
            final ping = await candidateModel.generateContent([Content.text('ping')]);
            if ((ping.text ?? '').isEmpty) {
              continue;
            }
            _model = candidateModel;
            _activeModelName = cand;
            switched = true;
            debugPrint('✅ Beralih ke model: $cand');
            ok = await _attempt(candidateModel);
            break;
          } catch (e) {
            debugPrint('➡️ Kandidat "$cand" gagal: $e');
            continue;
          }
        }
        if (!switched || ok == null) rethrow;
        response = ok;
      }

      final text = response.text?.trim() ?? '';

      // Normalisasi JSON bila dibungkus triple backticks
      String jsonStr = text;
      if (jsonStr.startsWith('```')) {
        final braceStart = jsonStr.indexOf('{');
        final braceEnd = jsonStr.lastIndexOf('}');
        final arrStart = jsonStr.indexOf('[');
        final arrEnd = jsonStr.lastIndexOf(']');
        if (arrStart != -1 && arrEnd != -1 && arrEnd > arrStart) {
          jsonStr = jsonStr.substring(arrStart, arrEnd + 1);
        } else if (braceStart != -1 && braceEnd != -1 && braceEnd > braceStart) {
          jsonStr = jsonStr.substring(braceStart, braceEnd + 1);
        }
      }

      dynamic decoded;
      try {
        if (jsonStr.trim().startsWith('[')) {
          decoded = json.decode(jsonStr) as List<dynamic>;
        } else {
          decoded = json.decode(jsonStr);
        }
      } catch (_) {
        return {
          'success': false,
          'error': 'Format respons Gemini tidak valid / bukan JSON: "$jsonStr"',
          'raw': text,
        };
      }

      final List<Map<String, dynamic>> items = [];
      if (decoded is List) {
        for (final e in decoded) {
          if (e is Map) {
            final n = (e['name'] ?? 'unknown').toString();
            final c = (e['confidence'] is num) ? (e['confidence'] as num).toDouble() : 0.0;
            final pg = (e['portion_grams_estimate'] is num) ? (e['portion_grams_estimate'] as num).round() : null;
            items.add({
              'name': n,
              'confidence': (c * 100).toStringAsFixed(1),
              'confidenceValue': c,
              if (pg != null) 'portionGrams': pg,
            });
          }
        }
      } else if (decoded is Map<String, dynamic>) {
        // Kompatibilitas: objek tunggal
        final n = (decoded['name'] ?? 'unknown').toString();
        final c = (decoded['confidence'] is num) ? (decoded['confidence'] as num).toDouble() : 0.0;
        final pg = (decoded['portion_estimate_grams'] is num)
            ? (decoded['portion_estimate_grams'] as num).round()
            : (decoded['portion_grams_estimate'] is num)
                ? (decoded['portion_grams_estimate'] as num).round()
                : null;
        items.add({
          'name': n,
          'confidence': (c * 100).toStringAsFixed(1),
          'confidenceValue': c,
          if (pg != null) 'portionGrams': pg,
        });
      }

      if (items.isEmpty) {
        return {
          'success': false,
          'error': 'Tidak ada item makanan terdeteksi dari respons: "$jsonStr"',
          'raw': text,
        };
      }

      items.sort((a, b) => (b['confidenceValue'] as double).compareTo(a['confidenceValue'] as double));
      final top = items.first;

      return {
        'success': true,
        'model': _activeModelName ?? 'unknown',
        'initializedAt': _initializedAt?.toIso8601String(),
        'topPrediction': top,
        'items': items,
      };
    } on SocketException catch (e) {
      debugPrint('❌ No internet: $e');
      return {
        'success': false,
        'error': 'Tidak ada koneksi internet. Periksa jaringan Anda.',
      };
    } catch (e) {
      debugPrint('❌ Gemini detection error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'suggestion': 'Coba ganti model ke salah satu: ${_modelCandidates.join(', ')} atau perbarui paket google_generative_ai.',
      };
    }
  }
}
