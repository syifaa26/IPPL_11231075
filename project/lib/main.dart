import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/camera_detection_modal.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/landing_page.dart';
import 'services/auth_service.dart';
import 'services/user_data_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NutrixApp());
}

class NutrixApp extends StatefulWidget {
  const NutrixApp({super.key});

  @override
  State<NutrixApp> createState() => _NutrixAppState();
}

class _NutrixAppState extends State<NutrixApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    // Ensure theme is loaded once app starts
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    // Trigger initial theme load (only once)
    _themeService;

    return AnimatedBuilder(
      animation: _themeService,
      builder: (context, _) {
        return MaterialApp(
          title: 'Nutrix',
          themeMode: _themeService.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              background: AppColors.background,
            ),
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: 'SF Pro Display',
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.textPrimary),
            ),
            cardTheme: CardThemeData(
              color: AppColors.card,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                textStyle: AppTextStyles.button,
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              background: AppColors.darkBackground,
            ),
            scaffoldBackgroundColor: AppColors.darkBackground,
            fontFamily: 'SF Pro Display',
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
            ),
            cardTheme: CardThemeData(
              color: AppColors.darkCard,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                textStyle: AppTextStyles.button,
              ),
            ),
          ),
          debugShowCheckedModeBanner: false,
          routes: {'/home': (_) => const NutrixHome()},
          home: Builder(
            builder: (innerContext) {
              return LandingPage(
                onGetStarted: () {
                  Navigator.of(innerContext).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class NutrixHome extends StatefulWidget {
  const NutrixHome({super.key});

  @override
  State<NutrixHome> createState() => _NutrixHomeState();
}

// Beranda utama aplikasi Nutrix
class _NutrixHomeState extends State<NutrixHome> {
  int _selectedIndex = 0;
  late final UserDataService _userDataService; // listen for changes

  void _onDataChanged() {
    if (mounted) setState(() {}); // trigger rebuild when meals change
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _userDataService = UserDataService();
    _userDataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _userDataService.removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header with Gradient & Better Design
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xxl),
                  bottomRight: Radius.circular(AppRadius.xxl),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutrix',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getGreeting(),
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textWhite.withOpacity(0.95),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _selectedIndex == 1
                            ? Icons.bar_chart_rounded
                            : Icons.restaurant_menu_rounded,
                        color: AppColors.textWhite,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main Content
            Expanded(
              child: _selectedIndex == 0
                  ? _buildHomeContent()
                  : _selectedIndex == 1
                  ? const StatisticsScreen()
                  : _buildProfileContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: AppShadow.medium),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Statistik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: AppColors.card,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.caption,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi! 🌅';
    } else if (hour < 17) {
      return 'Selamat Siang! ☀️';
    } else if (hour < 19) {
      return 'Selamat Sore! 🌤️';
    } else {
      return 'Selamat Malam! 🌙';
    }
  }

  // Format waktu jadi HH:MM saja
  String _formatTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      final match = RegExp(r'(\d{2}:\d{2})').firstMatch(raw);
      return match?.group(1) ?? raw;
    }
  }

  Widget _buildHomeContent() {
    final authService = AuthService();
    final currentUser = authService.currentUser;
    final userDataService = _userDataService; // use listening instance

    // Get user data
    final userId = currentUser?.id ?? 'demo';
    final totalCalories = userDataService.getTotalCalories(userId);
    final targetCalories = userDataService.getCalorieTarget(userId);
    final remainingCalories = userDataService.getRemainingCalories(userId);
    final totalProtein = userDataService.getCalorieData(userId).totalProtein;
    final totalCarbs = userDataService.getCalorieData(userId).totalCarbs;
    final meals = userDataService.getMeals(userId);

    // Calculate progress
    final progress = targetCalories > 0
        ? (totalCalories / targetCalories).clamp(0.0, 1.0)
        : 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Centered calorie headline
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: totalCalories.toString(),
                        style: AppTextStyles.number.copyWith(
                          color: AppColors.textWhite,
                          fontSize: 56,
                        ),
                      ),
                      TextSpan(
                        text: ' / $targetCalories',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textWhite.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'kkal',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textWhite.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Centered progress bar with subtle glow
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      color: AppColors.textWhite.withOpacity(0.25),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          color: AppColors.textWhite,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textWhite.withOpacity(0.35),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Macros row centered
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildModernMacroItem(
                      Icons.emoji_events_rounded,
                      remainingCalories.toString(),
                      'Sisa',
                      AppColors.textWhite,
                    ),
                    _buildModernMacroItem(
                      Icons.fitness_center_rounded,
                      '${totalProtein}g',
                      'Protein',
                      AppColors.textWhite,
                    ),
                    _buildModernMacroItem(
                      Icons.bakery_dining_rounded,
                      '${totalCarbs}g',
                      'Karbo',
                      AppColors.textWhite,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Tombol tambah makanan
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const CameraDetectionModal(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.textWhite,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tambah Makanan',
                    style: AppTextStyles.button.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Daftar makanan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Makanan Hari Ini', style: AppTextStyles.h3),
                    if (meals.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${meals.length} item',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                meals.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xl,
                            horizontal: AppSpacing.lg,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu_rounded,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Belum ada makanan hari ini',
                                style: AppTextStyles.body1.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "Tambah Makanan" untuk memulai',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: meals.length,
                        itemBuilder: (context, index) {
                          return _buildMealItem(meals[index]);
                        },
                      ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return const ProfileScreen();
  }

  Widget _buildModernMacroItem(
    IconData icon,
    String value,
    String label,
    Color textColor,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: textColor.withOpacity(0.8)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: textColor.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMealItem(Meal meal) {
    Color typeColor;
    IconData typeIcon;
    switch (meal.type) {
      case 'Sarapan':
        typeColor = const Color(0xFFFF9F43);
        typeIcon = Icons.wb_sunny_rounded;
        break;
      case 'Makan Siang':
        typeColor = AppColors.secondary;
        typeIcon = Icons.lunch_dining_rounded;
        break;
      case 'Makan Malam':
        typeColor = const Color(0xFF5F27CD);
        typeIcon = Icons.dinner_dining_rounded;
        break;
      default:
        typeColor = AppColors.accent;
        typeIcon = Icons.fastfood_rounded;
    }

    final timeOnly = _formatTime(meal.time);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          builder: (ctx) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(meal.name, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeOnly,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Chip(
                          label: Text(meal.type),
                          backgroundColor: typeColor.withOpacity(0.15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kalori: ${meal.calories} kkal',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _macroPill('Protein', meal.protein, Colors.deepPurple),
                        _macroPill('Karbo', meal.carbs, Colors.blue),
                        _macroPill('Lemak', meal.fat, Colors.orange),
                      ],
                    ),
                    if (meal.components != null &&
                        meal.components!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Komponen',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: -4,
                        children: meal.components!
                            .map(
                              (c) => Chip(label: Text(c.replaceAll('_', ' '))),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadow.small,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(typeIcon, color: typeColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meal.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [typeColor, typeColor.withOpacity(0.75)],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          meal.type,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeOnly,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    meal.calories.toString(),
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'kkal',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
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

  Widget _macroPill(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 6),
          Text(
            '$label: $value g',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
