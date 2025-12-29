import 'package:flutter/material.dart';
import 'notification_sync_service.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _initializeSync();
  }
  
  final NotificationSyncService _syncService = NotificationSyncService();

  bool _isEnabled = true;
  bool _breakfastReminder = true;
  bool _lunchReminder = true;
  bool _dinnerReminder = true;
  bool _waterReminder = false;
  
  TimeOfDay _breakfastTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 19, minute: 0);
  
  String? _currentUserId;
  
  bool get isEnabled => _isEnabled;
  bool get breakfastReminder => _breakfastReminder;
  bool get lunchReminder => _lunchReminder;
  bool get dinnerReminder => _dinnerReminder;
  bool get waterReminder => _waterReminder;
  
  TimeOfDay get breakfastTime => _breakfastTime;
  TimeOfDay get lunchTime => _lunchTime;
  TimeOfDay get dinnerTime => _dinnerTime;
  
  NotificationSyncService get syncService => _syncService;
  
  /// Initialize sync service
  Future<void> _initializeSync() async {
    await _syncService.initialize();
  }
  
  /// Set current user for syncing
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    _loadSyncedSettings();
  }
  
  /// Load synced settings
  Future<void> _loadSyncedSettings() async {
    if (_currentUserId == null) return;
    
    final prefs = await _syncService.loadSyncedPreferences(_currentUserId!);
    if (prefs != null) {
      _isEnabled = prefs['isEnabled'] ?? true;
      _breakfastReminder = prefs['breakfastReminder'] ?? true;
      _lunchReminder = prefs['lunchReminder'] ?? true;
      _dinnerReminder = prefs['dinnerReminder'] ?? true;
      _waterReminder = prefs['waterReminder'] ?? false;
      notifyListeners();
    }
    
    final times = await _syncService.loadSyncedReminderTimes(_currentUserId!);
    if (times != null) {
      _breakfastTime = times['breakfast'] ?? _breakfastTime;
      _lunchTime = times['lunch'] ?? _lunchTime;
      _dinnerTime = times['dinner'] ?? _dinnerTime;
      notifyListeners();
    }
  }
  
  /// Sync current settings
  Future<void> _syncSettings() async {
    if (_currentUserId == null) return;
    
    await _syncService.syncNotificationPreferences(
      _currentUserId!,
      isEnabled: _isEnabled,
      breakfastReminder: _breakfastReminder,
      lunchReminder: _lunchReminder,
      dinnerReminder: _dinnerReminder,
      waterReminder: _waterReminder,
    );
    
    await _syncService.syncReminderTimes(_currentUserId!, {
      'breakfast': _breakfastTime,
      'lunch': _lunchTime,
      'dinner': _dinnerTime,
    });
  }
  
  void setEnabled(bool value) {
    _isEnabled = value;
    notifyListeners();
    _syncSettings();
  }
  
  void setBreakfastReminder(bool value) {
    _breakfastReminder = value;
    notifyListeners();
    _syncSettings();
  }
  
  void setLunchReminder(bool value) {
    _lunchReminder = value;
    notifyListeners();
    _syncSettings();
  }
  
  void setDinnerReminder(bool value) {
    _dinnerReminder = value;
    notifyListeners();
    _syncSettings();
  }
  
  void setWaterReminder(bool value) {
    _waterReminder = value;
    notifyListeners();
    _syncSettings();
  }
  
  void setBreakfastTime(TimeOfDay time) {
    _breakfastTime = time;
    notifyListeners();
    _syncSettings();
  }
  
  void setLunchTime(TimeOfDay time) {
    _lunchTime = time;
    notifyListeners();
    _syncSettings();
  }
  
  void setDinnerTime(TimeOfDay time) {
    _dinnerTime = time;
    notifyListeners();
    _syncSettings();
  }
}
