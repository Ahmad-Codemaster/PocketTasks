import 'package:flutter_test/flutter_test.dart';
import 'package:flutternew/models/task.dart';
import 'package:flutternew/models/task_priority.dart';
import 'package:flutternew/providers/task_provider.dart';
import 'package:flutternew/repositories/task_repository.dart';

/// Fake repository for isolated in-memory unit testing of TaskProvider.
class FakeTaskRepository implements TaskRepository {
  List<Task> storage = [];

  @override
  Future<List<Task>> getAllTasks() async => List.from(storage);

  @override
  Future<bool> saveAllTasks(List<Task> tasks) async {
    storage = List.from(tasks);
    return true;
  }
}

void main() {
  group('TaskProvider Tests', () {
    late FakeTaskRepository fakeRepository;
    late TaskProvider provider;

    setUp(() async {
      fakeRepository = FakeTaskRepository();
      fakeRepository.storage = [
        Task(
          id: '1',
          title: 'Buy groceries',
          description: 'Milk and eggs',
          priority: TaskPriority.low,
          dueDate: DateTime.now(),
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Finish Flutter Project',
          description: 'Portfolio app',
          priority: TaskPriority.high,
          dueDate: DateTime.now(),
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '3',
          title: 'Schedule dentist appointment',
          description: 'Routine checkup',
          priority: TaskPriority.medium,
          dueDate: DateTime.now().add(const Duration(days: 5)),
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

      provider = TaskProvider(repository: fakeRepository);
      await provider.loadTasks();
    });

    test('Statistics calculations are dynamic and accurate', () {
      expect(provider.totalTasksCount, 3);
      expect(provider.completedTasksCount, 1);
      expect(provider.pendingTasksCount, 2);
      // 1 / 3 = 33%
      expect(provider.completionPercentage, 33);
      expect(provider.completionRatio, closeTo(0.333, 0.01));
    });

    test('Status filtering correctly separates All, Pending, and Completed', () {
      // Default is All
      expect(provider.filteredTasks.length, 3);

      // Pending only
      provider.setStatusFilter(TaskStatusFilter.pending);
      expect(provider.filteredTasks.length, 2);
      expect(provider.filteredTasks.every((t) => !t.isCompleted), isTrue);

      // Completed only
      provider.setStatusFilter(TaskStatusFilter.completed);
      expect(provider.filteredTasks.length, 1);
      expect(provider.filteredTasks.first.id, '1');
      expect(provider.filteredTasks.first.isCompleted, isTrue);
    });

    test('Priority filtering isolates specific priority levels', () {
      provider.setPriorityFilter(TaskPriority.high);
      expect(provider.filteredTasks.length, 1);
      expect(provider.filteredTasks.first.title, 'Finish Flutter Project');

      provider.setPriorityFilter(TaskPriority.low);
      expect(provider.filteredTasks.length, 1);
      expect(provider.filteredTasks.first.title, 'Buy groceries');

      provider.setPriorityFilter(null);
      expect(provider.filteredTasks.length, 3);
    });

    test('Live search matches task title and description', () {
      provider.setSearchQuery('groceries');
      expect(provider.filteredTasks.length, 1);
      expect(provider.filteredTasks.first.id, '1');

      provider.setSearchQuery('portfolio');
      expect(provider.filteredTasks.length, 1);
      expect(provider.filteredTasks.first.id, '2');

      provider.setSearchQuery('nonexistent');
      expect(provider.filteredTasks.isEmpty, isTrue);

      provider.clearFilters();
      expect(provider.filteredTasks.length, 3);
    });

    test('Toggle completion modifies status and recalculates statistics', () async {
      expect(provider.completedTasksCount, 1);

      await provider.toggleTaskCompletion('2');
      expect(provider.completedTasksCount, 2);
      expect(provider.pendingTasksCount, 1);
      expect(provider.completionPercentage, 67);

      await provider.toggleTaskCompletion('2');
      expect(provider.completedTasksCount, 1);
      expect(provider.completionPercentage, 33);
    });

    test('Add, update, and delete task mutations', () async {
      final newTask = Task(
        id: '4',
        title: 'Read book',
        priority: TaskPriority.low,
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await provider.addTask(newTask);
      expect(provider.totalTasksCount, 4);

      final updatedTask = newTask.copyWith(title: 'Read 2 chapters of book');
      await provider.updateTask(updatedTask);
      expect(provider.tasks.firstWhere((t) => t.id == '4').title, 'Read 2 chapters of book');

      await provider.deleteTask('4');
      expect(provider.totalTasksCount, 3);
    });
  });
}
