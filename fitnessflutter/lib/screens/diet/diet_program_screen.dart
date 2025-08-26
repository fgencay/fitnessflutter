import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fitness_provider.dart';
import '../../models/diet_model.dart';

class DietProgramScreen extends StatefulWidget {
  const DietProgramScreen({super.key});

  @override
  State<DietProgramScreen> createState() => _DietProgramScreenState();
}

class _DietProgramScreenState extends State<DietProgramScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadDietProgram();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDietProgram() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await fitnessProvider.loadFitnessData(authProvider.currentUser!.id);
    }
  }

  void _generateNewDietProgram() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    final user = authProvider.currentUser;
    final bmi = fitnessProvider.currentBMI;
    
    if (user != null && bmi != null) {
      await fitnessProvider.generateDietProgram(user, bmi);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yeni diyet programınız oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Önce BMI hesaplayın'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diyet Programı'),
        backgroundColor: Colors.purple,
        actions: [
          Consumer<FitnessProvider>(
            builder: (context, fitnessProvider, child) {
              return IconButton(
                icon: fitnessProvider.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh),
                onPressed: fitnessProvider.isLoading ? null : _generateNewDietProgram,
                tooltip: 'Yeni Program Oluştur',
              );
            },
          ),
        ],
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, fitnessProvider, child) {
          final dietProgram = fitnessProvider.currentDietProgram;
          
          if (dietProgram == null) {
            return _buildEmptyState();
          }
          
          return _buildDietProgram(dietProgram);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 60,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz diyet programınız yok',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Kişiye özel beslenme programı oluşturmak için önce BMI hesaplamanızı yapın',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Consumer<FitnessProvider>(
              builder: (context, fitnessProvider, child) {
                return ElevatedButton.icon(
                  onPressed: fitnessProvider.isLoading ? null : _generateNewDietProgram,
                  icon: fitnessProvider.isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    fitnessProvider.isLoading 
                        ? 'Program Oluşturuluyor...' 
                        : 'Program Oluştur',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietProgram(DietProgram program) {
    return Column(
      children: [
        _buildProgramHeader(program),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: program.weekPlan.map((day) => _buildDayPlan(day)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProgramHeader(DietProgram program) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.purple.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  program.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            program.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProgramStat('Hedef Kalori', '${program.dailyCalorieTarget.toInt()} kcal'),
              const SizedBox(width: 20),
              _buildProgramStat('Hedef', _getGoalText(program.goal)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgramStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.purple,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Pazartesi'),
          Tab(text: 'Salı'),
          Tab(text: 'Çarşamba'),
          Tab(text: 'Perşembe'),
          Tab(text: 'Cuma'),
          Tab(text: 'Cumartesi'),
          Tab(text: 'Pazar'),
        ],
      ),
    );
  }

  Widget _buildDayPlan(DayMealPlan dayPlan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayHeader(dayPlan),
          const SizedBox(height: 20),
          _buildNutritionSummary(dayPlan),
          const SizedBox(height: 20),
          ...dayPlan.meals.map((meal) => _buildMealCard(meal)),
        ],
      ),
    );
  }

  Widget _buildDayHeader(DayMealPlan dayPlan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayPlan.dayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toplam: ${dayPlan.totalCalories.toInt()} kalori',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(DayMealPlan dayPlan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Besin Değerleri',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  'Protein',
                  '${dayPlan.totalProtein.toInt()}g',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  'Karbonhidrat',
                  '${dayPlan.totalCarbs.toInt()}g',
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  'Yağ',
                  '${dayPlan.totalFat.toInt()}g',
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getMealColor(meal.name).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getMealIcon(meal.name),
                color: _getMealColor(meal.name),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${meal.totalCalories.toInt()} kalori',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${meal.foods.length} öğe',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        children: [
          ...meal.foods.map((foodItem) => _buildFoodItem(foodItem)),
        ],
      ),
    );
  }

  Widget _buildFoodItem(FoodItem foodItem) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getFoodCategoryColor(foodItem.food.category),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodItem.food.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${foodItem.amount.toInt()}g',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${foodItem.calories.toInt()} kcal',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMealColor(String mealName) {
    switch (mealName) {
      case 'Kahvaltı':
        return Colors.orange;
      case 'Öğle Yemeği':
        return Colors.blue;
      case 'Akşam Yemeği':
        return Colors.green;
      case 'Ara Öğün':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getMealIcon(String mealName) {
    switch (mealName) {
      case 'Kahvaltı':
        return Icons.wb_sunny;
      case 'Öğle Yemeği':
        return Icons.wb_sunny_outlined;
      case 'Akşam Yemeği':
        return Icons.nightlight_round;
      case 'Ara Öğün':
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }

  Color _getFoodCategoryColor(String category) {
    switch (category) {
      case 'protein':
        return Colors.red;
      case 'vegetable':
        return Colors.green;
      case 'fruit':
        return Colors.orange;
      case 'grain':
        return Colors.brown;
      case 'dairy':
        return Colors.blue;
      case 'fat':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  String _getGoalText(String goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Kilo Verme';
      case 'gain_weight':
        return 'Kilo Alma';
      case 'maintain':
        return 'Kilo Koruma';
      default:
        return 'Sağlıklı Beslenme';
    }
  }
}