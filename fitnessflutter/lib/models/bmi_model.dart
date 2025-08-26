enum BMICategory {
  underweight,
  normal,
  overweight,
  obese,
}

class BMIData {
  final double bmi;
  final BMICategory category;
  final String categoryText;
  final String recommendation;
  final String description;

  BMIData({
    required this.bmi,
    required this.category,
    required this.categoryText,
    required this.recommendation,
    required this.description,
  });


  static BMIData calculateBMI(double height, double weight) {
   
    double heightInMeters = height / 100;
    double bmi = weight / (heightInMeters * heightInMeters);
    
    BMICategory category;
    String categoryText;
    String recommendation;
    String description;

    if (bmi < 18.5) {
      category = BMICategory.underweight;
      categoryText = 'Zayıf';
      recommendation = 'Kilo almaya odaklanın';
      description = 'Sağlıklı kilo alımı için dengeli beslenme ve güç antrenmanları önerilir.';
    } else if (bmi >= 18.5 && bmi < 25) {
      category = BMICategory.normal;
      categoryText = 'Normal';
      recommendation = 'Mevcut kilonuzu koruyun';
      description = 'İdeal kilo aralığındasınız. Sağlıklı yaşam tarzınızı sürdürün.';
    } else if (bmi >= 25 && bmi < 30) {
      category = BMICategory.overweight;
      categoryText = 'Fazla Kilolu';
      recommendation = 'Kilo vermeye odaklanın';
      description = 'Sağlıklı kilo kaybı için kalori açığı oluşturun ve düzenli egzersiz yapın.';
    } else {
      category = BMICategory.obese;
      categoryText = 'Obez';
      recommendation = 'Acil kilo verme gerekli';
      description = 'Sağlık riskleri nedeniyle profesyonel destek alarak kilo vermeye odaklanın.';
    }

    return BMIData(
      bmi: double.parse(bmi.toStringAsFixed(1)),
      category: category,
      categoryText: categoryText,
      recommendation: recommendation,
      description: description,
    );
  }

  
  static Map<String, double> getIdealWeightRange(double height) {
    double heightInMeters = height / 100;
    double minWeight = 18.5 * (heightInMeters * heightInMeters);
    double maxWeight = 24.9 * (heightInMeters * heightInMeters);
    
    return {
      'min': double.parse(minWeight.toStringAsFixed(1)),
      'max': double.parse(maxWeight.toStringAsFixed(1)),
    };
  }

  // Calculate daily calorie needs based on BMI and activity level
  double calculateDailyCalories(double weight, double height, int age, String gender, String activityLevel) {
    double bmr;
    
    // Calculate BMR using Mifflin-St Jeor Equatino
    if (gender.toLowerCase() == 'erkek') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    // Activity factor
    double activityFactor;
    switch (activityLevel) {
      case 'sedentary':
        activityFactor = 1.2;
        break;
      case 'light':
        activityFactor = 1.375;
        break;
      case 'moderate':
        activityFactor = 1.55;
        break;
      case 'active':
        activityFactor = 1.725;
        break;
      case 'very_active':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.2;
    }

    return bmr * activityFactor;
  }
}