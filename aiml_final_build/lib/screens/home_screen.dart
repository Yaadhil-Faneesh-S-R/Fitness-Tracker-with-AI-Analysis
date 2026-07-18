import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import 'views/dashboard_view.dart';
import 'views/profile_view.dart';
import 'views/workout_view.dart';
import 'views/meal_view.dart';
import 'views/weight_view.dart';
import 'views/goal_view.dart';
import 'views/history_view.dart';
import 'views/progress_view.dart';
import 'ai_analyzer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BackendService _backend = BackendService();
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<String> _users = [];
  String? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _backend.initializeApp();
    final users = await _backend.listUsers();
    final profile = await _backend.getProfile();
    if (mounted) {
      setState(() {
        _users = users;
        _currentUser = profile?.name ?? _backend.currentUserId;
        _isLoading = false;
      });
    }
  }

  Future<void> _switchUser(String userId) async {
    setState(() => _isLoading = true);
    _backend.switchUser(userId);
    final profile = await _backend.getProfile();
    final users = await _backend.listUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _currentUser = profile?.name ?? userId;
        _isLoading = false;
      });
    }
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0: return 'Dashboard';
      case 1: return 'User Profile';
      case 2: return 'Workout Logging';
      case 3: return 'Meal Tracking';
      case 4: return 'Weight Tracking';
      case 5: return 'Fitness Goal';
      case 6: return 'Progress & Analytics';
      case 7: return 'History';
      case 8: return 'AI Body Analysis';
      default: return 'Fitness Tracker';
    }
  }

  Widget _getView() {
    switch (_selectedIndex) {
      case 0: return DashboardView(backend: _backend, onNavigate: (index) => setState(() => _selectedIndex = index));
      case 1: return ProfileView(backend: _backend, onProfileSaved: _initializeApp);
      case 2: return WorkoutView(backend: _backend);
      case 3: return MealView(backend: _backend);
      case 4: return WeightView(backend: _backend);
      case 5: return GoalView(backend: _backend);
      case 6: return ProgressView(backend: _backend);
      case 7: return HistoryView(backend: _backend);
      case 8: return const AiAnalyzerScreen();
      default: return DashboardView(backend: _backend, onNavigate: (index) => setState(() => _selectedIndex = index));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: false,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        actions: [
          if (_users.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _users.contains(_currentUser?.toLowerCase().replaceAll(' ', '_')) ? _currentUser?.toLowerCase().replaceAll(' ', '_') : _users.first,
                  icon: const Icon(Icons.switch_account, color: Colors.black54),
                  onChanged: (String? newValue) {
                    if (newValue != null) _switchUser(newValue);
                  },
                  items: _users.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _currentUser ?? 'Guest',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
            indicatorColor: colorScheme.primaryContainer,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Home')),
              NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile')),
              NavigationRailDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: Text('Workouts')),
              NavigationRailDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: Text('Meals')),
              NavigationRailDestination(icon: Icon(Icons.monitor_weight_outlined), selectedIcon: Icon(Icons.monitor_weight), label: Text('Weight')),
              NavigationRailDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: Text('Goals')),
              NavigationRailDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: Text('Analytics')),
              NavigationRailDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: Text('History')),
              NavigationRailDestination(icon: Icon(Icons.camera_alt_outlined), selectedIcon: Icon(Icons.camera_alt), label: Text('AI Image Analysis')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey('$_currentUser-$_selectedIndex'),
              child: _getView(),
            ),
          ),
        ],
      ),
    );
  }
}
