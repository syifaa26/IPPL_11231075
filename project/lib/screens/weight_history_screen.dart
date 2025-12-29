import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/user_data_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class WeightHistoryScreen extends StatefulWidget {
  const WeightHistoryScreen({super.key});

  @override
  State<WeightHistoryScreen> createState() => _WeightHistoryScreenState();
}

class _WeightHistoryScreenState extends State<WeightHistoryScreen> {
  final TextEditingController _weightController = TextEditingController();
  
  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }
  
  void _addWeightRecord() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan berat badan yang valid')),
      );
      return;
    }
    
    final authService = AuthService();
    final userId = authService.currentUser?.id ?? 'demo';
    final userDataService = UserDataService();
    
    userDataService.updateCurrentWeight(userId, weight);
    _weightController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berat badan berhasil ditambahkan')),
    );
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userId = authService.currentUser?.id ?? 'demo';
    final userDataService = UserDataService();
    final weightHistory = userDataService.getWeightHistory(userId);
    final userProfile = userDataService.getUserProfile(userId);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Berat Badan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: weightHistory.isEmpty 
          ? _buildEmptyState()
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Progress Summary Card
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadow.medium,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Progress Anda',
                          style: AppTextStyles.h3.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProgressStat(
                              'Awal',
                              '${weightHistory.first.weight.toStringAsFixed(1)} kg',
                            ),
                            _buildProgressStat(
                              'Sekarang',
                              '${weightHistory.last.weight.toStringAsFixed(1)} kg',
                            ),
                            if (userProfile != null)
                              _buildProgressStat(
                                'Target',
                                '${userProfile.targetWeight.toStringAsFixed(1)} kg',
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getProgressIcon(weightHistory),
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                _getProgressText(weightHistory),
                                style: AppTextStyles.body1.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Chart
                  if (weightHistory.length > 1)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadow.small,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grafik Progress',
                            style: AppTextStyles.h4,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            height: 250,
                            child: LineChart(
                              _buildChartData(weightHistory),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Add Weight Entry
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadow.small,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catat Berat Badan Hari Ini',
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan berat (kg)',
                                  prefixIcon: Icon(
                                    Icons.monitor_weight_outlined,
                                    color: AppColors.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                boxShadow: AppShadow.medium,
                              ),
                              child: ElevatedButton(
                                onPressed: _addWeightRecord,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                ),
                                child: const Icon(Icons.add),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // History List
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadow.small,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'Riwayat Lengkap',
                            style: AppTextStyles.h4,
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: weightHistory.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            // Reverse to show latest first
                            final record = weightHistory[weightHistory.length - 1 - index];
                            final previousRecord = index < weightHistory.length - 1
                                ? weightHistory[weightHistory.length - 2 - index]
                                : null;
                            
                            final difference = previousRecord != null
                                ? record.weight - previousRecord.weight
                                : 0.0;
                            
                            return ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.monitor_weight,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                '${record.weight.toStringAsFixed(1)} kg',
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                _formatDate(record.date),
                                style: AppTextStyles.caption,
                              ),
                              trailing: previousRecord != null
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: difference < 0
                                            ? Colors.green.withOpacity(0.1)
                                            : difference > 0
                                                ? Colors.orange.withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            difference < 0
                                                ? Icons.arrow_downward
                                                : difference > 0
                                                    ? Icons.arrow_upward
                                                    : Icons.remove,
                                            size: 16,
                                            color: difference < 0
                                                ? Colors.green
                                                : difference > 0
                                                    ? Colors.orange
                                                    : Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${difference.abs().toStringAsFixed(1)} kg',
                                            style: TextStyle(
                                              color: difference < 0
                                                  ? Colors.green
                                                  : difference > 0
                                                      ? Colors.orange
                                                      : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.monitor_weight_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Belum Ada Riwayat',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Lengkapi profil Anda terlebih dahulu\nuntuk mulai mencatat berat badan',
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
  
  IconData _getProgressIcon(List<WeightRecord> history) {
    if (history.length < 2) return Icons.remove;
    final diff = history.last.weight - history.first.weight;
    if (diff < 0) return Icons.trending_down;
    if (diff > 0) return Icons.trending_up;
    return Icons.remove;
  }
  
  String _getProgressText(List<WeightRecord> history) {
    if (history.length < 2) return 'Belum ada perubahan';
    final diff = history.last.weight - history.first.weight;
    if (diff < 0) {
      return 'Turun ${diff.abs().toStringAsFixed(1)} kg';
    } else if (diff > 0) {
      return 'Naik ${diff.toStringAsFixed(1)} kg';
    }
    return 'Tidak ada perubahan';
  }
  
  LineChartData _buildChartData(List<WeightRecord> history) {
    final spots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
    
    final minWeight = history.map((r) => r.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight = history.map((r) => r.weight).reduce((a, b) => a > b ? a : b);
    final margin = (maxWeight - minWeight) * 0.1;
    
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()} kg',
                style: AppTextStyles.caption,
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < history.length) {
                final date = history[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: AppTextStyles.caption,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (history.length - 1).toDouble(),
      minY: minWeight - margin,
      maxY: maxWeight + margin,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: AppColors.primaryGradient,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppColors.primary,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.primary.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else if (difference < 7) {
      return '$difference hari yang lalu';
    } else {
      return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
    }
  }
}
