import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/notification_sync_service.dart';
import '../services/auth_service.dart';

class NotificationSyncScreen extends StatefulWidget {
  const NotificationSyncScreen({super.key});

  @override
  State<NotificationSyncScreen> createState() => _NotificationSyncScreenState();
}

class _NotificationSyncScreenState extends State<NotificationSyncScreen> {
  final NotificationSyncService _syncService = NotificationSyncService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);

    final userId = _authService.currentUser?.id ?? 'demo';
    _devices = await _syncService.getSyncedDevices(userId);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sinkronisasi Notifikasi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _syncService,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sync Status Card
                _buildSyncStatusCard(),

                const SizedBox(height: 20),

                // Sync Toggle
                _buildSyncToggle(),

                const SizedBox(height: 20),

                // Sync Actions
                _buildSyncActions(),

                const SizedBox(height: 30),

                // Devices List
                _buildDevicesSection(),

                const SizedBox(height: 20),

                // Info Section
                _buildInfoSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSyncStatusCard() {
    final statusMessage = _syncService.getSyncStatusMessage();
    final isActive = _syncService.isSyncEnabled;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isActive ? AppColors.primaryGradient : null,
        color: isActive ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isActive ? Icons.cloud_done : Icons.cloud_off,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            isActive ? 'Sinkronisasi Aktif' : 'Sinkronisasi Nonaktif',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            statusMessage,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          if (_syncService.isSyncing)
            const Padding(
              padding: EdgeInsets.only(top: 15),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSyncToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.sync, color: AppColors.primary),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sinkronisasi Otomatis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sinkronkan pengaturan di semua perangkat',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _syncService.isSyncEnabled,
            onChanged: (value) {
              _syncService.setSyncEnabled(value);
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSyncActions() {
    final userId = _authService.currentUser?.id ?? 'demo';

    return Column(
      children: [
        // Sync Now Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _syncService.isSyncing
                ? null
                : () async {
                    await _syncService.syncNow();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sinkronisasi berhasil!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.refresh),
            label: const Text('Sinkronkan Sekarang'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Clear Sync Data Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Data Sinkronisasi?'),
                  content: const Text(
                    'Ini akan menghapus data sinkronisasi dari perangkat ini. '
                    'Pengaturan lokal Anda tidak akan terpengaruh.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _syncService.clearSyncData(userId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data sinkronisasi dihapus')),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Hapus Data Sinkronisasi'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: BorderSide(color: AppColors.danger),
              foregroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDevicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perangkat Tersinkronisasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_devices.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'Belum ada perangkat tersinkronisasi',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ..._devices.map((device) => _buildDeviceCard(device)),
      ],
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final isActive = device['isActive'] as bool;
    final lastSync = device['lastSync'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isActive ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone_android,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            size: 32,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device['deviceName'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastSync != null
                      ? 'Sinkronisasi: ${_formatDate(lastSync)}'
                      : 'Belum pernah sinkronisasi',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Aktif',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: 10),
              Text(
                'Tentang Sinkronisasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            '• Pengaturan notifikasi akan disinkronkan otomatis ke semua perangkat Anda\n'
            '• Data disimpan secara lokal dan aman\n'
            '• Anda dapat menonaktifkan sinkronisasi kapan saja\n'
            '• Perubahan akan terlihat di semua perangkat dalam beberapa menit',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) {
        return 'Baru saja';
      } else if (diff.inHours < 1) {
        return '${diff.inMinutes} menit yang lalu';
      } else if (diff.inDays < 1) {
        return '${diff.inHours} jam yang lalu';
      } else {
        return '${diff.inDays} hari yang lalu';
      }
    } catch (e) {
      return 'Tidak diketahui';
    }
  }
}
