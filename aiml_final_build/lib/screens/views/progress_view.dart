import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/backend_service.dart';
import '../../widgets/chart_widget.dart';
import '../../models/models.dart';

class ProgressView extends StatefulWidget {
  final BackendService backend;
  const ProgressView({super.key, required this.backend});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  List<WeightEntry> _weightHistory = [];
  Map<String, double> _weeklyCalories = {};
  Map<String, int> _weeklyFrequency = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final weight = await widget.backend.getWeightHistory();
    final calories = await widget.backend.getWeeklyCalories();
    final frequency = await widget.backend.getWeeklyFrequency();
    
    if (mounted) {
      setState(() {
        _weightHistory = weight;
        _weeklyCalories = calories;
        _weeklyFrequency = frequency;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    // Weight Spots
    final weightSpots = _weightHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weightKg)).toList();
    
    // Calorie Spots
    final calSpots = _weeklyCalories.values.toList().asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    
    // Frequency Spots
    final freqSpots = _weeklyFrequency.values.toList().asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress & Analytics', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          if (weightSpots.isNotEmpty)
            ChartWidget(
              title: 'Weight Trend (kg)',
              spots: weightSpots,
              color: Colors.blue,
              minY: _weightHistory.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b) - 2,
              maxY: _historyMaxWeight(),
            ),
          const SizedBox(height: 24),
          
          ChartWidget(
            title: 'Weekly Calories Burned',
            spots: calSpots,
            color: Colors.orange,
            maxY: _historyMaxCalories(),
          ),
          const SizedBox(height: 24),
          
          ChartWidget(
            title: 'Workout Frequency (count/day)',
            spots: freqSpots,
            color: Colors.teal,
            maxY: _historyMaxFrequency(),
          ),
        ],
      ),
    );
  }

  double _historyMaxWeight() {
    if (_weightHistory.isEmpty) return 100;
    return _weightHistory.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b) + 2;
  }

  double _historyMaxCalories() {
    if (_weeklyCalories.isEmpty) return 1000;
    final max = _weeklyCalories.values.reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1000 : max + 200;
  }

  double _historyMaxFrequency() {
    if (_weeklyFrequency.isEmpty) return 5;
    final max = _weeklyFrequency.values.reduce((a, b) => a > b ? a : b).toDouble();
    return max == 0 ? 5 : max + 1;
  }
}
