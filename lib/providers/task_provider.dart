import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/task_priority.dart';
import '../repositories/task_repository.dart';

/// Enum representing filter options based on task completion status.
enum TaskStatusFilter {
  all,
  pending,
  completed;

  String get label {
    switch (this) {
      case TaskStatusFilter.all:
        return 'All';
      case TaskStatusFilter.pending:
        return 'Pending';
      case TaskStatusFilter.completed:
        return 'Completed';
    }
  }
}

/// Provider managing application state, filtering, search, and statistics calculations for tasks.
class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;
  TaskPriority? _priorityFilter;

  TaskProvider({TaskRepository? repository})
      : _repository = repository ?? TaskRepository() {
    loadTasks();
  }

  // --- Getters ---
  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  TaskStatusFilter get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;

  /// Returns tasks filtered by status, priority, and search query.
  List<Task> get filteredTasks {
    return _tasks.where((task) {
      // Status filter
      if (_statusFilter == TaskStatusFilter.pending && task.isCompleted) {
        return false;
      }
      if (_statusFilter == TaskStatusFilter.completed && !task.isCompleted) {
        return false;
      }

      // Priority filter
      if (_priorityFilter != null && task.priority != _priorityFilter) {
        return false;
      }

      // Search query
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDesc = task.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Returns tasks scheduled for today.
  List<Task> get todayTasks {
    return _tasks.where((t) => t.isDueToday).toList();
  }

  /// Dynamically calculated statistics
  int get totalTasksCount => _tasks.length;
  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingTasksCount => _tasks.where((t) => !t.isCompleted).length;

  /// Completion percentage from 0.0 to 1.0 (for progress bars)
  double get completionRatio {
    if (_tasks.isEmpty) return 0.0;
    return completedTasksCount / totalTasksCount;
  }

  /// Completion percentage as an integer (0 to 100)
  int get completionPercentage {
    return (completionRatio * 100).round();
  }

  // --- Operations ---

  /// Loads tasks from the repository.
  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _repository.getAllTasks();
    } catch (e) {
      _errorMessage = 'Failed to load tasks. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new task and persists it.
  Future<bool> addTask(Task task) async {
    _tasks.insert(0, task);
    notifyListeners();

    final success = await _repository.saveAllTasks(_tasks);
    if (!success) {
      _errorMessage = 'Failed to save task locally.';
      notifyListeners();
    }
    return success;
  }

  /// Updates an existing task.
  Future<bool> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();

      final success = await _repository.saveAllTasks(_tasks);
      if (!success) {
        _errorMessage = 'Failed to save changes.';
        notifyListeners();
      }
      return success;
    }
    return false;
  }

  /// Toggles task completion state.
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      notifyListeners();
      await _repository.saveAllTasks(_tasks);
    }
  }

  /// Deletes a task by ID.
  Future<bool> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks.removeAt(index);
      notifyListeners();
      return await _repository.saveAllTasks(_tasks);
    }
    return false;
  }

  // --- Filter and Search Setters ---

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(TaskStatusFilter filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = TaskStatusFilter.all;
    _priorityFilter = null;
    notifyListeners();
  }
}
