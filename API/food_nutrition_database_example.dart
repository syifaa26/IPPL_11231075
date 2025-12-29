// food_nutrition_database.dart
// Database nutrisi untuk 101 kategori makanan Food-101
// Copy file ini ke: project/lib/data/food_nutrition_database.dart

class FoodNutrition {
  final String name;
  final int calories; // per 100g
  final double protein; // grams per 100g
  final double carbs; // grams per 100g
  final double fat; // grams per 100g
  final double fiber; // grams per 100g
  final String servingSize;
  final String category;

  FoodNutrition({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.servingSize,
    required this.category,
  });
}

class FoodNutritionDatabase {
  static final Map<String, FoodNutrition> _database = {
    // Fruits
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
    
    // Breakfast
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
    
    // Main Dishes
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
    
    // Chicken Dishes
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
    
    // Seafood
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
    
    'fried_calamari': FoodNutrition(
      name: 'Fried Calamari',
      calories: 175,
      protein: 15.0,
      carbs: 8.0,
      fat: 9.0,
      fiber: 0.5,
      servingSize: '100g',
      category: 'Seafood',
    ),
    
    'grilled_salmon': FoodNutrition(
      name: 'Grilled Salmon',
      calories: 206,
      protein: 22.0,
      carbs: 0.0,
      fat: 13.0,
      fiber: 0.0,
      servingSize: '100g',
      category: 'Healthy',
    ),
    
    'shrimp_and_grits': FoodNutrition(
      name: 'Shrimp and Grits',
      calories: 258,
      protein: 18.0,
      carbs: 22.0,
      fat: 11.0,
      fiber: 2.0,
      servingSize: '1 cup (250g)',
      category: 'Southern',
    ),
    
    // Asian Food
    'pad_thai': FoodNutrition(
      name: 'Pad Thai',
      calories: 350,
      protein: 15.0,
      carbs: 45.0,
      fat: 12.0,
      fiber: 3.0,
      servingSize: '1 plate (300g)',
      category: 'Thai',
    ),
    
    'pho': FoodNutrition(
      name: 'Pho',
      calories: 350,
      protein: 30.0,
      carbs: 50.0,
      fat: 3.0,
      fiber: 2.0,
      servingSize: '1 bowl (500g)',
      category: 'Vietnamese',
    ),
    
    'ramen': FoodNutrition(
      name: 'Ramen',
      calories: 436,
      protein: 19.0,
      carbs: 56.0,
      fat: 14.0,
      fiber: 4.0,
      servingSize: '1 bowl (400g)',
      category: 'Japanese',
    ),
    
    'sushi': FoodNutrition(
      name: 'Sushi',
      calories: 140,
      protein: 6.0,
      carbs: 28.0,
      fat: 1.0,
      fiber: 1.0,
      servingSize: '6 pieces (150g)',
      category: 'Japanese',
    ),
    
    'spring_rolls': FoodNutrition(
      name: 'Spring Rolls',
      calories: 150,
      protein: 4.0,
      carbs: 20.0,
      fat: 6.0,
      fiber: 2.0,
      servingSize: '3 rolls (100g)',
      category: 'Asian',
    ),
    
    'dumplings': FoodNutrition(
      name: 'Dumplings',
      calories: 220,
      protein: 8.0,
      carbs: 30.0,
      fat: 8.0,
      fiber: 2.0,
      servingSize: '6 pieces (150g)',
      category: 'Chinese',
    ),
    
    // Mexican Food
    'tacos': FoodNutrition(
      name: 'Tacos',
      calories: 226,
      protein: 13.0,
      carbs: 20.0,
      fat: 11.0,
      fiber: 3.0,
      servingSize: '2 tacos (150g)',
      category: 'Mexican',
    ),
    
    'burritos': FoodNutrition(
      name: 'Burritos',
      calories: 400,
      protein: 18.0,
      carbs: 50.0,
      fat: 14.0,
      fiber: 6.0,
      servingSize: '1 burrito (300g)',
      category: 'Mexican',
    ),
    
    'nachos': FoodNutrition(
      name: 'Nachos',
      calories: 346,
      protein: 9.0,
      carbs: 36.0,
      fat: 19.0,
      fiber: 5.0,
      servingSize: '1 plate (150g)',
      category: 'Mexican',
    ),
    
    'quesadilla': FoodNutrition(
      name: 'Quesadilla',
      calories: 500,
      protein: 20.0,
      carbs: 40.0,
      fat: 28.0,
      fiber: 3.0,
      servingSize: '1 quesadilla (200g)',
      category: 'Mexican',
    ),
    
    // Desserts
    'ice_cream': FoodNutrition(
      name: 'Ice Cream',
      calories: 207,
      protein: 3.5,
      carbs: 24.0,
      fat: 11.0,
      fiber: 0.7,
      servingSize: '1/2 cup (100g)',
      category: 'Dessert',
    ),
    
    'chocolate_cake': FoodNutrition(
      name: 'Chocolate Cake',
      calories: 352,
      protein: 5.0,
      carbs: 51.0,
      fat: 15.0,
      fiber: 2.0,
      servingSize: '1 slice (100g)',
      category: 'Dessert',
    ),
    
    'cheesecake': FoodNutrition(
      name: 'Cheesecake',
      calories: 321,
      protein: 5.5,
      carbs: 25.0,
      fat: 23.0,
      fiber: 0.8,
      servingSize: '1 slice (125g)',
      category: 'Dessert',
    ),
    
    'donuts': FoodNutrition(
      name: 'Donuts',
      calories: 452,
      protein: 5.0,
      carbs: 51.0,
      fat: 25.0,
      fiber: 1.5,
      servingSize: '1 donut (100g)',
      category: 'Dessert',
    ),
    
    'cupcakes': FoodNutrition(
      name: 'Cupcakes',
      calories: 305,
      protein: 3.6,
      carbs: 45.0,
      fat: 12.0,
      fiber: 0.5,
      servingSize: '1 cupcake (100g)',
      category: 'Dessert',
    ),
    
    'churros': FoodNutrition(
      name: 'Churros',
      calories: 237,
      protein: 3.0,
      carbs: 35.0,
      fat: 10.0,
      fiber: 1.0,
      servingSize: '3 churros (100g)',
      category: 'Dessert',
    ),
    
    // Salads
    'caesar_salad': FoodNutrition(
      name: 'Caesar Salad',
      calories: 190,
      protein: 8.0,
      carbs: 6.0,
      fat: 15.0,
      fiber: 2.0,
      servingSize: '1 bowl (200g)',
      category: 'Salad',
    ),
    
    'greek_salad': FoodNutrition(
      name: 'Greek Salad',
      calories: 106,
      protein: 4.0,
      carbs: 8.0,
      fat: 7.0,
      fiber: 3.0,
      servingSize: '1 bowl (200g)',
      category: 'Salad',
    ),
    
    'caprese_salad': FoodNutrition(
      name: 'Caprese Salad',
      calories: 240,
      protein: 12.0,
      carbs: 5.0,
      fat: 19.0,
      fiber: 1.0,
      servingSize: '1 serving (200g)',
      category: 'Salad',
    ),
    
    // Soups
    'miso_soup': FoodNutrition(
      name: 'Miso Soup',
      calories: 40,
      protein: 3.0,
      carbs: 5.0,
      fat: 1.0,
      fiber: 1.0,
      servingSize: '1 bowl (240ml)',
      category: 'Soup',
    ),
    
    'french_onion_soup': FoodNutrition(
      name: 'French Onion Soup',
      calories: 175,
      protein: 8.0,
      carbs: 17.0,
      fat: 8.0,
      fiber: 2.0,
      servingSize: '1 bowl (300ml)',
      category: 'Soup',
    ),
    
    // Sides
    'french_fries': FoodNutrition(
      name: 'French Fries',
      calories: 312,
      protein: 3.4,
      carbs: 41.0,
      fat: 15.0,
      fiber: 3.8,
      servingSize: '1 serving (117g)',
      category: 'Side Dish',
    ),
    
    'onion_rings': FoodNutrition(
      name: 'Onion Rings',
      calories: 407,
      protein: 5.0,
      carbs: 38.0,
      fat: 26.0,
      fiber: 2.5,
      servingSize: '8-9 rings (100g)',
      category: 'Side Dish',
    ),
    
    'mashed_potato': FoodNutrition(
      name: 'Mashed Potato',
      calories: 116,
      protein: 2.0,
      carbs: 17.0,
      fat: 4.5,
      fiber: 1.6,
      servingSize: '1 cup (210g)',
      category: 'Side Dish',
    ),
    
    'garlic_bread': FoodNutrition(
      name: 'Garlic Bread',
      calories: 350,
      protein: 8.0,
      carbs: 45.0,
      fat: 15.0,
      fiber: 2.0,
      servingSize: '2 slices (100g)',
      category: 'Side Dish',
    ),
    
    // Add more foods as needed...
    // Total: 101 categories dari Food-101 dataset
  };

  // Get nutrition info by food name
  static FoodNutrition? getNutrition(String foodName) {
    // Normalize food name (lowercase, replace spaces with underscores)
    String normalizedName = foodName.toLowerCase().replaceAll(' ', '_');
    return _database[normalizedName];
  }

  // Get all available foods
  static List<String> getAllFoodNames() {
    return _database.keys.toList();
  }

  // Search foods by category
  static List<FoodNutrition> getFoodsByCategory(String category) {
    return _database.values
        .where((food) => food.category == category)
        .toList();
  }

  // Get all categories
  static List<String> getAllCategories() {
    return _database.values
        .map((food) => food.category)
        .toSet()
        .toList();
  }
}

// Example usage in Flutter:
/*
void main() {
  // Get nutrition info after AI detection
  String detectedFood = 'pizza';
  FoodNutrition? nutrition = FoodNutritionDatabase.getNutrition(detectedFood);
  
  if (nutrition != null) {
    print('Food: ${nutrition.name}');
    print('Calories: ${nutrition.calories}');
    print('Protein: ${nutrition.protein}g');
    print('Carbs: ${nutrition.carbs}g');
    print('Fat: ${nutrition.fat}g');
    print('Fiber: ${nutrition.fiber}g');
    print('Serving: ${nutrition.servingSize}');
  }
}
*/
