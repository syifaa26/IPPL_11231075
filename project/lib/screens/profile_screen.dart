import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/user_data_service.dart';
import '../theme/app_theme.dart';
import 'weight_history_screen.dart';
import 'edit_profile_screen.dart';
import 'target_goals_screen.dart';
import 'activity_routine_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.currentUser;
    final userDataService = UserDataService();

    // Get user data
    final userId = currentUser?.id ?? 'demo';
    final userProfile = userDataService.getUserProfile(userId);
    final totalCalories = userDataService.getTotalCalories(userId);
    final targetCalories = userDataService.getCalorieTarget(userId);
    final totalProtein = userDataService.getCalorieData(userId).totalProtein;
    final totalCarbs = userDataService.getCalorieData(userId).totalCarbs;
    final streak = userDataService.getCurrentStreak(userId);

    // Cek apakah user sudah lengkap profil
    final hasCompletedProfile = userProfile != null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Avatar and Info
            Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(currentUser?.name ?? 'User'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Name
                Text(
                  currentUser?.name ?? 'User',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),

                // Email
                Text(
                  currentUser?.email ?? 'user@email.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Stats Cards - Vertical Layout
            // Weight Card
            _buildStatCard(
              context: context,
              icon: Icons.monitor_weight_outlined,
              iconColor: AppColors.primary,
              title: 'Berat Badan',
              value: hasCompletedProfile
                  ? '${userProfile.currentWeight.toStringAsFixed(1)} kg'
                  : '- kg',
              subtitle: hasCompletedProfile
                  ? 'Target: ${userProfile.targetWeight.toStringAsFixed(1)} kg'
                  : 'Belum diatur',
              isFullWidth: true,
            ),

            const SizedBox(height: 15),

            // Daily Target Card
            _buildStatCard(
              context: context,
              icon: Icons.local_fire_department_outlined,
              iconColor: AppColors.warning,
              title: 'Target Harian',
              value: '$targetCalories kkal',
              subtitle: hasCompletedProfile
                  ? userProfile.goal
                  : 'Belum ada data',
              isFullWidth: true,
            ),

            const SizedBox(height: 15),

            // Streak Card
            _buildStatCard(
              context: context,
              icon: Icons.emoji_events_outlined,
              iconColor: AppColors.secondary,
              title: 'Streak',
              value: hasCompletedProfile ? '$streak hari' : '0 hari',
              subtitle: hasCompletedProfile
                  ? 'Pencapaian terbaik'
                  : 'Mulai hari ini!',
              isFullWidth: true,
            ),

            const SizedBox(height: 15),

            // Total Calories Today Card
            _buildStatCard(
              context: context,
              icon: Icons.local_dining_outlined,
              iconColor: AppColors.info,
              title: 'Kalori Hari Ini',
              value: '$totalCalories kkal',
              subtitle: 'Protein: ${totalProtein}g | Karbo: ${totalCarbs}g',
              isFullWidth: true,
            ),

            const SizedBox(height: 30),

            // Menu Items
            _buildMenuItem(
              context: context,
              title: 'Edit Profil',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              context: context,
              title: 'Target & Tujuan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TargetGoalsScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              context: context,
              title: 'Rutinitas Olahraga',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ActivityRoutineScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              context: context,
              title: 'Riwayat Berat Badan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WeightHistoryScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              context: context,
              title: 'Pengaturan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              context: context,
              title: 'Tentang Aplikasi',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Nutrix',
                  applicationVersion: '1.0.0',
                  applicationIcon: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  children: [
                    const Text(
                      'Nutrix adalah aplikasi pelacak nutrisi dan kalori yang membantu Anda mencapai tujuan kesehatan.',
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Keluar',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    bool isFullWidth = false,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
    required BuildContext context,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Logout and navigate to auth screen
                final authService = AuthService();
                authService.logout();

                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/auth', (route) => false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Logout berhasil'),
                    backgroundColor: AppColors.primary,
                  ),
                );

                // Exit app after logout
                Future.delayed(const Duration(seconds: 1), () {
                  SystemNavigator.pop();
                });
              },
              child: Text('Keluar', style: TextStyle(color: AppColors.danger)),
            ),
          ],
        );
      },
    );
  }
}
