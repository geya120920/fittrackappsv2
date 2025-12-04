class Workout {
  final String? id;
  final String exerciseName;
  final int sets;
  final int reps;
  final double weight;
  final String? notes;
  final DateTime date;
  final String category;

  Workout({
    this.id,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weight,
    this.notes,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_name': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'notes': notes,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id']?.toString(),
      exerciseName: json['exercise_name'] ?? '',
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      weight: (json['weight'] ?? 0).toDouble(),
      notes: json['notes'],
      date: DateTime.parse(json['date']),
      category: json['category'] ?? 'Other',
    );
  }
}

class BodyMetric {
  final String? id;
  final double weight;
  final double? bodyFat;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? arms;
  final double? legs;
  final DateTime date;
  final String? notes;

  BodyMetric({
    this.id,
    required this.weight,
    this.bodyFat,
    this.chest,
    this.waist,
    this.hips,
    this.arms,
    this.legs,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'body_fat': bodyFat,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'arms': arms,
      'legs': legs,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory BodyMetric.fromJson(Map<String, dynamic> json) {
    return BodyMetric(
      id: json['id']?.toString(),
      weight: (json['weight'] ?? 0).toDouble(),
      bodyFat: json['body_fat']?.toDouble(),
      chest: json['chest']?.toDouble(),
      waist: json['waist']?.toDouble(),
      hips: json['hips']?.toDouble(),
      arms: json['arms']?.toDouble(),
      legs: json['legs']?.toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }
}

class ProgressPhoto {
  final String? id;
  final String imageUrl;
  final DateTime date;
  final String? notes;

  ProgressPhoto({
    this.id,
    required this.imageUrl,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    return ProgressPhoto(
      id: json['id']?.toString(),
      imageUrl: json['image_url'] ?? '',
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }
}