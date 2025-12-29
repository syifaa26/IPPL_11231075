import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/user_data_service.dart';
import '../widgets/daily_notes_calendar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int selectedTab = 0; // 0 for "Hari Ini", 1 for "Minggu Ini"
  final AuthService _authService = AuthService();
  final UserDataService _userDataService = UserDataService();
  
  NutritionStats? _dailyStats;
  List<NutritionStats>? _weeklyStats;
  NutritionStats? _weeklyAverage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    final user = _authService.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      
      _dailyStats = _userDataService.getDailyNutritionStats(user.id, now);
      _weeklyStats = _userDataService.getWeeklyNutritionStats(user.id, weekStart);
      _weeklyAverage = _userDataService.getWeeklyAverageStats(user.id, weekStart);
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Modern Tab Selection with Gradient
          Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: selectedTab == 0 
                            ? AppColors.primaryGradient
                            : null,
                        color: selectedTab == 0 
                            ? null
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        'Hari Ini',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: selectedTab == 0 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          color: selectedTab == 0 
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: selectedTab == 1 
                            ? AppColors.primaryGradient
                            : null,
                        color: selectedTab == 1 
                            ? null
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        'Minggu Ini',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: selectedTab == 1 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          color: selectedTab == 1 
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Chart Content
          selectedTab == 0 ? _buildDailyNutritionChart() : _buildWeeklyCalorieChart(),

          const SizedBox(height: 20),

          // Daily Targets with REAL DATA
          if (_dailyStats != null && _dailyStats!.meals.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Harian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Protein Progress with REAL DATA
                  _buildProgressItem(
                    label: 'Protein',
                    current: _dailyStats!.totalProtein,
                    target: 80,
                    color: AppColors.protein,
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Carbohydrate Progress with REAL DATA
                  _buildProgressItem(
                    label: 'Karbohidrat',
                    current: _dailyStats!.totalCarbs,
                    target: 250,
                    color: AppColors.carbs,
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Fat Progress with REAL DATA
                  _buildProgressItem(
                    label: 'Lemak',
                    current: _dailyStats!.totalFat,
                    target: 65,
                    color: AppColors.fat,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          
          // Daily Notes Calendar Widget
          if (_authService.currentUser != null)
            DailyNotesCalendar(userId: _authService.currentUser!.id),
          const SizedBox(height: 100), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildDailyNutritionChart() {
    // Handle loading state
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    
    // Handle no data (user baru)
    if (_dailyStats == null || _dailyStats!.meals.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai tambahkan makanan untuk melihat statistik nutrisi Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komposisi Nutrisi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 30),
          
          // Donut Chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 70,
                sections: _getPieChartSections(),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Legend with REAL DATA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(
                color: AppColors.protein,
                label: 'Protein',
                value: '${_dailyStats!.totalProtein}g',
              ),
              _buildLegendItem(
                color: AppColors.carbs,
                label: 'Karbohidrat',
                value: '${_dailyStats!.totalCarbs}g',
              ),
              _buildLegendItem(
                color: AppColors.fat,
                label: 'Lemak',
                value: '${_dailyStats!.totalFat}g',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalorieChart() {
    // Handle loading state
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    
    // Handle no data (user baru)
    if (_weeklyStats == null || _weeklyStats!.every((stat) => stat.meals.isEmpty)) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(Icons.show_chart, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Data Mingguan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data statistik minggu ini akan muncul setelah Anda menambahkan makanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    // Calculate max value for chart scaling
    double maxCalories = 2200;
    if (_weeklyStats!.isNotEmpty) {
      final maxFromData = _weeklyStats!.map((s) => s.totalCalories.toDouble()).reduce((a, b) => a > b ? a : b);
      if (maxFromData > maxCalories) {
        maxCalories = ((maxFromData / 500).ceil() * 500).toDouble();
      }
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kalori Mingguan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 30),
          
          // Line Chart with REAL DATA
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxCalories / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = Text('Sen', style: style);
                            break;
                          case 1:
                            text = Text('Sel', style: style);
                            break;
                          case 2:
                            text = Text('Rab', style: style);
                            break;
                          case 3:
                            text = Text('Kam', style: style);
                            break;
                          case 4:
                            text = Text('Jum', style: style);
                            break;
                          case 5:
                            text = Text('Sab', style: style);
                            break;
                          case 6:
                            text = Text('Min', style: style);
                            break;
                          default:
                            text = Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxCalories / 4,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxCalories,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(7, (index) {
                      if (index < _weeklyStats!.length) {
                        return FlSpot(index.toDouble(), _weeklyStats![index].totalCalories.toDouble());
                      }
                      return FlSpot(index.toDouble(), 0);
                    }),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Weekly Average with REAL DATA
          Center(
            child: Column(
              children: [
                Text(
                  'Rata-rata minggu ini',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_weeklyAverage?.totalCalories ?? 0} kkal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    // Use REAL DATA from _dailyStats
    if (_dailyStats == null) {
      return [];
    }
    
    return [
      PieChartSectionData(
        color: AppColors.protein,
        value: _dailyStats!.totalProtein.toDouble(),
        title: '',
        radius: 25,
      ),
      PieChartSectionData(
        color: AppColors.carbs,
        value: _dailyStats!.totalCarbs.toDouble(),
        title: '',
        radius: 25,
      ),
      PieChartSectionData(
        color: AppColors.fat,
        value: _dailyStats!.totalFat.toDouble(),
        title: '',
        radius: 25,
      ),
    ];
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItem({
    required String label,
    required int current,
    required int target,
    required Color color,
  }) {
    double progress = current / target;
    if (progress > 1.0) progress = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${current}g / ${target}g',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200]!,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
