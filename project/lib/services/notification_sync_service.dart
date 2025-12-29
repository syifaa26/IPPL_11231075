import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service untuk mengelola sinkronisasi notifikasi antar perangkat
/// Menggunakan SharedPreferences dengan ID unik per user
class NotificationSyncService extends ChangeNotifier {
  static final NotificationSyncService _instance =
      NotificationSyncService._internal();
  factory NotificationSyncService() => _instance;
  NotificationSyncService._internal();

  static const String _keyPrefix = 'notification_sync_';
  static const String _keySyncEnabled = 'sync_enabled';
  static const String _keyLastSync = 'last_sync_time';
  static const String _keyDeviceId = 'device_id';

  SharedPreferences? _prefs;
  bool _isSyncEnabled = true;
  DateTime? _lastSyncTime;
  String? _deviceId;

  // Status sinkronisasi
  bool _isSyncing = false;
  String _syncStatus = 'Idle';

  bool get isSyncEnabled => _isSyncEnabled;
  bool get isSyncing => _isSyncing;
  String get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get deviceId => _deviceId;

  /// Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    await _generateDeviceId();
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    _isSyncEnabled = _prefs?.getBool(_keySyncEnabled) ?? true;

    final lastSyncString = _prefs?.getString(_keyLastSync);
    if (lastSyncString != null) {
      _lastSyncTime = DateTime.tryParse(lastSyncString);
    }

    notifyListeners();
  }

  /// Generate atau load device ID
  Future<void> _generateDeviceId() async {
    _deviceId = _prefs?.getString(_keyDeviceId);
    if (_deviceId == null) {
      _deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await _prefs?.setString(_keyDeviceId, _deviceId!);
    }
  }

  /// Enable/disable sync
  Future<void> setSyncEnabled(bool enabled) async {
    _isSyncEnabled = enabled;
    await _prefs?.setBool(_keySyncEnabled, enabled);
    notifyListeners();

    if (enabled) {
      await syncNow();
    }
  }

  /// Sync notification settings untuk user tertentu
  Future<void> syncNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    if (!_isSyncEnabled) return;

    _isSyncing = true;
    _syncStatus = 'Syncing...';
    notifyListeners();

    try {
      // Save to local storage with user ID
      final key = '$_keyPrefix${userId}_settings';
      await _prefs?.setString(
        key,
        json.encode({
          'settings': settings,
          'syncTime': DateTime.now().toIso8601String(),
          'deviceId': _deviceId,
        }),
      );

      _lastSyncTime = DateTime.now();
      await _prefs?.setString(_keyLastSync, _lastSyncTime!.toIso8601String());

      // Simulate cloud sync delay
      await Future.delayed(const Duration(milliseconds: 500));

      _syncStatus = 'Synced';
    } catch (e) {
      _syncStatus = 'Error: ${e.toString()}';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Load notification settings dari sinkronisasi
  Future<Map<String, dynamic>?> loadSyncedSettings(String userId) async {
    if (!_isSyncEnabled) return null;

    try {
      final key = '$_keyPrefix${userId}_settings';
      final data = _prefs?.getString(key);

      if (data != null) {
        final decoded = json.decode(data) as Map<String, dynamic>;
        return decoded['settings'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('Error loading synced settings: $e');
    }

    return null;
  }

  /// Sync reminder times untuk user
  Future<void> syncReminderTimes(
    String userId,
    Map<String, TimeOfDay> times,
  ) async {
    if (!_isSyncEnabled) return;

    final serializedTimes = times.map(
      (key, time) => MapEntry(key, {'hour': time.hour, 'minute': time.minute}),
    );

    await syncNotificationSettings(userId, {
      'reminderTimes': serializedTimes,
      'type': 'reminder_times',
    });
  }

  /// Load synced reminder times
  Future<Map<String, TimeOfDay>?> loadSyncedReminderTimes(String userId) async {
    final settings = await loadSyncedSettings(userId);

    if (settings != null && settings['type'] == 'reminder_times') {
      final reminderTimes = settings['reminderTimes'] as Map<String, dynamic>?;

      if (reminderTimes != null) {
        return reminderTimes.map((key, value) {
          final timeData = value as Map<String, dynamic>;
          return MapEntry(
            key,
            TimeOfDay(
              hour: timeData['hour'] as int,
              minute: timeData['minute'] as int,
            ),
          );
        });
      }
    }

    return null;
  }

  /// Sync notification preferences
  Future<void> syncNotificationPreferences(
    String userId, {
    required bool isEnabled,
    required bool breakfastReminder,
    required bool lunchReminder,
    required bool dinnerReminder,
    required bool waterReminder,
  }) async {
    await syncNotificationSettings(userId, {
      'type': 'preferences',
      'isEnabled': isEnabled,
      'breakfastReminder': breakfastReminder,
      'lunchReminder': lunchReminder,
      'dinnerReminder': dinnerReminder,
      'waterReminder': waterReminder,
    });
  }

  /// Load synced notification preferences
  Future<Map<String, bool>?> loadSyncedPreferences(String userId) async {
    final settings = await loadSyncedSettings(userId);

    if (settings != null && settings['type'] == 'preferences') {
      return {
        'isEnabled': settings['isEnabled'] as bool? ?? true,
        'breakfastReminder': settings['breakfastReminder'] as bool? ?? true,
        'lunchReminder': settings['lunchReminder'] as bool? ?? true,
        'dinnerReminder': settings['dinnerReminder'] as bool? ?? true,
        'waterReminder': settings['waterReminder'] as bool? ?? false,
      };
    }

    return null;
  }

  /// Force sync now
  Future<void> syncNow() async {
    if (!_isSyncEnabled) return;

    _isSyncing = true;
    _syncStatus = 'Force syncing...';
    notifyListeners();

    try {
      // Simulate sync with cloud
      await Future.delayed(const Duration(seconds: 1));

      _lastSyncTime = DateTime.now();
      await _prefs?.setString(_keyLastSync, _lastSyncTime!.toIso8601String());

      _syncStatus = 'Synced successfully';
    } catch (e) {
      _syncStatus = 'Sync failed: ${e.toString()}';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Get all synced devices untuk user
  Future<List<Map<String, dynamic>>> getSyncedDevices(String userId) async {
    // Dalam implementasi real, ini akan query dari cloud
    // Untuk sekarang, return current device saja
    return [
      {
        'deviceId': _deviceId,
        'deviceName': 'This Device',
        'lastSync': _lastSyncTime?.toIso8601String(),
        'isActive': true,
      },
    ];
  }

  /// Clear sync data
  Future<void> clearSyncData(String userId) async {
    final key = '$_keyPrefix${userId}_settings';
    await _prefs?.remove(key);
    _lastSyncTime = null;
    _syncStatus = 'Cleared';
    notifyListeners();
  }

  /// Check if settings are synced (berbeda dari device)
  Future<bool> hasUnsyncedChanges(
    String userId,
    Map<String, dynamic> currentSettings,
  ) async {
    final synced = await loadSyncedSettings(userId);
    if (synced == null) return true;

    // Compare settings
    return json.encode(currentSettings) != json.encode(synced);
  }

  /// Get sync status message
  String getSyncStatusMessage() {
    if (!_isSyncEnabled) {
      return 'Sinkronisasi dinonaktifkan';
    }

    if (_isSyncing) {
      return 'Menyinkronkan...';
    }

    if (_lastSyncTime != null) {
      final diff = DateTime.now().difference(_lastSyncTime!);
      if (diff.inMinutes < 1) {
        return 'Baru saja disinkronkan';
      } else if (diff.inHours < 1) {
        return 'Disinkronkan ${diff.inMinutes} menit yang lalu';
      } else if (diff.inDays < 1) {
        return 'Disinkronkan ${diff.inHours} jam yang lalu';
      } else {
        return 'Disinkronkan ${diff.inDays} hari yang lalu';
      }
    }

    return 'Belum pernah disinkronkan';
  }
}
