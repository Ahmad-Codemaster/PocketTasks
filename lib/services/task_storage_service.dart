import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/task_priority.dart';

/// Handles low-level reading and writing of tasks to local persistent storage (SharedPreferences).
class TaskStorageService {
  static const String _tasksKey = 'pocket_tasks_data_v1';
  static const String _initializedKey = 'pocket_tasks_has_initial_data';

  final SharedPreferences? _prefs;

  TaskStorageService([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// Loads stored tasks from local storage.
  /// If it is the first launch, populates helpful initial starter tasks.
  Future<List<Task>> loadTasks() async {
    try {
      final prefs = await _getPrefs();
      final isInitialized = prefs.getBool(_initializedKey) ?? false;

      if (!isInitialized) {
        final sampleTasks = _getSampleInitialTasks();
        await saveTasks(sampleTasks);
        await prefs.setBool(_initializedKey, true);
        return sampleTasks;
      }

      final jsonString = prefs.getString(_tasksKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(jsonString) as List<dynamic>;
      return decodedList
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // In case of parsing or storage errors, log and return empty list rather than crashing.
      return [];
    }
  }

  /// Saves the complete list of tasks to local storage.
  Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await _getPrefs();
      final rawList = tasks.map((task) => task.toJson()).toList();
      final jsonString = jsonEncode(rawList);
      return await prefs.setString(_tasksKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Initial starter sample tasks for new users.
  List<Task> _getSampleInitialTasks() {
    final now = DateTime.now();
    return [
      Task(
        id: 'sample-1',
        title: 'Review project requirements & design',
        description: 'Verify all criteria for PocketTasks mobile app.',
        priority: TaskPriority.high,
        dueDate: now,
        isCompleted: true,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      Task(
        id: 'sample-2',
        title: 'Plan daily productivity goals',
        description: 'Prioritize top 3 tasks for maximum output today.',
        priority: TaskPriority.medium,
        dueDate: now,
        isCompleted: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Task(
        id: 'sample-3',
        title: 'Explore new Flutter Material 3 widgets',
        description: 'Check out updated NavigationBar and card elevations.',
        priority: TaskPriority.low,
        dueDate: now.add(const Duration(days: 1)),
        isCompleted: false,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
