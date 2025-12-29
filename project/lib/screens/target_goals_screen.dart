import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_data_service.dart';
import '../theme/app_theme.dart';

class TargetGoalsScreen extends StatefulWidget {
  const TargetGoalsScreen({super.key});

  @override
  State<TargetGoalsScreen> createState() => _TargetGoalsScreenState();
}

class _TargetGoalsScreenState extends State<TargetGoalsScreen> {
  String _goal = 'Menurunkan Berat Badan';
  String _targetPace = 'Sedang (0.5 kg/minggu)';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  void _loadUserProfile() {
    final authService = AuthService();
    final userId = authService.currentUser?.id ?? 'demo';
    final userDataService = UserDataService();
    final profile = userDataService.getUserProfile(userId);
    
    if (profile != null) {
      setState(() {
        _goal = profile.goal;
        _targetPace = profile.targetPace;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _saveGoals() {
    final authService = AuthService();
    final userId = authService.currentUser?.id ?? 'demo';
    final userDataService = UserDataService();
    final currentProfile = userDataService.getUserProfile(userId);
    
    if (currentProfile != null) {
      // Recalculate calories based on new goal
      final dailyCalories = _calculateDailyCalories(
        weight: currentProfile.currentWeight,
        height: currentProfile.height,
        age: _calculateAge(currentProfile.birthDate),
        gender: currentProfile.gender,
        activityLevel: currentProfile.activityLevel,
        goal: _goal,
      );
      
      userDataService.saveUserProfile(
        userId: userId,
        currentWeight: currentProfile.currentWeight,
        targetWeight: currentProfile.targetWeight,
        height: currentProfile.height,
        gender: currentProfile.gender,
        birthDate: currentProfile.birthDate,
        goal: _goal,
        targetPace: _targetPace,
        activityLevel: currentProfile.activityLevel,
        exerciseFrequency: currentProfile.exerciseFrequency,
        dailyCaloriesTarget: dailyCalories,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Target & tujuan berhasil diperbarui'),
          backgroundColor: AppColors.primary,
        ),
      );
      
      Navigator.pop(context);
    }
  }
  
  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  
  int _calculateDailyCalories({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    // BMR calculation
    double bmr;
    if (gender == 'Laki-laki') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    
    // Activity multiplier
    double activityMultiplier;
    switch (activityLevel) {
      case 'Sangat Jarang (Tidak pernah olahraga)':
        activityMultiplier = 1.2;
        break;
      case 'Jarang Berolahraga':
        activityMultiplier = 1.375;
        break;
      case 'Sedang (3-5x seminggu)':
        activityMultiplier = 1.55;
        break;
      case 'Aktif (6-7x seminggu)':
        activityMultiplier = 1.725;
        break;
      case 'Sangat Aktif (Atlet)':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2;
    }
    
    double tdee = bmr * activityMultiplier;
    
    // Adjust based on goal
    if (goal == 'Menurunkan Berat Badan') {
      tdee -= 500;
    } else if (goal == 'Menaikkan Berat Badan') {
      tdee += 500;
    }
    
    return tdee.round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Target & Tujuan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveGoals,
            child: Text(
              'Simpan',
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atur Target Kesehatan',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Sesuaikan tujuan dan kecepatan pencapaian Anda',
                    style: AppTextStyles.body2,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  Text('Tujuan Utama', style: AppTextStyles.body1),
                  const SizedBox(height: AppSpacing.md),
                  _buildGoalOption(
                    'Menurunkan Berat Badan',
                    Icons.trending_down_rounded,
                    '🎯',
                    'Defisit kalori untuk turun berat',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildGoalOption(
                    'Menjaga Berat Badan',
                    Icons.favorite_rounded,
                    '💚',
                    'Kalori seimbang untuk maintain',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildGoalOption(
                    'Menaikkan Berat Badan',
                    Icons.trending_up_rounded,
                    '📈',
                    'Surplus kalori untuk naik berat',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  Text('Kecepatan Target', style: AppTextStyles.body1),
                  const SizedBox(height: AppSpacing.md),
                  _buildPaceOption('Lambat (0.25 kg/minggu)', 'Aman & Berkelanjutan'),
                  const SizedBox(height: AppSpacing.sm),
                  _buildPaceOption('Sedang (0.5 kg/minggu)', 'Disarankan ⭐'),
                  const SizedBox(height: AppSpacing.sm),
                  _buildPaceOption('Cepat (1 kg/minggu)', 'Memerlukan Disiplin'),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Info box
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Target kalori harian Anda akan dihitung ulang berdasarkan pilihan ini',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildGoalOption(String goal, IconData icon, String emoji, String description) {
    final isSelected = _goal == goal;
    return InkWell(
      onTap: () {
        setState(() {
          _goal = goal;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected ? AppShadow.medium : AppShadow.small,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal,
                    style: AppTextStyles.body1.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.9) 
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaceOption(String pace, String description) {
    final isSelected = _targetPace == pace;
    return InkWell(
      onTap: () {
        setState(() {
          _targetPace = pace;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
          boxShadow: isSelected ? AppShadow.medium : AppShadow.small,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pace,
                    style: AppTextStyles.body1.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.9) 
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
