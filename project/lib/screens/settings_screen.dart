import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/user_data_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart' show AuthScreen;
import 'notification_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'change_password_screen.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userDataService = UserDataService();
    final userId = authService.currentUser?.id ?? 'demo';
    final notificationService = NotificationService();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Akun'),
            _buildSettingItem(
              context,
              icon: Icons.person_outline,
              title: 'Informasi Akun',
              subtitle: authService.currentUser?.email ?? '-',
              onTap: () {
                // Show account info
                _showAccountInfo(context);
              },
            ),
            _buildSettingItem(
              context,
              icon: Icons.lock_outline,
              title: 'Ubah Password',
              subtitle: 'Ubah kata sandi akun Anda',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            
            const Divider(height: 40),
            
            // App Settings
            _buildSectionHeader('Pengaturan Aplikasi'),
            // Dark Mode Toggle
            _buildSettingToggleItem(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'Mode Gelap',
              subtitle: 'Sesuaikan tampilan terang/gelap',
              value: ThemeService().isDarkMode,
              onChanged: (value) async {
                await ThemeService().setDarkMode(value);
                setState(() {});
              },
            ),
            _buildSettingItem(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              subtitle: notificationService.isEnabled 
                  ? 'Aktif - ${_getActiveRemindersCount(notificationService)} pengingat'
                  : 'Tidak aktif',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
            _buildSettingItem(
              context,
              icon: Icons.language_outlined,
              title: 'Bahasa',
              subtitle: 'Bahasa Indonesia',
              onTap: () {
                _showLanguageDialog(context);
              },
            ),
            
            const Divider(height: 40),
            
            // Data & Privacy
            _buildSectionHeader('Data & Privasi'),
            _buildSettingItem(
              context,
              icon: Icons.download_outlined,
              title: 'Ekspor Data',
              subtitle: 'Download data nutrisi Anda',
              onTap: () {
                _showExportDialog(context, userId, userDataService);
              },
            ),
            _buildSettingItem(
              context,
              icon: Icons.delete_outline,
              title: 'Hapus Data',
              subtitle: 'Reset semua data kalori',
              onTap: () {
                _confirmDeleteData(context, userId, userDataService);
              },
              isDestructive: true,
            ),
            
            const Divider(height: 40),
            
            // About
            _buildSectionHeader('Tentang'),
            _buildSettingItem(
              context,
              icon: Icons.info_outline,
              title: 'Tentang Nutrix',
              subtitle: 'Versi 1.0.0',
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
                  children: const [
                    Text(
                      'Nutrix adalah aplikasi pelacak nutrisi dan kalori yang membantu Anda mencapai tujuan kesehatan dengan teknologi AI.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Dibuat dengan ❤️ untuk kesehatan Anda.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                );
              },
            ),
            _buildSettingItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Kebijakan Privasi',
              subtitle: 'Baca kebijakan privasi kami',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            _buildSettingItem(
              context,
              icon: Icons.description_outlined,
              title: 'Syarat & Ketentuan',
              subtitle: 'Baca syarat penggunaan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TermsConditionsScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _confirmLogout(context, authService);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.h4.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
  
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.small,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1) 
                : AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingToggleItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.small,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption,
        ),
        trailing: Switch(
          value: value,
          activeColor: AppColors.primary,
          onChanged: (val) async {
            await ThemeService().setDarkMode(val);
            setState(() {});
          },
        ),
        onTap: () async {
          await ThemeService().toggleDarkMode();
          setState(() {});
        },
      ),
    );
  }
  
  void _showAccountInfo(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informasi Akun'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Nama', user?.name ?? '-'),
            const SizedBox(height: 12),
            _buildInfoRow('Email', user?.email ?? '-'),
            const SizedBox(height: 12),
            _buildInfoRow('User ID', user?.id ?? '-'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  void _confirmDeleteData(
    BuildContext context,
    String userId,
    UserDataService userDataService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua data kalori? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              userDataService.clearUserData(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data berhasil dihapus'),
                  backgroundColor: Color.fromRGBO(76, 158, 175, 1),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  int _getActiveRemindersCount(NotificationService service) {
    int count = 0;
    if (service.breakfastReminder) count++;
    if (service.lunchReminder) count++;
    if (service.dinnerReminder) count++;
    if (service.waterReminder) count++;
    return count;
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇮🇩', style: TextStyle(fontSize: 24)),
              title: const Text('Bahasa Indonesia'),
              trailing: Icon(Icons.check, color: Colors.green[700]),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              enabled: false,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(
    BuildContext context,
    String userId,
    UserDataService userDataService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ekspor Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih format ekspor data:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV'),
              subtitle: const Text('Data dalam format tabel'),
              onTap: () {
                Navigator.pop(context);
                _exportDataAsCSV(context, userId, userDataService);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON'),
              subtitle: const Text('Data dalam format JSON'),
              onTap: () {
                Navigator.pop(context);
                _exportDataAsJSON(context, userId, userDataService);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportDataAsCSV(
    BuildContext context,
    String userId,
    UserDataService userDataService,
  ) {
    final meals = userDataService.getMeals(userId);
    if (meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diekspor')),
      );
      return;
    }

    // Generate CSV content
    String csv = 'Tanggal,Waktu,Nama,Jenis,Kalori,Protein,Karbohidrat,Lemak\n';
    for (var meal in meals) {
      csv += '${meal.time.toString().split(' ')[0]},'
          '${meal.time.toString().split(' ')[1].split('.')[0]},'
          '${meal.name},${meal.type},${meal.calories},'
          '${meal.protein},${meal.carbs},${meal.fat}\n';
    }

    // Show preview dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data CSV'),
        content: SingleChildScrollView(
          child: SelectableText(
            csv,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('CSV data berhasil dibuat (${meals.length} baris)'),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'Salin',
                    textColor: Colors.white,
                    onPressed: () {
                      // Copy to clipboard functionality would go here
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _exportDataAsJSON(
    BuildContext context,
    String userId,
    UserDataService userDataService,
  ) {
    final meals = userDataService.getMeals(userId);
    if (meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diekspor')),
      );
      return;
    }

    // Generate JSON content
    final jsonData = {
      'user_id': userId,
      'export_date': DateTime.now().toIso8601String(),
      'total_meals': meals.length,
      'meals': meals.map((meal) => {
        'date': meal.time.toString().split(' ')[0],
        'time': meal.time.toString().split(' ')[1].split('.')[0],
        'name': meal.name,
        'type': meal.type,
        'calories': meal.calories,
        'protein': meal.protein,
        'carbs': meal.carbs,
        'fat': meal.fat,
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

    // Show preview dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data JSON'),
        content: SingleChildScrollView(
          child: SelectableText(
            jsonString,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('JSON data berhasil dibuat (${meals.length} makanan)'),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'Salin',
                    textColor: Colors.white,
                    onPressed: () {
                      // Copy to clipboard functionality would go here
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }
  
  void _confirmLogout(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              authService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
              
              // Exit app after logout
              Future.delayed(const Duration(seconds: 1), () {
                SystemNavigator.pop();
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
