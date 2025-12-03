class Exercise {
  final String name;  
  final String description;
  final int sets;  
  final int reps;
  final int duration;  
  final String type; 
  final String targetMuscle;  
  final String difficulty; 

  Exercise({

    required this.name,   
    required this.description,
    this.sets = 1,    
    this.reps = 1,    
    this.duration = 0,
    required this.type,    
    required this.targetMuscle,
    required this.difficulty,  }
    );

  Map<String, dynamic> toMap() {

    return {

      'name': name, 
      'description': description, 
      'sets': sets,
      'reps': reps, 
      'duration': duration,  
      'type': type,
      'targetMuscle': targetMuscle,
      'difficulty': difficulty,  
       };
        }

  factory Exercise.fromMap(Map<String, dynamic> map) {

    return Exercise(

      name: map['name'] ?? '',
      description: map['description'] ?? '',   
      sets: map['sets'] ?? 1,
      reps: map['reps'] ?? 1,  
      duration: map['duration'] ?? 0,
      type: map['type'] ?? '',   
      targetMuscle: map['targetMuscle'] ?? '',
      difficulty: map['difficulty'] ?? '',  
        );  
        }}


class WorkoutDay {
  final String dayName;
  final List<Exercise> exercises;  
  final String focus;

  WorkoutDay({
   required this.dayName,required this.exercises, required this.focus, });
  Map<String, dynamic> toMap() {
    return { 'dayName': dayName,
      'exercises': exercises.map((e) => e.toMap()).toList(), 'focus': focus,  };  }
  factory WorkoutDay.fromMap(Map<String, dynamic> map) {
    return WorkoutDay(
      dayName: map['dayName'] ?? '',
      exercises: List<Exercise>.from(
        map['exercises']?.map((e) => Exercise.fromMap(e)) ?? [],   ),
      focus: map['focus'] ?? '',    );  }
}
class WorkoutProgram {

  final String id;  
  final String name;
  final String description;  
  final List<WorkoutDay> workoutDays;
  final String difficulty;  
  final int durationWeeks;
  final String goal;   
  final DateTime createdAt;

  WorkoutProgram({
    required this.id,    
    required this.name,
    required this.description,    
    required this.workoutDays,
    required this.difficulty,    
    required this.durationWeeks,
    required this.goal,    
    required this.createdAt,  
    }
    );

  Map<String, dynamic> toMap() {
    return {
      'id': id,      
      'name': name,
      'description': description,
      'workoutDays': workoutDays.map((day) => day.toMap()).toList(),
      'difficulty': difficulty,  
      'durationWeeks': durationWeeks,
      'goal': goal,  
      'createdAt': createdAt.toIso8601String(),    
      };
        }

  factory WorkoutProgram.fromMap(Map<String, dynamic> map) {

    return WorkoutProgram(

      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      workoutDays: List<WorkoutDay>.from(
        map['workoutDays']?.map((day) => WorkoutDay.fromMap(day)) ?? [],
      ),
      difficulty: map['difficulty'] ?? '',
      durationWeeks: map['durationWeeks'] ?? 0,
      goal: map['goal'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()), 
        );
          }
  static WorkoutProgram generateProgram(

    String userId,    
    String fitnessGoal,
    String activityLevel,    
    double bmi,  ) {
    String difficulty; 

    List<WorkoutDay> workoutDays = [];
    String programName; 
    String description;    
    switch (activityLevel) {
      case 'sedentary':  case 'light':
        difficulty = 'beginner';   break;
      case 'moderate':  difficulty = 'intermediate';   break;
      case 'active':  case 'very_active':  difficulty = 'advanced';   break;  
          default:  difficulty = 'beginner';  }   
    switch (fitnessGoal) {
            case 'lose_weight':
        programName = 'Kilo Verme Programı';
        description = 'Kardiyovasküler egzersizler ve güç antrenmanları ile kilo vermeye odaklanan program';
        workoutDays = _generateWeightLossProgram(difficulty);
        break;
      case 'gain_weight':
        programName = 'Kas Geliştirme Programı';
        description = 'Güç antrenmanları ile kas kütlesi artırımına odaklanan program';
        workoutDays = _generateMuscleGainProgram(difficulty);
        break;
      case 'maintain':
        programName = 'Sağlık Koruma Programı';
        description = 'Genel fitness ve sağlık koruma için dengeli egzersiz programı';
        workoutDays = _generateMaintenanceProgram(difficulty);
        break;
      default:
        programName = 'Genel Fitness Programı';
        description = 'Genel sağlık ve fitness için dengeli program';
        workoutDays = _generateMaintenanceProgram(difficulty);
    }

    return WorkoutProgram(
      id: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
      name: programName,
      description: description,
      workoutDays: workoutDays,
      difficulty: difficulty,
      durationWeeks: 8,
      goal: fitnessGoal,
      createdAt: DateTime.now(),
    );
  }

  static List<WorkoutDay> _generateWeightLossProgram(String difficulty) {
    return [
      WorkoutDay(
        dayName: 'Pazartesi',
        focus: 'cardio',
        exercises: [
          Exercise(
            name: 'Yürüyüş/Koşu',
            description: 'Orta tempoda kardiyovasküler egzersiz',
            duration: difficulty == 'beginner' ? 1800 : difficulty == 'intermediate' ? 2400 : 3000,
            type: 'cardio',
            targetMuscle: 'kardiyovasküler',
            difficulty: difficulty,
          ),
          Exercise(
            name: 'Burpees',
            description: 'Tüm vücut yakan egzersiz',
            sets: difficulty == 'beginner' ? 3 : difficulty == 'intermediate' ? 4 : 5,
            reps: difficulty == 'beginner' ? 8 : difficulty == 'intermediate' ? 12 : 15,
            type: 'cardio',
            targetMuscle: 'full_body',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Salı',
        focus: 'upper_body',
        exercises: [
          Exercise(
            name: 'Şınav',
            description: 'Göğüs ve kol kasları için temel egzersiz',
            sets: difficulty == 'beginner' ? 3 : difficulty == 'intermediate' ? 4 : 5,
            reps: difficulty == 'beginner' ? 10 : difficulty == 'intermediate' ? 15 : 20,
            type: 'strength',
            targetMuscle: 'chest',
            difficulty: difficulty,
          ),
          Exercise(
            name: 'Plank',
            description: 'Core stabilizasyonu için',
            sets: 3,
            duration: difficulty == 'beginner' ? 30 : difficulty == 'intermediate' ? 45 : 60,
            type: 'strength',
            targetMuscle: 'core',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Çarşamba',
        focus: 'rest',
        exercises: [
          Exercise(
            name: 'Hafif Yürüyüş',
            description: 'Aktif dinlenme için hafif aktivite',
            duration: 1800,
            type: 'cardio',
            targetMuscle: 'legs',
            difficulty: 'beginner',
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Perşembe',
        focus: 'lower_body',
        exercises: [
          Exercise(
            name: 'Squat',
            description: 'Bacak ve kalça kasları için',
            sets: difficulty == 'beginner' ? 3 : difficulty == 'intermediate' ? 4 : 5,
            reps: difficulty == 'beginner' ? 12 : difficulty == 'intermediate' ? 15 : 20,
            type: 'strength',
            targetMuscle: 'legs',
            difficulty: difficulty,
          ),
          Exercise(
            name: 'Lunges',
            description: 'Bacak kasları ve denge için',
            sets: 3,
            reps: difficulty == 'beginner' ? 10 : difficulty == 'intermediate' ? 12 : 15,
            type: 'strength',
            targetMuscle: 'legs',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Cuma',
        focus: 'cardio',
        exercises: [
          Exercise(
            name: 'HIIT Antrenmanı',
            description: 'Yüksek yoğunluklu interval antrenman',
            duration: difficulty == 'beginner' ? 1200 : difficulty == 'intermediate' ? 1800 : 2400,
            type: 'cardio',
            targetMuscle: 'full_body',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Cumartesi',
        focus: 'full_body',
        exercises: [
          Exercise(
            name: 'Circuit Training',
            description: 'Tüm vücut devre antrenmanı',
            sets: 3,
            reps: 15,
            type: 'strength',
            targetMuscle: 'full_body',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Pazar',
        focus: 'rest',
        exercises: [
          Exercise(
            name: 'Germe Egzersizleri',
            description: 'Esneklik ve toparlanma için',
            duration: 1800,
            type: 'flexibility',
            targetMuscle: 'full_body',
            difficulty: 'beginner',
          ),
        ],
      ),
    ];
  }

  static List<WorkoutDay> _generateMuscleGainProgram(String difficulty) {
    return [
      WorkoutDay(
        dayName: 'Pazartesi',
        focus: 'upper_body',
        exercises: [
          Exercise(
            name: 'Şınav',
            description: 'Göğüs kasları geliştirme',
            sets: difficulty == 'beginner' ? 4 : difficulty == 'intermediate' ? 5 : 6,
            reps: difficulty == 'beginner' ? 8 : difficulty == 'intermediate' ? 12 : 15,
            type: 'strength',
            targetMuscle: 'chest',
            difficulty: difficulty,
          ),
          Exercise(
            name: 'Pull-ups/Chin-ups',
            description: 'Sırt ve kol kasları için',
            sets: 4,
            reps: difficulty == 'beginner' ? 5 : difficulty == 'intermediate' ? 8 : 12,
            type: 'strength',
            targetMuscle: 'back',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Salı',
        focus: 'lower_body',
        exercises: [
          Exercise(
            name: 'Squat',
            description: 'Bacak kasları geliştirme',
            sets: difficulty == 'beginner' ? 4 : difficulty == 'intermediate' ? 5 : 6,
            reps: difficulty == 'beginner' ? 8 : difficulty == 'intermediate' ? 12 : 15,
            type: 'strength',
            targetMuscle: 'legs',
            difficulty: difficulty,
          ),
          Exercise(
            name: 'Deadlift (Vücut Ağırlığı)',
            description: 'Arka bacak ve kalça kasları',
            sets: 4,
            reps: difficulty == 'beginner' ? 6 : difficulty == 'intermediate' ? 10 : 12,
            type: 'strength',
            targetMuscle: 'legs',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Çarşamba',
        focus: 'rest',
        exercises: [
          Exercise(
            name: 'Hafif Kardiyovasküler',
            description: 'Toparlanma için hafif aktivite',
            duration: 1800,
            type: 'cardio',
            targetMuscle: 'cardiovascular',
            difficulty: 'beginner',
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Perşembe',
        focus: 'upper_body',
        exercises: [
          Exercise(
            name: 'Pike Push-ups',
            description: 'Omuz kasları için',
            sets: 4,
            reps: difficulty == 'beginner' ? 6 : difficulty == 'intermediate' ? 10 : 12,
            type: 'strength',
            targetMuscle: 'shoulders',
            difficulty: difficulty,
          ),
          Exercise(
            name: 'Tricep Dips',
            description: 'Tricep kasları geliştirme',
            sets: 4,
            reps: difficulty == 'beginner' ? 8 : difficulty == 'intermediate' ? 12 : 15,
            type: 'strength',
            targetMuscle: 'arms',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Cuma',
        focus: 'full_body',
        exercises: [
          Exercise(
            name: 'Compound Movements',
            description: 'Çoklu kas grubu egzersizleri',
            sets: 4,
            reps: difficulty == 'beginner' ? 8 : difficulty == 'intermediate' ? 10 : 12,
            type: 'strength',
            targetMuscle: 'full_body',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Cumartesi',
        focus: 'core',
        exercises: [
          Exercise(
            name: 'Core Workout',
            description: 'Karın kasları güçlendirme',
            sets: 4,
            reps: 15,
            type: 'strength',
            targetMuscle: 'core',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Pazar',
        focus: 'rest',
        exercises: [
          Exercise(
            name: 'Aktif Dinlenme',
            description: 'Toparlanma ve esneklik',
            duration: 1800,
            type: 'flexibility',
            targetMuscle: 'full_body',
            difficulty: 'beginner',
          ),
        ],
      ),
    ];
  }

  static List<WorkoutDay> _generateMaintenanceProgram(String difficulty) {
    return [
      WorkoutDay(
        dayName: 'Pazartesi',
        focus: 'full_body',
        exercises: [
          Exercise(
            name: 'Full Body Circuit',
            description: 'Genel fitness için dengeli egzersiz',
            sets: 3,
            reps: 12,
            type: 'strength',
            targetMuscle: 'full_body',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Salı',
        focus: 'cardio',
        exercises: [
          Exercise(
            name: 'Kardiyovasküler Egzersiz',
            description: 'Kalp sağlığı için',
            duration: 2400,
            type: 'cardio',
            targetMuscle: 'cardiovascular',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Çarşamba',
        focus: 'upper_body',
        exercises: [
          Exercise(
            name: 'Upper Body Strength',
            description: 'Üst vücut güçlendirme',
            sets: 3,
            reps: 12,
            type: 'strength',
            targetMuscle: 'upper_body',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Perşembe',
        focus: 'rest',
        exercises: [
          Exercise(
            name: 'Aktif Dinlenme',
            description: 'Hafif aktivite',
            duration: 1800,
            type: 'cardio',
            targetMuscle: 'full_body',
            difficulty: 'beginner',
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Cuma',
        focus: 'lower_body',
        exercises: [
          Exercise(
            name: 'Lower Body Strength',
            description: 'Alt vücut güçlendirme',
            sets: 3,
            reps: 12,
            type: 'strength',
            targetMuscle: 'legs',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Cumartesi',
        focus: 'flexibility',
        exercises: [
          Exercise(
            name: 'Yoga/Pilates',
            description: 'Esneklik ve denge',
            duration: 3600,
            type: 'flexibility',
            targetMuscle: 'full_body',
            difficulty: difficulty,
          ),
        ],
      ),
      WorkoutDay(
        dayName: 'Pazar',
        focus: 'rest',
        exercises: [
          Exercise(
            name: 'Tam Dinlenme',
            description: 'Vücut toparlanması için',
            duration: 0,
            type: 'rest',
            targetMuscle: 'none',
            difficulty: 'beginner',
          ),
        ],
      ),
    ];
  }
}