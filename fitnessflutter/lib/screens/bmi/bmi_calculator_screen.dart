import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/base_auth_provider.dart';
import '../../providers/fitness_provider.dart';
import '../../models/bmi_model.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  BMIData? _bmiResult;
  bool _useUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<BaseAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null && _useUserData) {
      _heightController.text = user.height.toString();
      _weightController.text = user.weight.toString();
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    if (_formKey.currentState!.validate()) {
      final height = double.parse(_heightController.text);
      final weight = double.parse(_weightController.text);
      
      setState(() {
        _bmiResult = BMIData.calculateBMI(height, weight);
      });
      
      // Save BMI to provider
      final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
      fitnessProvider.calculateBMI(height, weight);
      
      // Update user data if different
      final authProvider = Provider.of<BaseAuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user != null && (user.height != height || user.weight != weight)) {
        final updatedUser = user.copyWith(height: height, weight: weight);
        authProvider.updateUserProfile(updatedUser);
      }
    }
  }

  void _generatePrograms() {
    if (_bmiResult != null) {
      final authProvider = Provider.of<BaseAuthProvider>(context, listen: false);
      final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user != null) {
        // Generate both workout and diet programs
        fitnessProvider.generateWorkoutProgram(user, _bmiResult!);
        fitnessProvider.generateDietProgram(user, _bmiResult!);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kişiselleştirilmiş programlarınız oluşturuluyor...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Hesaplayıcı'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.orange.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.monitor_weight,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Vücut Kitle Endeksi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Boy ve kilonuzu girerek BMI değerinizi hesaplayın',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Use Current Data Toggle
              Consumer<BaseAuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.currentUser != null) {
                    return Card(
                      child: SwitchListTile(
                        title: const Text('Mevcut verilerimi kullan'),
                        subtitle: Text(
                          'Boy: ${authProvider.currentUser!.height.toInt()} cm, '
                          'Kilo: ${authProvider.currentUser!.weight.toInt()} kg',
                        ),
                        value: _useUserData,
                        onChanged: (value) {
                          setState(() {
                            _useUserData = value;
                            if (value) {
                              _loadUserData();
                            } else {
                              _heightController.clear();
                              _weightController.clear();
                            }
                          });
                        },
                        activeThumbColor: Colors.orange,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              
              const SizedBox(height: 20),
              
              // Input Fields
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Boy',
                        hintText: '170',
                        suffixText: 'cm',
                        prefixIcon: const Icon(Icons.height, color: Colors.orange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Boy gerekli';
                        }
                        final height = double.tryParse(value);
                        if (height == null || height < 100 || height > 250) {
                          return 'Geçerli boy (100-250 cm)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Kilo',
                        hintText: '70',
                        suffixText: 'kg',
                        prefixIcon: const Icon(Icons.monitor_weight_outlined, color: Colors.orange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kilo gerekli';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight < 30 || weight > 300) {
                          return 'Geçerli kilo (30-300 kg)';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Calculate Button
              ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'BMI Hesapla',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // BMI Result
              if (_bmiResult != null) _buildBMIResult(),
              
              const SizedBox(height: 20),
              
              // BMI Information
              _buildBMIInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMIResult() {
    Color categoryColor;
    switch (_bmiResult!.category) {
      case BMICategory.underweight:
        categoryColor = Colors.blue;
        break;
      case BMICategory.normal:
        categoryColor = Colors.green;
        break;
      case BMICategory.overweight:
        categoryColor = Colors.orange;
        break;
      case BMICategory.obese:
        categoryColor = Colors.red;
        break;
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                'BMI Sonucunuz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _bmiResult!.bmi.toString(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _bmiResult!.categoryText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _bmiResult!.recommendation,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _bmiResult!.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Ideal Weight Range
        Consumer<BaseAuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.currentUser != null) {
              final height = double.parse(_heightController.text);
              final idealRange = BMIData.getIdealWeightRange(height);
              
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'İdeal Kilo Aralığınız',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${idealRange['min']!.toInt()} - ${idealRange['max']!.toInt()} kg',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
        
        const SizedBox(height: 20),
        
        // Generate Programs Button
        Consumer<FitnessProvider>(
          builder: (context, fitnessProvider, child) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: fitnessProvider.isLoading ? null : _generatePrograms,
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
                      ? 'Programlar Oluşturuluyor...' 
                      : 'Kişiselleştirilmiş Programlar Oluştur',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBMIInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BMI Kategorileri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildBMICategory('Zayıf', '< 18.5', Colors.blue),
          _buildBMICategory('Normal', '18.5 - 24.9', Colors.green),
          _buildBMICategory('Fazla Kilolu', '25.0 - 29.9', Colors.orange),
          _buildBMICategory('Obez', '≥ 30.0', Colors.red),
        ],
      ),
    );
  }

  Widget _buildBMICategory(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}