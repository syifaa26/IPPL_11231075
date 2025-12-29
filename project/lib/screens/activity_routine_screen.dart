import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_data_service.dart';
import '../theme/app_theme.dart';

class ActivityRoutineScreen extends StatefulWidget {
  const ActivityRoutineScreen({super.key});

  @override
  State<ActivityRoutineScreen> createState() => _ActivityRoutineScreenState();
}

class _ActivityRoutineScreenState extends State<ActivityRoutineScreen> {
  String _activityLevel = 'Jarang Berolahraga';
  int _exerciseFrequency = 0;
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
        _activityLevel = profile.activityLevel;
        _exerciseFrequency = profile.exerciseFrequency;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _saveRoutine() {
    final authService = AuthService();
    final userId = authService.currentUser?.id ?? 'demo';
    final userDataService = UserDataService();
    final currentProfile = userDataService.getUserProfile(userId);
    
    if (currentProfile != null) {
      // Recalculate calories based on new activity level
      final dailyCalories = _calculateDailyCalories(
        weight: currentProfile.currentWeight,
        height: currentProfile.height,
        age: _calculateAge(currentProfile.birthDate),
        gender: currentProfile.gender,
        activityLevel: _activityLevel,
        goal: currentProfile.goal,
      );
      
      userDataService.saveUserProfile(
        userId: userId,
        currentWeight: currentProfile.currentWeight,
        targetWeight: currentProfile.targetWeight,
        height: currentProfile.height,
        gender: currentProfile.gender,
        birthDate: currentProfile.birthDate,
        goal: currentProfile.goal,
        targetPace: currentProfile.targetPace,
        activityLevel: _activityLevel,
        exerciseFrequency: _exerciseFrequency,
        dailyCaloriesTarget: dailyCalories,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rutinitas olahraga berhasil diperbarui'),
          backgroundColor: Colors.green,
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
        title: const Text('Rutinitas Olahraga'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveRoutine,
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
                    'Aktivitas Fisik Anda',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Bantu kami menghitung kebutuhan kalori yang lebih akurat',
                    style: AppTextStyles.body2,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  Text('Tingkat Aktivitas', style: AppTextStyles.body1),
                  const SizedBox(height: AppSpacing.md),
                  _buildActivityOption(
                    'Sangat Jarang (Tidak pernah olahraga)',
                    'Aktivitas harian ringan, banyak duduk',
                    '🛋️',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildActivityOption(
                    'Jarang Berolahraga',
                    'Olahraga ringan 1-2x seminggu',
                    '🚶',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildActivityOption(
                    'Sedang (3-5x seminggu)',
                    'Olahraga teratur, aktivitas cukup',
                    '🏃',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildActivityOption(
                    'Aktif (6-7x seminggu)',
                    'Olahraga setiap hari, sangat aktif',
                    '💪',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildActivityOption(
                    'Sangat Aktif (Atlet)',
                    'Latihan intensif 2x sehari, atlet',
                    '🏆',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  Text('Frekuensi Olahraga per Minggu', style: AppTextStyles.body1),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(8, (index) {
                      return _buildFrequencyButton(index);
                    }),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Text(
                      '$_exerciseFrequency hari per minggu',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
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
                          Icons.lightbulb_outline,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Semakin aktif Anda, semakin banyak kalori yang dibutuhkan tubuh',
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
  
  Widget _buildActivityOption(String level, String description, String emoji) {
    final isSelected = _activityLevel == level;
    return InkWell(
      onTap: () {
        setState(() {
          _activityLevel = level;
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
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
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
  
  Widget _buildFrequencyButton(int frequency) {
    final isSelected = _exerciseFrequency == frequency;
    return InkWell(
      onTap: () {
        setState(() {
          _exerciseFrequency = frequency;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
          boxShadow: isSelected ? AppShadow.small : null,
        ),
        child: Center(
          child: Text(
            '$frequency',
            style: AppTextStyles.body1.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
