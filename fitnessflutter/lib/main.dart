import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/base_auth_provider.dart';
import 'providers/auth_provider.dart' as custom;
import 'providers/web_auth_provider.dart';
import 'providers/fitness_provider.dart';
import 'services/navigation_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/bmi/bmi_calculator_screen.dart';
import 'screens/workout/workout_program_screen.dart';
import 'screens/diet/diet_program_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/debug/auth_debug_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); 
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //tüm ekranların ulaşabileceği iki tane merkez veri yöneticisi tanımlandı
      providers: [
       ChangeNotifierProvider<BaseAuthProvider>(
  create: (_) => custom.AuthProvider(), 
),
        ChangeNotifierProvider(create: (_) => FitnessProvider()),
      ],
      child: MaterialApp(
            title: 'FitLife - Fitness App',
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService.navigatorKey,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: const Color(0xFF1E88E5),
              fontFamily: 'Roboto',
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2),
                ),
              ),
            ),
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.login: (_) => const LoginScreen(),
              AppRoutes.register: (_) => const RegisterScreen(),
              AppRoutes.dashboard: (_) => const DashboardScreen(),
              AppRoutes.bmiCalculator: (_) => const BMICalculatorScreen(),
              AppRoutes.workoutProgram: (_) => const WorkoutProgramScreen(),
              AppRoutes.dietProgram: (_) => const DietProgramScreen(),
              AppRoutes.profile: (_) => const ProfileScreen(),
              AppRoutes.authDebug: (_) => const AuthDebugScreen(),
            },
          ),
    );
  }
}
