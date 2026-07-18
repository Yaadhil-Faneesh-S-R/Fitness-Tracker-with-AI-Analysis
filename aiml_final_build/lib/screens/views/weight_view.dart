import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/backend_service.dart';
import '../../widgets/chart_widget.dart';
import '../../models/models.dart';

class WeightView extends StatefulWidget {
  final BackendService backend;
  const WeightView({super.key, required this.backend});

  @override
  State<WeightView> createState() => _WeightViewState();
}

class _WeightViewState extends State<WeightView> {
  final _weightController = TextEditingController();
  List<WeightEntry> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await widget.backend.getWeightHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _loading = false;
      });
    }
  }

  Future<void> _add() async {
    final res = await widget.backend.logWeight(_weightController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.message), backgroundColor: res.success ? Colors.green : Colors.red),
    );
    if (res.success) {
      _weightController.clear();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final spots = _history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weightKg)).toList();
    final latest = _history.isNotEmpty ? _history.last.weightKg : 0.0;
    
    double weightChange = 0.0;
    if (_history.length >= 2) {
      weightChange = _history.last.weightKg - _history[_history.length - 2].weightKg;
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weight Tracking', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (_history.length > 1)
            ChartWidget(
              title: 'Weight Trend',
              spots: spots,
              color: Colors.blue,
              minY: _history.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b) - 5,
              maxY: _history.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b) + 5,
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Latest Weight', style: TextStyle(color: Colors.grey)),
                        Text('$latest kg', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Weight Change', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${weightChange > 0 ? "+" : ""}${weightChange.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: weightChange > 0 ? Colors.red : (weightChange < 0 ? Colors.green : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                   TextField(
                    controller: _weightController, 
                    decoration: const InputDecoration(
                      labelText: 'New Weight Entry (kg)', 
                      hintText: 'e.g. 75.5',
                      prefixIcon: Icon(Icons.monitor_weight),
                    ), 
                    keyboardType: TextInputType.number,
                  ),
                   const SizedBox(height: 24),
                   SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Add Weight Entry')),
                   ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('Weight History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final entry = _history[_history.length - 1 - index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text('${entry.weightKg} kg'),
                  subtitle: Text(entry.date),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
