import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/base_auth_provider.dart';
import '../../providers/fitness_provider.dart';
import '../../services/navigation_service.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: Consumer<BaseAuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 20),
                _buildPersonalInfo(user),
                const SizedBox(height: 20),
                _buildFitnessInfo(user),
                const SizedBox(height: 20),
                _buildFitnessStats(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Üye olma tarihi: ${_formatDate(user.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(User user) {
    return _buildInfoCard(
      title: 'Kişisel Bilgiler',
      icon: Icons.person_outline,
      color: Colors.blue,
      children: [
        _buildInfoRow('Yaş', '${user.age} yaş'),
        _buildInfoRow('Cinsiyet', user.gender),
        _buildInfoRow('Boy', '${user.height.toInt()} cm'),
        _buildInfoRow('Kilo', '${user.weight.toInt()} kg'),
      ],
    );
  }

  Widget _buildFitnessInfo(User user) {
    return _buildInfoCard(
      title: 'Fitness Bilgileri',
      icon: Icons.fitness_center,
      color: Colors.purple,
      children: [
        _buildInfoRow('Hedef', _getFitnessGoalText(user.fitnessGoal)),
        _buildInfoRow('Aktivite Seviyesi', _getActivityLevelText(user.activityLevel)),
      ],
    );
  }

  Widget _buildFitnessStats() {
    return Consumer<FitnessProvider>(
      builder: (context, fitnessProvider, child) {
        final summary = fitnessProvider.getFitnessSummary();
        
        return _buildInfoCard(
          title: 'Fitness Durumu',
          icon: Icons.analytics,
          color: Colors.orange,
          children: [
            _buildInfoRow('BMI Durumu', summary['bmiCategory']),
            _buildInfoRow('Öneri', summary['recommendation']),
            _buildInfoRow('Egzersiz Programı', summary['hasWorkoutProgram'] ? 'Mevcut' : 'Henüz Yok'),
            _buildInfoRow('Diyet Programı', summary['hasDietProgram'] ? 'Mevcut' : 'Henüz Yok'),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              NavigationService.navigateTo(AppRoutes.bmiCalculator);
            },
            icon: const Icon(Icons.calculate),
            label: const Text('BMI Hesapla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  NavigationService.navigateTo(AppRoutes.workoutProgram);
                },
                icon: const Icon(Icons.fitness_center),
                label: const Text('Egzersiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  NavigationService.navigateTo(AppRoutes.dietProgram);
                },
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Diyet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış Yap'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    final authProvider = Provider.of<BaseAuthProvider>(context, listen: false);
    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    
    await authProvider.logout();
    fitnessProvider.clearFitnessData();
    
    if (mounted) {
      NavigationService.navigateAndClearStack(AppRoutes.login);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
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

  String _getActivityLevelText(String level) {
    switch (level) {
      case 'sedentary':
        return 'Hareketsiz';
      case 'light':
        return 'Hafif Aktif';
      case 'moderate':
        return 'Orta Aktif';
      case 'active':
        return 'Aktif';
      case 'very_active':
        return 'Çok Aktif';
      default:
        return 'Belirlenmemiş';
    }
  }
}