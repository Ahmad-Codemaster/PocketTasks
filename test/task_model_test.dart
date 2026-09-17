import 'package:flutter_test/flutter_test.dart';
import 'package:flutternew/models/task.dart';
import 'package:flutternew/models/task_priority.dart';

void main() {
  group('Task Model & Priority Tests', () {
    test('Task creation and properties', () {
      final now = DateTime.now();
      final task = Task(
        id: 't-1',
        title: 'Complete internship assignment',
        description: 'Implement tests and polish UI',
        priority: TaskPriority.high,
        dueDate: now,
        isCompleted: false,
        createdAt: now,
      );

      expect(task.id, 't-1');
      expect(task.title, 'Complete internship assignment');
      expect(task.description, 'Implement tests and polish UI');
      expect(task.priority, TaskPriority.high);
      expect(task.isCompleted, isFalse);
      expect(task.isDueToday, isTrue);
      expect(task.isOverdue, isFalse);
    });

    test('Task isOverdue getter correctly detects past uncompleted tasks', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final overdueTask = Task(
        id: 't-2',
        title: 'Overdue task',
        priority: TaskPriority.medium,
        dueDate: pastDate,
        isCompleted: false,
        createdAt: pastDate,
      );

      expect(overdueTask.isOverdue, isTrue);

      // Completed task should not be overdue
      final completedTask = overdueTask.copyWith(isCompleted: true);
      expect(completedTask.isOverdue, isFalse);
    });

    test('Task copyWith modifies specified attributes', () {
      final now = DateTime.now();
      final task = Task(
        id: 't-3',
        title: 'Initial Title',
        priority: TaskPriority.low,
        dueDate: now,
        createdAt: now,
      );

      final updated = task.copyWith(
        title: 'Updated Title',
        isCompleted: true,
        priority: TaskPriority.high,
      );

      expect(updated.id, 't-3');
      expect(updated.title, 'Updated Title');
      expect(updated.priority, TaskPriority.high);
      expect(updated.isCompleted, isTrue);
    });

    test('Task JSON serialization and deserialization', () {
      final now = DateTime(2026, 9, 17, 12, 0);
      final task = Task(
        id: 'json-1',
        title: 'Test JSON',
        description: 'Verify serialization',
        priority: TaskPriority.high,
        dueDate: now,
        isCompleted: true,
        createdAt: now,
      );

      final json = task.toJson();
      expect(json['id'], 'json-1');
      expect(json['title'], 'Test JSON');
      expect(json['priority'], 'high');
      expect(json['isCompleted'], isTrue);

      final fromJsonTask = Task.fromJson(json);
      expect(fromJsonTask.id, task.id);
      expect(fromJsonTask.title, task.title);
      expect(fromJsonTask.priority, TaskPriority.high);
      expect(fromJsonTask.isCompleted, isTrue);
      expect(fromJsonTask.dueDate, now);
    });

    test('TaskPriority enum mapping', () {
      expect(TaskPriority.low.displayName, 'Low');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.high.displayName, 'High');

      expect(TaskPriority.fromJson('high'), TaskPriority.high);
      expect(TaskPriority.fromJson('unknown'), TaskPriority.medium);

      expect(TaskPriority.low.icon, isNotNull);
      expect(TaskPriority.medium.icon, isNotNull);
      expect(TaskPriority.high.icon, isNotNull);
    });
  });
}
