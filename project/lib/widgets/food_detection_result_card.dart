import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/food_nutrition_database.dart';
import '../services/nutrition_api_service.dart';

class FoodDetectionResultCard extends StatefulWidget {
  final String foodKey; // normalized key
  final String originalName; // display name
  final double confidence; // 0..1
  final FoodNutrition? nutrition; // may be null
  final void Function(int portionGrams, int estimatedCalories)? onConfirm;

  const FoodDetectionResultCard({
    super.key,
    required this.foodKey,
    required this.originalName,
    required this.confidence,
    required this.nutrition,
    this.onConfirm,
  });

  @override
  State<FoodDetectionResultCard> createState() => _FoodDetectionResultCardState();
}

class _FoodDetectionResultCardState extends State<FoodDetectionResultCard> {
  final TextEditingController _portionController = TextEditingController(text: '100');
  FoodNutrition? _nutrition; // merged local or API
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _nutrition = widget.nutrition;
    if (_nutrition == null) {
      _fetchFallback();
    }
  }

  Future<void> _fetchFallback() async {
    setState(() { _loading = true; _error = false; });
    final data = await NutritionApiService.searchNutrition(widget.originalName);
    if (!mounted) return;
    if (data != null) {
      FoodNutritionDatabase.addDynamic(widget.originalName, data);
      _nutrition = FoodNutritionDatabase.getNutrition(widget.originalName);
    } else {
      _error = true;
    }
    setState(() { _loading = false; });
  }

  int _parsePortion() {
    final raw = _portionController.text.trim();
    final v = int.tryParse(raw);
    if (v == null || v <= 0) return 100;
    return v > 2000 ? 2000 : v; // clamp to reasonable upper bound
  }

  int _calculateCalories(int grams) {
    if (_nutrition == null) return 0;
    return ((_nutrition!.calories * grams) / 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final portion = _parsePortion();
    final estCalories = _calculateCalories(portion);
    final confPct = (widget.confidence * 100).toStringAsFixed(1);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.originalName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Conf: $confPct%'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_nutrition != null) ...[
              Text('Kalori (per 100g): ${_nutrition!.calories} kkal'),
              Text('Protein: ${_nutrition!.protein} g'),
              Text('Karbohidrat: ${_nutrition!.carbs} g'),
              Text('Lemak: ${_nutrition!.fat} g'),
              if (_nutrition!.category == 'API') const Text('(Sumber: API Gemini)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ] else if (_loading) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Mengambil data nutrisi...'),
                ],
              ),
            ] else ...[
              if (_error) const Text('Gagal mengambil nutrisi dari API.'),
              const Text('Data nutrisi tidak ditemukan.'),
              const SizedBox(height: 4),
              const Text('Gunakan porsi manual untuk estimasi.'),
              TextButton(
                onPressed: _fetchFallback,
                child: const Text('Coba Ambil Nutrisi'),
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _portionController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Porsi (gram)',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Reset ke 100g',
                        onPressed: () {
                          _portionController.text = '100';
                          setState(() {});
                        },
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimasi Kalori', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$estCalories kkal'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onConfirm?.call(portion, estCalories);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Konfirmasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
