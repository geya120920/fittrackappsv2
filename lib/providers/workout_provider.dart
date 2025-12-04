import 'package:flutter/material.dart';
import '../main.dart';
import '../models/workout.dart';

class WorkoutProvider with ChangeNotifier {
  List<Workout> _workouts = [];
  bool _isLoading = false;
  String? _error;

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all workouts
  Future<void> fetchWorkouts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await supabase
          .from('workouts')
          .select()
          .order('date', ascending: false);

      _workouts = (response as List)
          .map((workout) => Workout.fromJson(workout))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch workouts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new workout
  Future<bool> addWorkout(Workout workout) async {
    try {
      print('🔄 Attempting to add workout...');
      print('📝 Workout data: ${workout.toJson()}');

      final response = await supabase
          .from('workouts')
          .insert(workout.toJson())
          .select()
          .single();

      print('✅ Workout added successfully: $response');

      _workouts.insert(0, Workout.fromJson(response));
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('❌ Error adding workout: $e');
      print('Stack trace: $stackTrace');
      _error = 'Failed to add workout: $e';
      notifyListeners();
      return false;
    }
  }

  // Update workout
  Future<bool> updateWorkout(Workout workout) async {
    try {
      await supabase
          .from('workouts')
          .update(workout.toJson())
          .eq('id', workout.id!);

      final index = _workouts.indexWhere((w) => w.id == workout.id);
      if (index != -1) {
        _workouts[index] = workout;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update workout: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete workout
  Future<bool> deleteWorkout(String id) async {
    try {
      await supabase.from('workouts').delete().eq('id', id);
      _workouts.removeWhere((w) => w.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete workout: $e';
      notifyListeners();
      return false;
    }
  }

  // Get workouts by date range
  List<Workout> getWorkoutsByDateRange(DateTime start, DateTime end) {
    return _workouts.where((workout) {
      return workout.date.isAfter(start.subtract(const Duration(days: 1))) &&
          workout.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get workouts by category
  List<Workout> getWorkoutsByCategory(String category) {
    return _workouts.where((w) => w.category == category).toList();
  }

  // Get total workouts count
  int get totalWorkouts => _workouts.length;

  // Get workouts this week
  int get workoutsThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return getWorkoutsByDateRange(startOfWeek, now).length;
  }
}