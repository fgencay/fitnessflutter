// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fitnessflutter/providers/auth_provider.dart';
import 'package:fitnessflutter/providers/fitness_provider.dart';
import 'package:fitnessflutter/models/bmi_model.dart';
import 'package:fitnessflutter/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    // Test the login screen widget directly
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => FitnessProvider()),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
        ),
      ),
    );

    // Verify that the login screen elements are present
    expect(find.text('FitLife'), findsOneWidget);
    expect(find.text('Hesabınıza giriş yapın'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
    expect(find.text('Hesap Oluştur'), findsOneWidget);
  });

  testWidgets('BMI calculation works correctly', (WidgetTester tester) async {
    // Test BMI calculation logic
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
}
