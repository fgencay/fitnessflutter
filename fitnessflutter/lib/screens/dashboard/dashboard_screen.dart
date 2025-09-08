import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/base_auth_provider.dart';
import '../../providers/fitness_provider.dart';
import '../../services/navigation_service.dart';
import '../../models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() async {
    final authProvider = Provider.of<BaseAuthProvider>(context, listen: false);
    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await fitnessProvider.loadFitnessData(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitLife'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              NavigationService.navigateTo(AppRoutes.profile);
            },
          ),
        ],
      ),
      body: Consumer2<BaseAuthProvider, FitnessProvider>(
        builder: (context, authProvider, fitnessProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(user),
                const SizedBox(height: 20),
                _buildStatsSection(fitnessProvider),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildProgressSection(fitnessProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Merhaba, ${user.name}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fitness hedefiniz: ${_getFitnessGoalText(user.fitnessGoal)}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildUserStat('Yaş', '${user.age}'),
              const SizedBox(width: 20),
              _buildUserStat('Boy', '${user.height.toInt()} cm'),
              const SizedBox(width: 20),
              _buildUserStat('Kilo', '${user.weight.toInt()} kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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

  Widget _buildStatsSection(FitnessProvider fitnessProvider) {
    final summary = fitnessProvider.getFitnessSummary();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fitness Durumu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'BMI',
                summary['bmiCategory'],
                Icons.monitor_weight,
                summary['hasBMI'] ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Egzersiz',
                summary['hasWorkoutProgram'] ? 'Programa Sahip' : 'Program Yok',
                Icons.fitness_center,
                summary['hasWorkoutProgram'] ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Diyet',
                summary['hasDietProgram'] ? 'Programa Sahip' : 'Program Yok',
                Icons.restaurant,
                summary['hasDietProgram'] ? Colors.purple : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı Erişim',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              'BMI Hesapla',
              Icons.calculate,
              Colors.orange,
              () => NavigationService.navigateTo(AppRoutes.bmiCalculator),
            ),
            _buildActionCard(
              'Egzersiz Programı',
              Icons.fitness_center,
              Colors.blue,
              () => NavigationService.navigateTo(AppRoutes.workoutProgram),
            ),
            _buildActionCard(
              'Diyet Programı',
              Icons.restaurant_menu,
              Colors.purple,
              () => NavigationService.navigateTo(AppRoutes.dietProgram),
            ),
            _buildActionCard(
              'Profil',
              Icons.person,
              Colors.green,
              () => NavigationService.navigateTo(AppRoutes.profile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(FitnessProvider fitnessProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Öneriler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<FitnessProvider>(
          builder: (context, provider, child) {
            final recommendation = provider.currentBMI?.recommendation ?? 'BMI hesaplayarak başlayın';
            final description = provider.currentBMI?.description ?? 
                'Vücut Kitle Endeksinizi hesaplayarak kişiselleştirilmiş öneriler alın.';
            
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        recommendation,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _getFitnessGoalText(String goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Kilo Vermek';
      case 'gain_weight':
        return 'Kilo Almak';
      case 'maintain':
        return 'Kilonu Korumak';
      default:
        return 'Belirlenmemiş';
    }
  }
}