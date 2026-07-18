import 'package:flutter/material.dart';
import '../../services/backend_service.dart';
import '../../models/models.dart';

class HistoryView extends StatefulWidget {
  final BackendService backend;
  const HistoryView({super.key, required this.backend});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WorkoutRecord> _workouts = [];
  List<MealRecord> _meals = [];
  List<WeightEntry> _weight = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final workouts = await widget.backend.getWorkoutHistory();
    final meals = await widget.backend.getMealHistory();
    final weight = await widget.backend.getWeightHistory();
    if (mounted) {
      setState(() {
        _workouts = workouts.reversed.toList();
        _meals = meals.reversed.toList();
        _weight = weight.reversed.toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center), text: 'Workouts'),
            Tab(icon: Icon(Icons.fastfood), text: 'Meals'),
            Tab(icon: Icon(Icons.monitor_weight), text: 'Weight'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildList(_workouts, (w) => 'Logged ${w.duration} min of ${w.exercise}\nBurned ${w.calories} cal', Icons.fitness_center),
              _buildList(_meals, (m) => '${m.type}: ${m.foodName}\n${m.calories} cal', Icons.restaurant),
              _buildList(_weight, (e) => 'Weight: ${e.weightKg} kg', Icons.monitor_weight),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<dynamic> items, String Function(dynamic) subtitle, IconData icon) {
    if (items.isEmpty) return const Center(child: Text('No history found.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(child: Icon(icon, size: 20)),
            title: Text(item.date, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle(item)),
                if (item.userName != null && item.userName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'By: ${item.userName}',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
