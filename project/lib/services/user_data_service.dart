import 'package:flutter/material.dart';

class UserDataService extends ChangeNotifier {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  // Data kalori per user
  final Map<String, UserCalorieData> _userCalorieData = {};
  
  // Data profil user
  final Map<String, UserProfile> _userProfiles = {};
  
  // Data riwayat berat badan
  final Map<String, List<WeightRecord>> _weightHistory = {};
  
  // Get calorie data for specific user
  UserCalorieData getCalorieData(String userId) {
    if (!_userCalorieData.containsKey(userId)) {
      _userCalorieData[userId] = UserCalorieData();
    }
    return _userCalorieData[userId]!;
  }

  // Add meal for user
  void addMeal(String userId, Meal meal) {
    if (!_userCalorieData.containsKey(userId)) {
      _userCalorieData[userId] = UserCalorieData();
    }
    _userCalorieData[userId]!.addMeal(meal);
    notifyListeners();
  }

  // Get meals for user
  List<Meal> getMeals(String userId) {
    if (!_userCalorieData.containsKey(userId)) {
      return [];
    }
    return _userCalorieData[userId]!.meals;
  }

  // Get total calories for user
  int getTotalCalories(String userId) {
    if (!_userCalorieData.containsKey(userId)) {
      return 0;
    }
    return _userCalorieData[userId]!.totalCalories;
  }

  // Set calorie target
  void setCalorieTarget(String userId, int target) {
    if (!_userCalorieData.containsKey(userId)) {
      _userCalorieData[userId] = UserCalorieData();
    }
    _userCalorieData[userId]!.targetCalories = target;
    notifyListeners();
  }

  // Get calorie target
  int getCalorieTarget(String userId) {
    if (!_userCalorieData.containsKey(userId)) {
      return 2000; // Default target
    }
    return _userCalorieData[userId]!.targetCalories;
  }

  // Get remaining calories
  int getRemainingCalories(String userId) {
    return getCalorieTarget(userId) - getTotalCalories(userId);
  }

  // Clear user data (for testing)
  void clearUserData(String userId) {
    _userCalorieData.remove(userId);
    notifyListeners();
  }
  
  // Save user profile
  void saveUserProfile({
    required String userId,
    required double currentWeight,
    required double targetWeight,
    required double height,
    required String gender,
    required DateTime birthDate,
    required String goal,
    required String targetPace,
    required String activityLevel,
    required int exerciseFrequency,
    required int dailyCaloriesTarget,
  }) {
    _userProfiles[userId] = UserProfile(
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      height: height,
      gender: gender,
      birthDate: birthDate,
      goal: goal,
      targetPace: targetPace,
      activityLevel: activityLevel,
      exerciseFrequency: exerciseFrequency,
      dailyCaloriesTarget: dailyCaloriesTarget,
    );
    
    // Set calorie target
    setCalorieTarget(userId, dailyCaloriesTarget);
    
    // Add initial weight record
    addWeightRecord(userId, currentWeight);
    
    notifyListeners();
  }
  
  // Get user profile
  UserProfile? getUserProfile(String userId) {
    return _userProfiles[userId];
  }
  
  // Update current weight
  void updateCurrentWeight(String userId, double weight) {
    if (_userProfiles.containsKey(userId)) {
      _userProfiles[userId]!.currentWeight = weight;
      addWeightRecord(userId, weight);
      notifyListeners();
    }
  }
  
  // Add weight record
  void addWeightRecord(String userId, double weight) {
    if (!_weightHistory.containsKey(userId)) {
      _weightHistory[userId] = [];
    }
    _weightHistory[userId]!.add(WeightRecord(
      date: DateTime.now(),
      weight: weight,
    ));
    notifyListeners();
  }
  
  // Get weight history
  List<WeightRecord> getWeightHistory(String userId) {
    return _weightHistory[userId] ?? [];
  }
  
  // Get weight progress (difference from start)
  double? getWeightProgress(String userId) {
    final history = getWeightHistory(userId);
    if (history.isEmpty) return null;
    
    final startWeight = history.first.weight;
    final currentWeight = history.last.weight;
    return currentWeight - startWeight;
  }
  
  // Get current streak (consecutive days with meals logged)
  int getCurrentStreak(String userId) {
    // For simplicity, just return days since join date
    // In real app, would check meal logging history
    final profile = getUserProfile(userId);
    if (profile == null) return 0;
    
    final daysSinceJoin = DateTime.now().difference(profile.joinDate).inDays;
    return daysSinceJoin;
  }
  
  // Get nutrition stats for specific date
  NutritionStats getDailyNutritionStats(String userId, DateTime date) {
    final meals = getMeals(userId);
    final dailyMeals = meals.where((meal) {
      // Parse time string to DateTime for comparison
      try {
        final mealDateTime = DateTime.parse(meal.time);
        return mealDateTime.year == date.year &&
            mealDateTime.month == date.month &&
            mealDateTime.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();
    
    return NutritionStats(
      date: date,
      meals: dailyMeals,
      totalCalories: dailyMeals.fold(0, (sum, meal) => sum + meal.calories),
      totalProtein: dailyMeals.fold(0, (sum, meal) => sum + meal.protein),
      totalCarbs: dailyMeals.fold(0, (sum, meal) => sum + meal.carbs),
      totalFat: dailyMeals.fold(0, (sum, meal) => sum + meal.fat),
    );
  }
  
  // Get weekly nutrition stats
  List<NutritionStats> getWeeklyNutritionStats(String userId, DateTime startDate) {
    final stats = <NutritionStats>[];
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      stats.add(getDailyNutritionStats(userId, date));
    }
    return stats;
  }
  
  // Get average nutrition for a week
  NutritionStats getWeeklyAverageStats(String userId, DateTime startDate) {
    final weeklyStats = getWeeklyNutritionStats(userId, startDate);
    final daysWithData = weeklyStats.where((s) => s.meals.isNotEmpty).length;
    
    if (daysWithData == 0) {
      return NutritionStats(
        date: startDate,
        meals: [],
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
      );
    }
    
    final totalCalories = weeklyStats.fold(0, (sum, s) => sum + s.totalCalories);
    final totalProtein = weeklyStats.fold(0, (sum, s) => sum + s.totalProtein);
    final totalCarbs = weeklyStats.fold(0, (sum, s) => sum + s.totalCarbs);
    final totalFat = weeklyStats.fold(0, (sum, s) => sum + s.totalFat);
    
    return NutritionStats(
      date: startDate,
      meals: [],
      totalCalories: totalCalories ~/ daysWithData,
      totalProtein: totalProtein ~/ daysWithData,
      totalCarbs: totalCarbs ~/ daysWithData,
      totalFat: totalFat ~/ daysWithData,
    );
  }
  
  // Daily Notes Management
  final Map<String, Map<String, String>> _dailyNotes = {};
  
  // Save daily notes
  void saveDailyNotes(String userId, DateTime date, String notes) {
    if (!_dailyNotes.containsKey(userId)) {
      _dailyNotes[userId] = {};
    }
    final dateKey = '${date.year}-${date.month}-${date.day}';
    _dailyNotes[userId]![dateKey] = notes;
    notifyListeners();
  }
  
  // Get daily notes
  String getDailyNotes(String userId, DateTime date) {
    if (!_dailyNotes.containsKey(userId)) {
      return '';
    }
    final dateKey = '${date.year}-${date.month}-${date.day}';
    return _dailyNotes[userId]![dateKey] ?? '';
  }
  
  // Check if has notes on date
  bool hasNotesOnDate(String userId, DateTime date) {
    final notes = getDailyNotes(userId, date);
    return notes.isNotEmpty;
  }
  
  // Check if has meals on date
  bool hasMealsOnDate(String userId, DateTime date) {
    final meals = getMealsForDate(userId, date);
    return meals.isNotEmpty;
  }
  
  // Get meals for specific date
  List<Meal> getMealsForDate(String userId, DateTime date) {
    final meals = getMeals(userId);
    return meals.where((meal) {
      try {
        final mealDateTime = DateTime.parse(meal.time);
        return mealDateTime.year == date.year &&
            mealDateTime.month == date.month &&
            mealDateTime.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }
}

class UserCalorieData {
  List<Meal> meals = [];
  int targetCalories = 2000;

  int get totalCalories {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  int get totalProtein {
    return meals.fold(0, (sum, meal) => sum + meal.protein);
  }

  int get totalCarbs {
    return meals.fold(0, (sum, meal) => sum + meal.carbs);
  }

  int get totalFat {
    return meals.fold(0, (sum, meal) => sum + meal.fat);
  }

  void addMeal(Meal meal) {
    meals.add(meal);
  }

  void removeMeal(int index) {
    if (index >= 0 && index < meals.length) {
      meals.removeAt(index);
    }
  }
}

// User Profile Model
class UserProfile {
  double currentWeight;
  double targetWeight;
  double height;
  String gender;
  DateTime birthDate;
  String goal;
  String targetPace;
  String activityLevel;
  int exerciseFrequency;
  int dailyCaloriesTarget;
  DateTime joinDate;

  UserProfile({
    required this.currentWeight,
    required this.targetWeight,
    required this.height,
    required this.gender,
    required this.birthDate,
    required this.goal,
    required this.targetPace,
    required this.activityLevel,
    required this.exerciseFrequency,
    required this.dailyCaloriesTarget,
    DateTime? joinDate,
  }) : joinDate = joinDate ?? DateTime.now();
}

// Weight Record Model
class WeightRecord {
  final DateTime date;
  final double weight;

  WeightRecord({
    required this.date,
    required this.weight,
  });
}

class Meal {
  final String name;
  final String type; // Sarapan, Makan Siang, Makan Malam, Camilan
  final String time;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String>? components; // daftar komponen/topping jika merupakan makanan gabungan

  Meal({
    required this.name,
    required this.type,
    required this.time,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.components,
  });
}

// Nutrition Statistics Model
class NutritionStats {
  final DateTime date;
  final List<Meal> meals;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;

  NutritionStats({
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });
}
