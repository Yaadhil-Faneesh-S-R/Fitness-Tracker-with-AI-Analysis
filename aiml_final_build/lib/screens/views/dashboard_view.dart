import 'package:flutter/material.dart';
import '../../services/backend_service.dart';
import '../../widgets/stat_card.dart';

class DashboardView extends StatefulWidget {
  final BackendService backend;
  final Function(int) onNavigate;
  const DashboardView({super.key, required this.backend, required this.onNavigate});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Map<String, double> _nutrition = {'burned': 0.0, 'consumed': 0.0, 'net': 0.0};
  Map<String, dynamic> _goalProgress = {'progress': 0.0};
  Map<String, dynamic> _workoutStats = {'totalWorkouts': 0, 'totalCalories': 0.0, 'avgDuration': 0.0};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final nutrition = await widget.backend.getDailyNutritionSummary();
    final goal = await widget.backend.getGoalProgress();
    final stats = await widget.backend.getWorkoutStats();
    
    if (mounted) {
      setState(() {
        _nutrition = nutrition;
        _goalProgress = goal;
        _workoutStats = stats;
        _loading = false;
      });
    }
  }

  Future<void> _calculateBmi() async {
    final res = await widget.backend.getBmi();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('BMI Calculator'),
        content: Text('Your BMI is ${res['bmi']}\nCategory: ${res['category']}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Fitness and Diet Tracking System',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Daily Summary',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Daily Burned',
                  value: '${_nutrition['burned']} cal',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: StatCard(
                  title: 'Daily Consumed',
                  value: '${_nutrition['consumed']} cal',
                  icon: Icons.restaurant,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: StatCard(
                  title: 'Net Calories',
                  value: '${_nutrition['net']} cal',
                  icon: Icons.calculate,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _QuickActionBtn(icon: Icons.calculate, label: 'Calculate BMI', color: Colors.indigo, onTap: _calculateBmi),
              _QuickActionBtn(icon: Icons.fitness_center, label: 'Add Workout', color: Colors.teal, onTap: () => widget.onNavigate(2)),
              _QuickActionBtn(icon: Icons.fastfood, label: 'Add Meal', color: Colors.orange, onTap: () => widget.onNavigate(3)),
              _QuickActionBtn(icon: Icons.history, label: 'View History', color: Colors.blueGrey, onTap: () => widget.onNavigate(7)),
              _QuickActionBtn(icon: Icons.monitor_weight, label: 'Weight Tracking', color: Colors.blue, onTap: () => widget.onNavigate(4)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fitness Goal Progress',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Progress?'),
                      content: const Text('This will clear your fitness goal and weight history for this user. This action cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await widget.backend.resetGoalProgress();
                    _loadData();
                  }
                },
                icon: const Icon(Icons.refresh, size: 18, color: Colors.red),
                label: const Text('Reset Goal', style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Goal: ${_goalProgress['goal'] ?? 'Not set'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Target: ${_goalProgress['target'] ?? '0'} kg'),
                          if (_goalProgress['current'] != null)
                            Text('Current: ${_goalProgress['current']} kg', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (_goalProgress['progress'] ?? 0.0) / 100,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text('${_goalProgress['progress'] ?? 0.0}% achieved'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Workout Statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Workouts',
                  value: '${_workoutStats['totalWorkouts']}',
                  icon: Icons.fitness_center,
                  color: Colors.teal,
                ),
              ),
              Expanded(
                child: StatCard(
                  title: 'Avg Duration',
                  value: '${_workoutStats['avgDuration']} min',
                  icon: Icons.timer,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        side: BorderSide(color: color.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

