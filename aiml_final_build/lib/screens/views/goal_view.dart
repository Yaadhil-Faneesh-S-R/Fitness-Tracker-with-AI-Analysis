import 'package:flutter/material.dart';
import '../../services/backend_service.dart';

class GoalView extends StatefulWidget {
  final BackendService backend;
  const GoalView({super.key, required this.backend});

  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView> {
  final _targetController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedType = 'Weight Loss';
  final List<String> _types = ['Weight Loss', 'Muscle Gain', 'Maintenance'];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final goal = await widget.backend.getGoal();
    if (goal != null) {
      _selectedType = goal.type;
      _targetController.text = goal.targetWeightKg.toString();
      _durationController.text = goal.durationWeeks.toString();
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final res = await widget.backend.saveGoal(_selectedType, _targetController.text, _durationController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.message), backgroundColor: res.success ? Colors.green : Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fitness Goal', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Goal Type', prefixIcon: Icon(Icons.star)),
                    items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _targetController,
                    decoration: const InputDecoration(
                      labelText: 'Final Target Weight (kg)',
                      hintText: 'e.g. 70.0',
                      prefixIcon: Icon(Icons.track_changes),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: _durationController, decoration: const InputDecoration(labelText: 'Goal Duration (weeks)', prefixIcon: Icon(Icons.calendar_today)), keyboardType: TextInputType.number),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.check_circle), label: const Text('Save Goal')),
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
