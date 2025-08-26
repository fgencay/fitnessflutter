import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fitness_provider.dart';
import '../../models/workout_model.dart';

class WorkoutProgramScreen extends StatefulWidget {
  const WorkoutProgramScreen({super.key});

  @override
  State<WorkoutProgramScreen> createState() => _WorkoutProgramScreenState();
}

class _WorkoutProgramScreenState extends State<WorkoutProgramScreen> {
  @override
  void initState() {
    super.initState();
    _loadWorkoutProgram();
  }

  void _loadWorkoutProgram() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await fitnessProvider.loadFitnessData(authProvider.currentUser!.id);
    }
  }

  void _generateNewProgram() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fitnessProvider = Provider.of<FitnessProvider>(context, listen: false);
    final user = authProvider.currentUser;
    final bmi = fitnessProvider.currentBMI;
    
    if (user != null && bmi != null) {
      await fitnessProvider.generateWorkoutProgram(user, bmi);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yeni egzersiz programınız oluşturuldu!'),
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
        title: const Text('Egzersiz Programı'),
        backgroundColor: Colors.blue,
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
                onPressed: fitnessProvider.isLoading ? null : _generateNewProgram,
                tooltip: 'Yeni Program Oluştur',
              );
            },
          ),
        ],
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, fitnessProvider, child) {
          final workoutProgram = fitnessProvider.currentWorkoutProgram;
          
          if (workoutProgram == null) {
            return _buildEmptyState();
          }
          
          return _buildWorkoutProgram(workoutProgram);
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
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz egzersiz programınız yok',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Kişiye özel egzersiz programı oluşturmak için önce BMI hesaplamanızı yapın',
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
                  onPressed: fitnessProvider.isLoading ? null : _generateNewProgram,
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
                    backgroundColor: Colors.blue,
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

  Widget _buildWorkoutProgram(WorkoutProgram program) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgramHeader(program),
          const SizedBox(height: 24),
          _buildProgramInfo(program),
          const SizedBox(height: 24),
          _buildWeeklySchedule(program),
        ],
      ),
    );
  }

  Widget _buildProgramHeader(WorkoutProgram program) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fitness_center,
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
              _buildProgramStat('Süre', '${program.durationWeeks} hafta'),
              const SizedBox(width: 20),
              _buildProgramStat('Seviye', _getDifficultyText(program.difficulty)),
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

  Widget _buildProgramInfo(WorkoutProgram program) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Program Bilgileri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Haftada ${program.workoutDays.where((day) => day.focus != 'rest').length} gün aktif egzersiz',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '• ${program.workoutDays.where((day) => day.focus == 'rest').length} gün dinlenme/aktif toparlanma',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            '• Her egzersizi doğru form ile yapın',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            '• Ağrı hissettiğinizde egzersizi durdurun',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule(WorkoutProgram program) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Haftalık Program',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...program.workoutDays.map((day) => _buildWorkoutDay(day)),
      ],
    );
  }

  Widget _buildWorkoutDay(WorkoutDay day) {
    Color focusColor = _getFocusColor(day.focus);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: focusColor.withValues(alpha: 0.3)),
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
                color: focusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getFocusIcon(day.focus),
                color: focusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.dayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getFocusText(day.focus),
                    style: TextStyle(
                      fontSize: 14,
                      color: focusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${day.exercises.length} egzersiz',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        children: [
          ...day.exercises.map((exercise) => _buildExerciseItem(exercise)),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getExerciseIcon(exercise.type),
                color: _getExerciseColor(exercise.type),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getExerciseColor(exercise.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getExerciseTypeText(exercise.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getExerciseColor(exercise.type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exercise.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (exercise.sets > 1) ...[
                _buildExerciseDetail(Icons.repeat, '${exercise.sets} set'),
                const SizedBox(width: 16),
              ],
              if (exercise.reps > 1) ...[
                _buildExerciseDetail(Icons.fitness_center, '${exercise.reps} tekrar'),
                const SizedBox(width: 16),
              ],
              if (exercise.duration > 0) ...[
                _buildExerciseDetail(Icons.timer, '${exercise.duration ~/ 60} dakika'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getFocusColor(String focus) {
    switch (focus) {
      case 'upper_body':
        return Colors.orange;
      case 'lower_body':
        return Colors.green;
      case 'full_body':
        return Colors.purple;
      case 'cardio':
        return Colors.red;
      case 'core':
        return Colors.blue;
      case 'flexibility':
        return Colors.teal;
      case 'rest':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getFocusIcon(String focus) {
    switch (focus) {
      case 'upper_body':
        return Icons.accessibility_new;
      case 'lower_body':
        return Icons.directions_run;
      case 'full_body':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.favorite;
      case 'core':
        return Icons.center_focus_strong;
      case 'flexibility':
        return Icons.self_improvement;
      case 'rest':
        return Icons.bed;
      default:
        return Icons.fitness_center;
    }
  }

  String _getFocusText(String focus) {
    switch (focus) {
      case 'upper_body':
        return 'Üst Vücut';
      case 'lower_body':
        return 'Alt Vücut';
      case 'full_body':
        return 'Tüm Vücut';
      case 'cardio':
        return 'Kardiyovasküler';
      case 'core':
        return 'Karın Kasları';
      case 'flexibility':
        return 'Esneklik';
      case 'rest':
        return 'Dinlenme';
      default:
        return 'Egzersiz';
    }
  }

  Color _getExerciseColor(String type) {
    switch (type) {
      case 'strength':
        return Colors.blue;
      case 'cardio':
        return Colors.red;
      case 'flexibility':
        return Colors.green;
      case 'rest':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getExerciseIcon(String type) {
    switch (type) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      case 'rest':
        return Icons.bed;
      default:
        return Icons.fitness_center;
    }
  }

  String _getExerciseTypeText(String type) {
    switch (type) {
      case 'strength':
        return 'Güç';
      case 'cardio':
        return 'Kardiyovas';
      case 'flexibility':
        return 'Esneklik';
      case 'rest':
        return 'Dinlenme';
      default:
        return 'Egzersiz';
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 'Başlangıç';
      case 'intermediate':
        return 'Orta';
      case 'advanced':
        return 'İleri';
      default:
        return 'Orta';
    }
  }

  String _getGoalText(String goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Kilo Verme';
      case 'gain_weight':
        return 'Kas Geliştirme';
      case 'maintain':
        return 'Sağlık Koruma';
      default:
        return 'Genel Fitness';
    }
  }
}