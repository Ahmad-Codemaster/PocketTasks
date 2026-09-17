import '../models/task.dart';
import '../services/task_storage_service.dart';

/// Repository coordinating task operations between the state management layer and storage service.
class TaskRepository {
  final TaskStorageService _storageService;

  TaskRepository({TaskStorageService? storageService})
      : _storageService = storageService ?? TaskStorageService();

  /// Retrieve all tasks from persistence.
  Future<List<Task>> getAllTasks() async {
    return await _storageService.loadTasks();
  }

  /// Persist the given list of tasks.
  Future<bool> saveAllTasks(List<Task> tasks) async {
    return await _storageService.saveTasks(tasks);
  }
}
