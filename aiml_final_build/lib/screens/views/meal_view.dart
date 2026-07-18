import 'package:flutter/material.dart';
import '../../services/backend_service.dart';

class MealView extends StatefulWidget {
  final BackendService backend;
  const MealView({super.key, required this.backend});

  @override
  State<MealView> createState() => _MealViewState();
}

class _MealViewState extends State<MealView> {
  final _foodController = TextEditingController();
  final _calController = TextEditingController();
  String _selectedType = 'Breakfast';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  bool _saving = false;

  Future<void> _add() async {
    setState(() => _saving = true);
    final res = await widget.backend.logMeal(_selectedType, _foodController.text, _calController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: res.success ? Colors.green : Colors.red),
      );
      if (res.success) {
        _foodController.clear();
        _calController.clear();
      }
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
          Text('Meal Tracking', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Meal Type', prefixIcon: Icon(Icons.fastfood)),
                    items: _mealTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: _foodController, decoration: const InputDecoration(labelText: 'Food Name', prefixIcon: Icon(Icons.restaurant))),
                  const SizedBox(height: 16),
                  TextField(controller: _calController, decoration: const InputDecoration(labelText: 'Calories', prefixIcon: Icon(Icons.local_fire_department)), keyboardType: TextInputType.number),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _add,
                      icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_shopping_cart),
                      label: const Text('Add Meal Entry'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
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
