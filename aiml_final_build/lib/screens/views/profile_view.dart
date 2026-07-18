import 'package:flutter/material.dart';
import '../../services/backend_service.dart';
import '../../models/models.dart';

class ProfileView extends StatefulWidget {
  final BackendService backend;
  final VoidCallback? onProfileSaved;
  const ProfileView({super.key, required this.backend, this.onProfileSaved});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await widget.backend.getProfile();
    if (profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _heightController.text = profile.heightCm.toString();
      _weightController.text = profile.weightKg.toString();
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final res = await widget.backend.saveProfile(
      _nameController.text,
      _ageController.text,
      _heightController.text,
      _weightController.text,
    );
    if (!mounted) return;
    
    if (res.success && widget.onProfileSaved != null) {
      widget.onProfileSaved!();
    }

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
          Text(
            'User Profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 16),
                  TextField(controller: _ageController, decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake)), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  TextField(controller: _heightController, decoration: const InputDecoration(labelText: 'Height (cm)', prefixIcon: Icon(Icons.height)), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  TextField(controller: _weightController, decoration: const InputDecoration(labelText: 'Weight (kg)', prefixIcon: Icon(Icons.monitor_weight)), keyboardType: TextInputType.number),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Profile'),
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
