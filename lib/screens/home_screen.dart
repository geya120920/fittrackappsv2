import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/metrics_provider.dart';
import 'workouts_screen.dart';
import 'metrics_screen.dart';
import 'progress_photos_screen.dart';
import 'add_workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const WorkoutsScreen(),
    const MetricsScreen(),
    const ProgressPhotosScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data
    Future.microtask(() {
      context.read<WorkoutProvider>().fetchWorkouts();
      context.read<MetricsProvider>().fetchMetrics();
      context.read<MetricsProvider>().fetchPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Metrics',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Photos',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Workout'),
      )
          : null,
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitTrack Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer2<WorkoutProvider, MetricsProvider>(
        builder: (context, workoutProvider, metricsProvider, child) {
          if (workoutProvider.isLoading || metricsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back! 💪',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Keep pushing towards your fitness goals!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Stats Grid
                Text(
                  'Your Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    _StatCard(
                      title: 'Total Workouts',
                      value: '${workoutProvider.totalWorkouts}',
                      icon: Icons.fitness_center,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: 'This Week',
                      value: '${workoutProvider.workoutsThisWeek}',
                      icon: Icons.calendar_today,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Current Weight',
                      value: metricsProvider.latestWeight != null
                          ? '${metricsProvider.latestWeight!.toStringAsFixed(1)} kg'
                          : 'N/A',
                      icon: Icons.monitor_weight,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Progress Photos',
                      value: '${metricsProvider.photos.length}',
                      icon: Icons.photo_camera,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Workouts
                if (workoutProvider.workouts.isNotEmpty) ...[
                  Text(
                    'Recent Workouts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...workoutProvider.workouts.take(3).map((workout) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.fitness_center,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(workout.exerciseName),
                        subtitle: Text(
                          '${workout.sets} sets × ${workout.reps} reps @ ${workout.weight} kg',
                        ),
                        trailing: Text(
                          '${workout.date.day}/${workout.date.month}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}