class Food {
  final String name;
  final double calories; // per 100g
  final double protein; // per 100g
  final double carbs; // per 100g
  final double fat; // per 100g
  final String category; // 'protein', 'vegetable', 'fruit', 'grain', 'dairy'

  Food({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'category': category,
    };
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0.0,
      protein: map['protein'] ?? 0.0,
      carbs: map['carbs'] ?? 0.0,
      fat: map['fat'] ?? 0.0,
      category: map['category'] ?? '',
    );
  }
}

class Meal {
  final String name; // 'Kahvaltı', 'Öğle Yemeği', 'Akşam Yemeği', 'Ara Öğün'
  final List<FoodItem> foods;
  final double totalCalories;

  Meal({
    required this.name,
    required this.foods,
    required this.totalCalories,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'foods': foods.map((food) => food.toMap()).toList(),
      'totalCalories': totalCalories,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'] ?? '',
      foods: List<FoodItem>.from(
        map['foods']?.map((food) => FoodItem.fromMap(food)) ?? [],
      ),
      totalCalories: map['totalCalories'] ?? 0.0,
    );
  }
}

class FoodItem {
  final Food food;
  final double amount; 
  final double calories;

  FoodItem({
    required this.food,
    required this.amount,
    required this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'food': food.toMap(),
      'amount': amount,
      'calories': calories,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      food: Food.fromMap(map['food'] ?? {}),
      amount: map['amount'] ?? 0.0,
      calories: map['calories'] ?? 0.0,
    );
  }
}

class DayMealPlan {
  final String dayName;
  final List<Meal> meals;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  DayMealPlan({
    required this.dayName,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  Map<String, dynamic> toMap() {
    return {
      'dayName': dayName,
      'meals': meals.map((meal) => meal.toMap()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }

  factory DayMealPlan.fromMap(Map<String, dynamic> map) {
    return DayMealPlan(
      dayName: map['dayName'] ?? '',
      meals: List<Meal>.from(
        map['meals']?.map((meal) => Meal.fromMap(meal)) ?? [],
      ),
      totalCalories: map['totalCalories'] ?? 0.0,
      totalProtein: map['totalProtein'] ?? 0.0,
      totalCarbs: map['totalCarbs'] ?? 0.0,
      totalFat: map['totalFat'] ?? 0.0,
    );
  }
}

class DietProgram {
  final String id;
  final String name;
  final String description;
  final List<DayMealPlan> weekPlan;
  final double dailyCalorieTarget;
  final String goal; // 'weight_loss', 'muscle_gain', 'maintenance'
  final DateTime createdAt;

  DietProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.weekPlan,
    required this.dailyCalorieTarget,
    required this.goal,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'weekPlan': weekPlan.map((day) => day.toMap()).toList(),
      'dailyCalorieTarget': dailyCalorieTarget,
      'goal': goal,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DietProgram.fromMap(Map<String, dynamic> map) {
    return DietProgram(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      weekPlan: List<DayMealPlan>.from(
        map['weekPlan']?.map((day) => DayMealPlan.fromMap(day)) ?? [],
      ),
      dailyCalorieTarget: map['dailyCalorieTarget'] ?? 0.0,
      goal: map['goal'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Generate personalized diet program
  static DietProgram generateDietProgram(
    String userId,
    String fitnessGoal,
    double dailyCalories,
    double bmi,
  ) {
    String programName;
    String description;
    double targetCalories;

    switch (fitnessGoal) {
      case 'lose_weight':
        programName = 'Kilo Verme Diyeti';
        description = 'Sağlıklı kilo kaybı için kalori açığı oluşturan beslenme programı';
        targetCalories = dailyCalories * 0.8; // 20% kalori açığı
        break;
      case 'gain_weight':
        programName = 'Kilo Alma Diyeti';
        description = 'Sağlıklı kilo alımı ve kas geliştirme için beslenme programı';
        targetCalories = dailyCalories * 1.15; // 15% kalori fazlası
        break;
      case 'maintain':
        programName = 'Denge Diyeti';
        description = 'Mevcut kiloyu korumak için dengeli beslenme programı';
        targetCalories = dailyCalories;
        break;
      default:
        programName = 'Sağlıklı Beslenme Programı';
        description = 'Genel sağlık için dengeli beslenme programı';
        targetCalories = dailyCalories;
    }

    List<DayMealPlan> weekPlan = _generateWeeklyMealPlan(targetCalories, fitnessGoal);

    return DietProgram(
      id: '${userId}_diet_${DateTime.now().millisecondsSinceEpoch}',
      name: programName,
      description: description,
      weekPlan: weekPlan,
      dailyCalorieTarget: targetCalories,
      goal: fitnessGoal,
      createdAt: DateTime.now(),
    );
  }

  static List<DayMealPlan> _generateWeeklyMealPlan(double targetCalories, String goal) {
    List<String> days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    List<DayMealPlan> weekPlan = [];

    for (String day in days) {
      List<Meal> meals = _generateDayMeals(targetCalories, goal);
      double totalCalories = meals.fold(0, (sum, meal) => sum + meal.totalCalories);
      
      weekPlan.add(DayMealPlan(
        dayName: day,
        meals: meals,
        totalCalories: totalCalories,
        totalProtein: totalCalories * 0.25 / 4, // 25% protein
        totalCarbs: totalCalories * 0.45 / 4, // 45% carbs
        totalFat: totalCalories * 0.30 / 9, // 30% fat
      ));
    }

    return weekPlan;
  }

  static List<Meal> _generateDayMeals(double targetCalories, String goal) {
    // Calorie distribution
    double breakfastCalories = targetCalories * 0.25;
    double lunchCalories = targetCalories * 0.35;
    double dinnerCalories = targetCalories * 0.30;
    double snackCalories = targetCalories * 0.10;

    return [
      _generateBreakfast(breakfastCalories, goal),
      _generateLunch(lunchCalories, goal),
      _generateDinner(dinnerCalories, goal),
      _generateSnack(snackCalories, goal),
    ];
  }

  static Meal _generateBreakfast(double calories, String goal) {
    List<FoodItem> foods = [];
    
    if (goal == 'lose_weight') {
      foods = [
        FoodItem(
          food: Food(name: 'Yulaf Ezmesi', calories: 68, protein: 2.4, carbs: 12, fat: 1.4, category: 'grain'),
          amount: 50,
          calories: 34,
        ),
        FoodItem(
          food: Food(name: 'Yaban Mersini', calories: 57, protein: 0.7, carbs: 14, fat: 0.3, category: 'fruit'),
          amount: 100,
          calories: 57,
        ),
        FoodItem(
          food: Food(name: 'Badem Sütü', calories: 17, protein: 0.6, carbs: 0.6, fat: 1.1, category: 'dairy'),
          amount: 200,
          calories: 34,
        ),
        FoodItem(
          food: Food(name: 'Bal', calories: 304, protein: 0.3, carbs: 82, fat: 0, category: 'grain'),
          amount: 15,
          calories: 46,
        ),
      ];
    } else if (goal == 'gain_weight') {
      foods = [
        FoodItem(
          food: Food(name: 'Tam Buğday Ekmeği', calories: 247, protein: 13, carbs: 41, fat: 4.2, category: 'grain'),
          amount: 100,
          calories: 247,
        ),
        FoodItem(
          food: Food(name: 'Avokado', calories: 160, protein: 2, carbs: 9, fat: 15, category: 'fruit'),
          amount: 100,
          calories: 160,
        ),
        FoodItem(
          food: Food(name: 'Yumurta', calories: 155, protein: 13, carbs: 1.1, fat: 11, category: 'protein'),
          amount: 100,
          calories: 155,
        ),
      ];
    } else {
      foods = [
        FoodItem(
          food: Food(name: 'Yulaf Ezmesi', calories: 68, protein: 2.4, carbs: 12, fat: 1.4, category: 'grain'),
          amount: 60,
          calories: 41,
        ),
        FoodItem(
          food: Food(name: 'Muz', calories: 89, protein: 1.1, carbs: 23, fat: 0.3, category: 'fruit'),
          amount: 100,
          calories: 89,
        ),
        FoodItem(
          food: Food(name: 'Süt', calories: 42, protein: 3.4, carbs: 5, fat: 1, category: 'dairy'),
          amount: 200,
          calories: 84,
        ),
      ];
    }

    double totalMealCalories = foods.fold(0, (sum, food) => sum + food.calories);
    
    return Meal(
      name: 'Kahvaltı',
      foods: foods,
      totalCalories: totalMealCalories,
    );
  }

  static Meal _generateLunch(double calories, String goal) {
    List<FoodItem> foods = [];
    
    if (goal == 'lose_weight') {
      foods = [
        FoodItem(
          food: Food(name: 'Izgara Tavuk Göğsü', calories: 165, protein: 31, carbs: 0, fat: 3.6, category: 'protein'),
          amount: 150,
          calories: 248,
        ),
        FoodItem(
          food: Food(name: 'Kinoa', calories: 120, protein: 4.4, carbs: 22, fat: 1.9, category: 'grain'),
          amount: 100,
          calories: 120,
        ),
        FoodItem(
          food: Food(name: 'Karışık Salata', calories: 20, protein: 1, carbs: 4, fat: 0.2, category: 'vegetable'),
          amount: 200,
          calories: 40,
        ),
        FoodItem(
          food: Food(name: 'Zeytinyağı', calories: 884, protein: 0, carbs: 0, fat: 100, category: 'fat'),
          amount: 10,
          calories: 88,
        ),
      ];
    } else if (goal == 'gain_weight') {
      foods = [
        FoodItem(
          food: Food(name: 'Somon', calories: 208, protein: 25, carbs: 0, fat: 12, category: 'protein'),
          amount: 200,
          calories: 416,
        ),
        FoodItem(
          food: Food(name: 'Pirinç', calories: 130, protein: 2.7, carbs: 28, fat: 0.3, category: 'grain'),
          amount: 150,
          calories: 195,
        ),
        FoodItem(
          food: Food(name: 'Brokoli', calories: 34, protein: 2.8, carbs: 7, fat: 0.4, category: 'vegetable'),
          amount: 150,
          calories: 51,
        ),
        FoodItem(
          food: Food(name: 'Fındık', calories: 628, protein: 15, carbs: 17, fat: 61, category: 'fat'),
          amount: 30,
          calories: 188,
        ),
      ];
    } else {
      foods = [
        FoodItem(
          food: Food(name: 'Izgara Balık', calories: 206, protein: 22, carbs: 0, fat: 12, category: 'protein'),
          amount: 150,
          calories: 309,
        ),
        FoodItem(
          food: Food(name: 'Bulgur', calories: 83, protein: 3, carbs: 19, fat: 0.2, category: 'grain'),
          amount: 100,
          calories: 83,
        ),
        FoodItem(
          food: Food(name: 'Karışık Sebze', calories: 25, protein: 1.2, carbs: 5, fat: 0.3, category: 'vegetable'),
          amount: 200,
          calories: 50,
        ),
      ];
    }

    double totalMealCalories = foods.fold(0, (sum, food) => sum + food.calories);
    
    return Meal(
      name: 'Öğle Yemeği',
      foods: foods,
      totalCalories: totalMealCalories,
    );
  }

  static Meal _generateDinner(double calories, String goal) {
    List<FoodItem> foods = [];
    
    if (goal == 'lose_weight') {
      foods = [
        FoodItem(
          food: Food(name: 'Izgara Sebze', calories: 35, protein: 1.5, carbs: 7, fat: 0.4, category: 'vegetable'),
          amount: 300,
          calories: 105,
        ),
        FoodItem(
          food: Food(name: 'Mercimek Çorbası', calories: 116, protein: 9, carbs: 20, fat: 0.4, category: 'protein'),
          amount: 200,
          calories: 232,
        ),
        FoodItem(
          food: Food(name: 'Yoğurt', calories: 59, protein: 10, carbs: 3.6, fat: 0.4, category: 'dairy'),
          amount: 150,
          calories: 89,
        ),
      ];
    } else if (goal == 'gain_weight') {
      foods = [
        FoodItem(
          food: Food(name: 'Kırmızı Et', calories: 250, protein: 26, carbs: 0, fat: 17, category: 'protein'),
          amount: 150,
          calories: 375,
        ),
        FoodItem(
          food: Food(name: 'Tatlı Patates', calories: 86, protein: 1.6, carbs: 20, fat: 0.1, category: 'vegetable'),
          amount: 200,
          calories: 172,
        ),
        FoodItem(
          food: Food(name: 'Salata', calories: 20, protein: 1, carbs: 4, fat: 0.2, category: 'vegetable'),
          amount: 150,
          calories: 30,
        ),
      ];
    } else {
      foods = [
        FoodItem(
          food: Food(name: 'Tavuk Çorbası', calories: 75, protein: 7, carbs: 5, fat: 3, category: 'protein'),
          amount: 250,
          calories: 188,
        ),
        FoodItem(
          food: Food(name: 'Sebze Yemeği', calories: 50, protein: 2, carbs: 10, fat: 1, category: 'vegetable'),
          amount: 200,
          calories: 100,
        ),
        FoodItem(
          food: Food(name: 'Cacık', calories: 20, protein: 1.5, carbs: 2, fat: 1, category: 'dairy'),
          amount: 150,
          calories: 30,
        ),
      ];
    }

    double totalMealCalories = foods.fold(0, (sum, food) => sum + food.calories);
    
    return Meal(
      name: 'Akşam Yemeği',
      foods: foods,
      totalCalories: totalMealCalories,
    );
  }

  static Meal _generateSnack(double calories, String goal) {
    List<FoodItem> foods = [];
    
    if (goal == 'lose_weight') {
      foods = [
        FoodItem(
          food: Food(name: 'Elma', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, category: 'fruit'),
          amount: 150,
          calories: 78,
        ),
        FoodItem(
          food: Food(name: 'Badem', calories: 579, protein: 21, carbs: 22, fat: 50, category: 'fat'),
          amount: 20,
          calories: 116,
        ),
      ];
    } else if (goal == 'gain_weight') {
      foods = [
        FoodItem(
          food: Food(name: 'Protein Smoothie', calories: 150, protein: 20, carbs: 15, fat: 3, category: 'protein'),
          amount: 250,
          calories: 375,
        ),
      ];
    } else {
      foods = [
        FoodItem(
          food: Food(name: 'Meyve Salatası', calories: 50, protein: 1, carbs: 12, fat: 0.3, category: 'fruit'),
          amount: 150,
          calories: 75,
        ),
        FoodItem(
          food: Food(name: 'Ceviz', calories: 654, protein: 15, carbs: 14, fat: 65, category: 'fat'),
          amount: 15,
          calories: 98,
        ),
      ];
    }

    double totalMealCalories = foods.fold(0, (sum, food) => sum + food.calories);
    
    return Meal(
      name: 'Ara Öğün',
      foods: foods,
      totalCalories: totalMealCalories,
    );
  }
}