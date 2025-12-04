import 'package:flutter/material.dart';
import 'dart:io';
import '../main.dart';
import '../models/workout.dart';

class MetricsProvider with ChangeNotifier {
  List<BodyMetric> _metrics = [];
  List<ProgressPhoto> _photos = [];
  bool _isLoading = false;
  String? _error;

  List<BodyMetric> get metrics => _metrics;
  List<ProgressPhoto> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all body metrics
  Future<void> fetchMetrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await supabase
          .from('body_metrics')
          .select()
          .order('date', ascending: false);

      _metrics = (response as List)
          .map((metric) => BodyMetric.fromJson(metric))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch metrics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new body metric
  Future<bool> addMetric(BodyMetric metric) async {
    try {
      final response = await supabase
          .from('body_metrics')
          .insert(metric.toJson())
          .select()
          .single();

      _metrics.insert(0, BodyMetric.fromJson(response));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add metric: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete metric
  Future<bool> deleteMetric(String id) async {
    try {
      await supabase.from('body_metrics').delete().eq('id', id);
      _metrics.removeWhere((m) => m.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete metric: $e';
      notifyListeners();
      return false;
    }
  }

  // Fetch all progress photos
  Future<void> fetchPhotos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await supabase
          .from('progress_photos')
          .select()
          .order('date', ascending: false);

      _photos = (response as List)
          .map((photo) => ProgressPhoto.fromJson(photo))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch photos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload progress photo
  Future<bool> uploadPhoto(File imageFile, String? notes) async {
    try {
      final fileName = 'progress_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'progress_photos/$fileName';

      // Upload to Supabase Storage
      await supabase.storage.from('fittrack-photos').upload(path, imageFile);

      // Get public URL
      final imageUrl = supabase.storage.from('fittrack-photos').getPublicUrl(path);

      // Save to database
      final photo = ProgressPhoto(
        imageUrl: imageUrl,
        date: DateTime.now(),
        notes: notes,
      );

      final response = await supabase
          .from('progress_photos')
          .insert(photo.toJson())
          .select()
          .single();

      _photos.insert(0, ProgressPhoto.fromJson(response));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to upload photo: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete progress photo
  Future<bool> deletePhoto(String id, String imageUrl) async {
    try {
      // Delete from storage
      final path = imageUrl.split('/').last;
      await supabase.storage.from('fittrack-photos').remove(['progress_photos/$path']);

      // Delete from database
      await supabase.from('progress_photos').delete().eq('id', id);
      _photos.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete photo: $e';
      notifyListeners();
      return false;
    }
  }

  // Get latest weight
  double? get latestWeight {
    if (_metrics.isEmpty) return null;
    return _metrics.first.weight;
  }

  // Get weight change
  double? get weightChange {
    if (_metrics.length < 2) return null;
    return _metrics.first.weight - _metrics.last.weight;
  }
}