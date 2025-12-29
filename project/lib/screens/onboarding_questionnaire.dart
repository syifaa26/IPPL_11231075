import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_data_service.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'permission_request_screen.dart';

class OnboardingQuestionnaire extends StatefulWidget {
  const OnboardingQuestionnaire({super.key});

  @override
  State<OnboardingQuestionnaire> createState() => _OnboardingQuestionnaireState();
}

class _OnboardingQuestionnaireState extends State<OnboardingQuestionnaire> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Personal Info
  final TextEditingController _currentWeightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _gender = 'Laki-laki';
  DateTime _birthDate = DateTime(2000, 1, 1);
  
  // Target & Tujuan
  String _goal = 'Menurunkan Berat Badan';
  String _targetPace = 'Sedang (0.5 kg/minggu)';
  
  // Rutinitas Olahraga
  String _activityLevel = 'Jarang Berolahraga';
  int _exerciseFrequency = 0;
  
  // Validation flags
  bool get _isPage1Valid {
    return _currentWeightController.text.isNotEmpty &&
           _targetWeightController.text.isNotEmpty &&
           _heightController.text.isNotEmpty &&
           (double.tryParse(_currentWeightController.text) ?? 0) > 0 &&
           (double.tryParse(_targetWeightController.text) ?? 0) > 0 &&
           (double.tryParse(_heightController.text) ?? 0) > 0;
  }
  
  bool get _isPage2Valid => true; // Goals always have default selection
  bool get _isPage3Valid => true; // Activity always has default selection
  
  @override
  void initState() {
    super.initState();
    // Add listeners to update button state
    _currentWeightController.addListener(() => setState(() {}));
    _targetWeightController.addListener(() => setState(() {}));
    _heightController.addListener(() => setState(() {}));
  }
  
  @override
  void dispose() {
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _heightController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    // Validate current page before proceeding
    if (_currentPage == 0 && !_isPage1Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data dengan benar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _isPage1Valid;
      case 1:
        return _isPage2Valid;
      case 2:
        return _isPage3Valid;
      default:
        return false;
    }
  }
  
  void _finishOnboarding() {
    // Validasi input
    if (_currentWeightController.text.isEmpty || 
        _targetWeightController.text.isEmpty ||
        _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data')),
      );
      return;
    }
    
    final currentWeight = double.tryParse(_currentWeightController.text) ?? 0;
    final targetWeight = double.tryParse(_targetWeightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    
    if (currentWeight <= 0 || targetWeight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon masukkan nilai yang valid')),
      );
      return;
    }
    
    // Simpan data user
    final authService = AuthService();
    final userId = authService.currentUser?.id ?? 'demo';
    final userDataService = UserDataService();
    
    // Hitung kalori target berdasarkan BMR dan aktivitas
    final dailyCalories = _calculateDailyCalories(
      weight: currentWeight,
      height: height,
      age: _calculateAge(_birthDate),
      gender: _gender,
      activityLevel: _activityLevel,
      goal: _goal,
    );
    
    // Simpan profil user
    userDataService.saveUserProfile(
      userId: userId,
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      height: height,
      gender: _gender,
      birthDate: _birthDate,
      goal: _goal,
      targetPace: _targetPace,
      activityLevel: _activityLevel,
      exerciseFrequency: _exerciseFrequency,
      dailyCaloriesTarget: dailyCalories,
    );
    
    // Mark onboarding as complete
    authService.completeOnboardingForCurrentUser();
    
    // Navigate to permission request for new users
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const PermissionRequestScreen()),
    );
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
    // Hitung BMR (Basal Metabolic Rate) menggunakan Mifflin-St Jeor Equation
    double bmr;
    if (gender == 'Laki-laki') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    
    // Kalikan dengan activity multiplier
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
    
    // Sesuaikan berdasarkan goal
    if (goal == 'Menurunkan Berat Badan') {
      tdee -= 500; // Defisit 500 kalori untuk turun ~0.5kg/minggu
    } else if (goal == 'Menaikkan Berat Badan') {
      tdee += 500; // Surplus 500 kalori untuk naik ~0.5kg/minggu
    }
    
    return tdee.round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index < 2 ? AppSpacing.sm : 0,
                        ),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= _currentPage 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.xxl),
                      topRight: Radius.circular(AppRadius.xxl),
                    ),
                  ),
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildPersonalInfoPage(),
                      _buildGoalsPage(),
                      _buildActivityPage(),
                    ],
                  ),
                ),
              ),
              
              // Navigation buttons
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: Text(
                            'Kembali',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: _currentPage == 0 ? 1 : 1,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: _canProceed() 
                              ? AppColors.primaryGradient 
                              : null,
                          color: _canProceed() 
                              ? null 
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: _canProceed() ? AppShadow.medium : null,
                        ),
                        child: ElevatedButton(
                          onPressed: _canProceed() ? _nextPage : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: Text(
                            _currentPage == 2 ? 'Selesai' : 'Lanjut',
                            style: AppTextStyles.button.copyWith(
                              color: _canProceed() 
                                  ? Colors.white 
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Pribadi',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Kami butuh informasi untuk menghitung kebutuhan kalori Anda',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Berat Badan Saat Ini
          Text('Berat Badan Saat Ini (kg)', style: AppTextStyles.body1),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _currentWeightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Contoh: 68',
              prefixIcon: Icon(Icons.monitor_weight_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Target Berat Badan
          Text('Target Berat Badan (kg)', style: AppTextStyles.body1),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _targetWeightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Contoh: 65',
              prefixIcon: Icon(Icons.flag_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Tinggi Badan
          Text('Tinggi Badan (cm)', style: AppTextStyles.body1),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Contoh: 170',
              prefixIcon: Icon(Icons.height_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Jenis Kelamin
          Text('Jenis Kelamin', style: AppTextStyles.body1),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildGenderButton('Laki-laki', Icons.male),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildGenderButton('Perempuan', Icons.female),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Tanggal Lahir
          Text('Tanggal Lahir', style: AppTextStyles.body1),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _birthDate,
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _birthDate = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake_outlined, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}',
                    style: AppTextStyles.body1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGenderButton(String gender, IconData icon) {
    final isSelected = _gender == gender;
    return InkWell(
      onTap: () {
        setState(() {
          _gender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              gender,
              style: AppTextStyles.body1.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target & Tujuan',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Apa tujuan kesehatan Anda?',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: AppSpacing.xl),
          
          Text('Tujuan Utama', style: AppTextStyles.body1),
          const SizedBox(height: AppSpacing.md),
          _buildGoalOption(
            'Menurunkan Berat Badan',
            Icons.trending_down_rounded,
            '🎯',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildGoalOption(
            'Menjaga Berat Badan',
            Icons.favorite_rounded,
            '💚',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildGoalOption(
            'Menaikkan Berat Badan',
            Icons.trending_up_rounded,
            '📈',
          ),
          const SizedBox(height: AppSpacing.xl),
          
          Text('Kecepatan Target', style: AppTextStyles.body1),
          const SizedBox(height: AppSpacing.md),
          _buildPaceOption('Lambat (0.25 kg/minggu)', 'Aman & Berkelanjutan'),
          const SizedBox(height: AppSpacing.sm),
          _buildPaceOption('Sedang (0.5 kg/minggu)', 'Disarankan'),
          const SizedBox(height: AppSpacing.sm),
          _buildPaceOption('Cepat (1 kg/minggu)', 'Memerlukan Disiplin'),
        ],
      ),
    );
  }
  
  Widget _buildGoalOption(String goal, IconData icon, String emoji) {
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
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                goal,
                style: AppTextStyles.body1.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
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
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
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
  
  Widget _buildActivityPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rutinitas Olahraga',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bantu kami menghitung kebutuhan kalori Anda',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: AppSpacing.xl),
          
          Text('Tingkat Aktivitas', style: AppTextStyles.body1),
          const SizedBox(height: AppSpacing.md),
          _buildActivityOption(
            'Sangat Jarang (Tidak pernah olahraga)',
            'Aktivitas harian ringan',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActivityOption(
            'Jarang Berolahraga',
            'Olahraga ringan 1-2x seminggu',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActivityOption(
            'Sedang (3-5x seminggu)',
            'Olahraga teratur',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActivityOption(
            'Aktif (6-7x seminggu)',
            'Olahraga setiap hari',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActivityOption(
            'Sangat Aktif (Atlet)',
            'Latihan intensif 2x sehari',
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
        ],
      ),
    );
  }
  
  Widget _buildActivityOption(String level, String description) {
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
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
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
          color: isSelected ? null : AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
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
