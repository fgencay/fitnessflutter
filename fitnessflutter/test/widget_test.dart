// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fitnessflutter/providers/fitness_provider.dart';
import 'package:fitnessflutter/models/bmi_model.dart';

void main() {
  testWidgets('BMI calculation works correctly', (WidgetTester tester) async {
    // Test BMI calculation logic without Firebase dependency
    const double height = 170; // cm
    const double weight = 70; // kg
    
    // Expected BMI = weight / (height in meters)^2 = 70 / (1.7)^2 ≈ 24.2
    const double expectedBMI = 24.2;
    
    // Calculate BMI using our model
    final bmiData = BMIData.calculateBMI(height, weight);
    
    // Verify BMI calculation
    expect(bmiData.bmi, closeTo(expectedBMI, 0.1));
    expect(bmiData.category, BMICategory.normal);
    expect(bmiData.categoryText, 'Normal');
  });
  
  testWidgets('FitnessProvider initialization works correctly', (WidgetTester tester) async {
    // Test FitnessProvider without Firebase dependency
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FitnessProvider()),
        ],
        child: MaterialApp(
          home: Consumer<FitnessProvider>(
            builder: (context, provider, child) {
              return Scaffold(
                body: Text('Provider initialized: ${provider.runtimeType == FitnessProvider}'),
              );
            },
          ),
        ),
      ),
    );

    // Verify that the FitnessProvider was created successfully
    expect(find.text('Provider initialized: true'), findsOneWidget);
  });
  
  testWidgets('BMI categories are correctly classified', (WidgetTester tester) async {
    // Test different BMI categories
    
    // Underweight test
    final underweightBMI = BMIData.calculateBMI(170, 50); // BMI = 17.3
    expect(underweightBMI.category, BMICategory.underweight);
    expect(underweightBMI.categoryText, 'Zayıf');
    
    // Normal test
    final normalBMI = BMIData.calculateBMI(170, 70); // BMI = 24.2
    expect(normalBMI.category, BMICategory.normal);
    expect(normalBMI.categoryText, 'Normal');
    
    // Overweight test
    final overweightBMI = BMIData.calculateBMI(170, 85); // BMI = 29.4
    expect(overweightBMI.category, BMICategory.overweight);
    expect(overweightBMI.categoryText, 'Fazla Kilolu');
    
    // Obese test
    final obeseBMI = BMIData.calculateBMI(170, 100); // BMI = 34.6
    expect(obeseBMI.category, BMICategory.obese);
    expect(obeseBMI.categoryText, 'Obez');
  });
}
