import 'package:flutter/material.dart';
import '../../services/backend_service.dart';
import '../../utils/fitness_utils.dart';

class WorkoutView extends StatefulWidget {
  final BackendService backend;
  const WorkoutView({super.key, required this.backend});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  final _durationController = TextEditingController();
  String _selectedExercise = supportedExercises.first;
  bool _saving = false;

  Future<void> _log() async {
    setState(() => _saving = true);
    final res = await widget.backend.logWorkout(_selectedExercise, _durationController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: res.success ? Colors.green : Colors.red),
      );
      if (res.success) _durationController.clear();
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log Workout', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedExercise,
                    decoration: const InputDecoration(labelText: 'Exercise Type', prefixIcon: Icon(Icons.directions_run)),
                    items: supportedExercises.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _selectedExercise = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: 'Duration (minutes)', prefixIcon: Icon(Icons.timer)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _log,
                      icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_circle_outline),
                      label: const Text('Add Workout Entry'),
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
