// food_nutrition_database.dart
// Database nutrisi (example). Copied from API folder.

class FoodNutrition {
  final String name;
  final int calories; // per 100g
  final double protein; // grams per 100g
  final double carbs; // grams per 100g
  final double fat; // grams per 100g
  final double fiber; // grams per 100g
  final String servingSize;
  final String category;
  final String? description;

  FoodNutrition({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.servingSize,
    required this.category,
    this.description,
  });
}

class FoodNutritionDatabase {
  static final Map<String, FoodNutrition> _database = {
    'apple_pie': FoodNutrition(
      name: 'Apple Pie',
      calories: 237,
      protein: 2.4,
      carbs: 34.0,
      fat: 11.0,
      fiber: 1.6,
      servingSize: '1 slice (125g)',
      category: 'Dessert',
    ),
    'breakfast_burrito': FoodNutrition(
      name: 'Breakfast Burrito',
      calories: 300,
      protein: 14.0,
      carbs: 28.0,
      fat: 14.0,
      fiber: 3.0,
      servingSize: '1 burrito (200g)',
      category: 'Breakfast',
    ),
    'french_toast': FoodNutrition(
      name: 'French Toast',
      calories: 216,
      protein: 7.0,
      carbs: 28.0,
      fat: 8.5,
      fiber: 1.0,
      servingSize: '2 slices (135g)',
      category: 'Breakfast',
    ),
    'pancakes': FoodNutrition(
      name: 'Pancakes',
      calories: 227,
      protein: 6.0,
      carbs: 28.0,
      fat: 9.0,
      fiber: 1.0,
      servingSize: '3 pancakes (150g)',
      category: 'Breakfast',
    ),
    'waffles': FoodNutrition(
      name: 'Waffles',
      calories: 291,
      protein: 7.0,
      carbs: 33.0,
      fat: 14.0,
      fiber: 1.5,
      servingSize: '1 waffle (75g)',
      category: 'Breakfast',
    ),
    'hamburger': FoodNutrition(
      name: 'Hamburger',
      calories: 295,
      protein: 17.0,
      carbs: 25.0,
      fat: 14.0,
      fiber: 1.5,
      servingSize: '1 burger (200g)',
      category: 'Fast Food',
    ),
    'hot_dog': FoodNutrition(
      name: 'Hot Dog',
      calories: 290,
      protein: 10.0,
      carbs: 24.0,
      fat: 17.0,
      fiber: 1.0,
      servingSize: '1 hot dog (150g)',
      category: 'Fast Food',
    ),
    'pizza': FoodNutrition(
      name: 'Pizza',
      calories: 266,
      protein: 11.0,
      carbs: 33.0,
      fat: 10.0,
      fiber: 2.3,
      servingSize: '1 slice (107g)',
      category: 'Fast Food',
    ),
    'spaghetti_bolognese': FoodNutrition(
      name: 'Spaghetti Bolognese',
      calories: 151,
      protein: 8.0,
      carbs: 20.0,
      fat: 4.0,
      fiber: 2.0,
      servingSize: '1 cup (250g)',
      category: 'Italian',
    ),
    'spaghetti_carbonara': FoodNutrition(
      name: 'Spaghetti Carbonara',
      calories: 346,
      protein: 14.0,
      carbs: 35.0,
      fat: 16.0,
      fiber: 2.0,
      servingSize: '1 cup (250g)',
      category: 'Italian',
    ),
    'lasagna': FoodNutrition(
      name: 'Lasagna',
      calories: 135,
      protein: 8.0,
      carbs: 14.0,
      fat: 5.0,
      fiber: 2.0,
      servingSize: '1 piece (215g)',
      category: 'Italian',
    ),
    'ravioli': FoodNutrition(
      name: 'Ravioli',
      calories: 175,
      protein: 7.0,
      carbs: 28.0,
      fat: 4.0,
      fiber: 2.5,
      servingSize: '1 cup (250g)',
      category: 'Italian',
    ),
    'chicken_curry': FoodNutrition(
      name: 'Chicken Curry',
      calories: 180,
      protein: 15.0,
      carbs: 10.0,
      fat: 10.0,
      fiber: 2.0,
      servingSize: '1 cup (250g)',
      category: 'Indian',
    ),
    'chicken_wings': FoodNutrition(
      name: 'Chicken Wings',
      calories: 290,
      protein: 24.0,
      carbs: 10.0,
      fat: 18.0,
      fiber: 0.5,
      servingSize: '6 wings (180g)',
      category: 'Fast Food',
    ),
    'fried_chicken': FoodNutrition(
      name: 'Fried Chicken',
      calories: 320,
      protein: 21.0,
      carbs: 14.0,
      fat: 20.0,
      fiber: 0.5,
      servingSize: '1 piece (140g)',
      category: 'Fast Food',
    ),
    'grilled_chicken': FoodNutrition(
      name: 'Grilled Chicken',
      calories: 165,
      protein: 31.0,
      carbs: 0.0,
      fat: 3.6,
      fiber: 0.0,
      servingSize: '100g',
      category: 'Healthy',
    ),
    'fish_and_chips': FoodNutrition(
      name: 'Fish and Chips',
      calories: 333,
      protein: 13.0,
      carbs: 30.0,
      fat: 18.0,
      fiber: 2.5,
      servingSize: '1 serving (250g)',
      category: 'British',
    ),
    'grilled_salmon': FoodNutrition(
      name: 'Grilled Salmon',
      calories: 206,
      protein: 22.0,
      carbs: 0.0,
      fat: 12.0,
      fiber: 0.0,
      servingSize: '100g',
      category: 'Seafood',
    ),
    'ramen': FoodNutrition(
      name: 'Ramen',
      calories: 436,
      protein: 12.0,
      carbs: 60.0,
      fat: 12.0,
      fiber: 3.0,
      servingSize: '1 bowl (500g)',
      category: 'Japanese',
    ),
    'sushi': FoodNutrition(
      name: 'Sushi',
      calories: 140,
      protein: 6.0,
      carbs: 28.0,
      fat: 1.0,
      fiber: 1.0,
      servingSize: '6 pieces',
      category: 'Japanese',
    ),
    'tacos': FoodNutrition(
      name: 'Tacos',
      calories: 226,
      protein: 12.0,
      carbs: 25.0,
      fat: 10.0,
      fiber: 3.0,
      servingSize: '2 tacos (200g)',
      category: 'Mexican',
    ),
    'burritos': FoodNutrition(
      name: 'Burritos',
      calories: 400,
      protein: 18.0,
      carbs: 45.0,
      fat: 12.0,
      fiber: 4.0,
      servingSize: '1 burrito (300g)',
      category: 'Mexican',
    ),
    'nachos': FoodNutrition(
      name: 'Nachos',
      calories: 346,
      protein: 8.0,
      carbs: 42.0,
      fat: 15.0,
      fiber: 4.0,
      servingSize: '1 plate (200g)',
      category: 'Snack',
    ),
    // Extended entries (common foods / synonyms)
    'mango': FoodNutrition(
      name: 'Mango',
      calories: 60,
      protein: 0.8,
      carbs: 15.0,
      fat: 0.4,
      fiber: 1.6,
      servingSize: '100g',
      category: 'Fruit',
    ),
    'banana': FoodNutrition(
      name: 'Banana',
      calories: 89,
      protein: 1.1,
      carbs: 23.0,
      fat: 0.3,
      fiber: 2.6,
      servingSize: '100g',
      category: 'Fruit',
    ),
    'pepperoni': FoodNutrition(
      name: 'Pepperoni',
      calories: 494,
      protein: 23.0,
      carbs: 4.0,
      fat: 44.0,
      fiber: 0.0,
      servingSize: '100g',
      category: 'Meat',
    ),
    'salad': FoodNutrition(
      name: 'Salad',
      calories: 33,
      protein: 2.0,
      carbs: 7.0,
      fat: 0.3,
      fiber: 2.0,
      servingSize: '100g (mixed greens)',
      category: 'Vegetable',
    ),
  };

  static final Map<String, String> _synonyms = {
    'bell_pepper': 'pepperoni', // example mapping (adjust if needed)
    'red_pepper': 'pepperoni',
    'green_pepper': 'pepperoni',
    'paprika': 'pepperoni',
    'mangga': 'mango',
  };

  static FoodNutrition? getNutrition(String foodName) {
    String base = foodName.toLowerCase().trim();
    base = base.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    base = base.replaceAll(RegExp(r'\s+'), ' ');
    // plural simplifications
    if (base.endsWith('es') && base.length > 4) {
      base = base.substring(0, base.length - 2);
    } else if (base.endsWith('s') && base.length > 3) {
      base = base.substring(0, base.length - 1);
    }
    final key = base.replaceAll(' ', '_');
    if (_database.containsKey(key)) return _database[key];
    final alt = _synonyms[key];
    if (alt != null && _database.containsKey(alt)) return _database[alt];
    return null;
  }

  /// Tambahkan entri nutrisi dinamis (misal dari API). Override jika sudah ada.
  static void addDynamic(String rawName, Map<String, dynamic> data) {
    final nut = FoodNutrition(
      name: rawName,
      calories: (data['calories'] as num?)?.round() ?? 0,
      protein: (data['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (data['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (data['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: 0.0,
      servingSize: '100g',
      category: 'API',
      description: data['description'] as String?,
    );
    String key = rawName.toLowerCase().trim();
    key = key.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    key = key.replaceAll(RegExp(r'\s+'), ' ');
    if (key.endsWith('es') && key.length > 4) {
      key = key.substring(0, key.length - 2);
    } else if (key.endsWith('s') && key.length > 3) {
      key = key.substring(0, key.length - 1);
    }
    key = key.replaceAll(' ', '_');
    _database[key] = nut;
  }
}
