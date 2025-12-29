import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'notification_sync_screen.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final notificationService = NotificationService();

  Future<void> _selectTime(BuildContext context, String meal) async {
    TimeOfDay initialTime;
    switch (meal) {
      case 'breakfast':
        initialTime = notificationService.breakfastTime;
        break;
      case 'lunch':
        initialTime = notificationService.lunchTime;
        break;
      case 'dinner':
        initialTime = notificationService.dinnerTime;
        break;
      default:
        initialTime = const TimeOfDay(hour: 12, minute: 0);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        switch (meal) {
          case 'breakfast':
            notificationService.setBreakfastTime(picked);
            break;
          case 'lunch':
            notificationService.setLunchTime(picked);
            break;
          case 'dinner':
            notificationService.setDinnerTime(picked);
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
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
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Aktifkan notifikasi untuk mengingatkan Anda mencatat makanan',
                style: AppTextStyles.body2,
              ),
            ),
            
            // Master toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadow.small,
              ),
              child: SwitchListTile(
                title: Text(
                  'Aktifkan Notifikasi',
                  style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Master pengaturan semua notifikasi'),
                value: notificationService.isEnabled,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    notificationService.setEnabled(value);
                  });
                },
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Pengingat Makan',
                style: AppTextStyles.h4.copyWith(color: AppColors.primary),
              ),
            ),
            
            // Breakfast reminder
            _buildMealReminderCard(
              icon: Icons.wb_sunny_outlined,
              iconColor: Colors.orange,
              title: 'Sarapan',
              subtitle: 'Pagi hari',
              time: notificationService.breakfastTime,
              isEnabled: notificationService.breakfastReminder,
              onToggle: (value) {
                setState(() {
                  notificationService.setBreakfastReminder(value);
                });
              },
              onTimePressed: () => _selectTime(context, 'breakfast'),
            ),
            
            // Lunch reminder
            _buildMealReminderCard(
              icon: Icons.wb_sunny,
              iconColor: Colors.yellow.shade700,
              title: 'Makan Siang',
              subtitle: 'Siang hari',
              time: notificationService.lunchTime,
              isEnabled: notificationService.lunchReminder,
              onToggle: (value) {
                setState(() {
                  notificationService.setLunchReminder(value);
                });
              },
              onTimePressed: () => _selectTime(context, 'lunch'),
            ),
            
            // Dinner reminder
            _buildMealReminderCard(
              icon: Icons.nightlight_outlined,
              iconColor: Colors.indigo,
              title: 'Makan Malam',
              subtitle: 'Malam hari',
              time: notificationService.dinnerTime,
              isEnabled: notificationService.dinnerReminder,
              onToggle: (value) {
                setState(() {
                  notificationService.setDinnerReminder(value);
                });
              },
              onTimePressed: () => _selectTime(context, 'dinner'),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Pengingat Lainnya',
                style: AppTextStyles.h4.copyWith(color: AppColors.primary),
              ),
            ),
            
            // Water reminder
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadow.small,
              ),
              child: SwitchListTile(
                secondary: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop_outlined,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Pengingat Minum Air',
                  style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Setiap 2 jam sekali'),
                value: notificationService.waterReminder,
                activeColor: AppColors.primary,
                onChanged: notificationService.isEnabled
                    ? (value) {
                        setState(() {
                          notificationService.setWaterReminder(value);
                        });
                      }
                    : null,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Sync Settings Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSyncScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.cloud_sync),
                label: const Text('Sinkronisasi Antar Perangkat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Info box
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
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
                      'Notifikasi membantu Anda tetap konsisten dalam mencatat makanan dan mencapai target kesehatan',
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
  
  Widget _buildMealReminderCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required bool isEnabled,
    required Function(bool) onToggle,
    required VoidCallback onTimePressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.small,
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(subtitle),
            value: isEnabled,
            activeColor: AppColors.primary,
            onChanged: notificationService.isEnabled ? onToggle : null,
          ),
          if (isEnabled && notificationService.isEnabled)
            InkWell(
              onTap: onTimePressed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Waktu: ${time.format(context)}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
