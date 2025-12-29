import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_data_service.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentWeightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _gender = 'Laki-laki';
  DateTime _birthDate = DateTime(2000, 1, 1);
  
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
        _currentWeightController.text = profile.currentWeight.toStringAsFixed(1);
        _targetWeightController.text = profile.targetWeight.toStringAsFixed(1);
        _heightController.text = profile.height.toStringAsFixed(0);
        _gender = profile.gender;
        _birthDate = profile.birthDate;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
  
  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
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
    
    final authService = AuthService();
    final userId = authService.currentUser?.id ?? 'demo';
    final userDataService = UserDataService();
    final currentProfile = userDataService.getUserProfile(userId);
    
    if (currentProfile != null) {
      // Update existing profile
      userDataService.saveUserProfile(
        userId: userId,
        currentWeight: currentWeight,
        targetWeight: targetWeight,
        height: height,
        gender: _gender,
        birthDate: _birthDate,
        goal: currentProfile.goal,
        targetPace: currentProfile.targetPace,
        activityLevel: currentProfile.activityLevel,
        exerciseFrequency: currentProfile.exerciseFrequency,
        dailyCaloriesTarget: currentProfile.dailyCaloriesTarget,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Pribadi',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Perbarui informasi pribadi Anda',
                      style: AppTextStyles.body2,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Berat Badan Saat Ini
                    Text('Berat Badan Saat Ini (kg)', style: AppTextStyles.body1),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _currentWeightController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wajib diisi';
                        }
                        final number = double.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Masukkan nilai yang valid';
                        }
                        return null;
                      },
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
                    TextFormField(
                      controller: _targetWeightController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wajib diisi';
                        }
                        final number = double.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Masukkan nilai yang valid';
                        }
                        return null;
                      },
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
                    TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wajib diisi';
                        }
                        final number = double.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Masukkan nilai yang valid';
                        }
                        return null;
                      },
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
              ),
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
}
