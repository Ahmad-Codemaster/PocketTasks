import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutternew/main.dart';
import 'package:flutternew/models/task.dart';
import 'package:flutternew/models/task_priority.dart';
import 'package:flutternew/providers/task_provider.dart';
import 'package:flutternew/repositories/task_repository.dart';
import 'package:flutternew/screens/main_navigation_screen.dart';
import 'package:flutternew/screens/task_form_screen.dart';

class MockTaskRepository implements TaskRepository {
  List<Task> mockTasks = [];

  @override
  Future<List<Task>> getAllTasks() async => List.from(mockTasks);

  @override
  Future<bool> saveAllTasks(List<Task> tasks) async {
    mockTasks = List.from(tasks);
    return true;
  }
}

void main() {
  testWidgets('PocketTasks displays greetings, navigation, and statistics', (WidgetTester tester) async {
    final mockRepo = MockTaskRepository();
    final now = DateTime.now();
    mockRepo.mockTasks = [
      Task(
        id: '1',
        title: 'Complete widget test',
        priority: TaskPriority.high,
        dueDate: now,
        isCompleted: false,
        createdAt: now,
      ),
      Task(
        id: '2',
        title: 'Review PR',
        priority: TaskPriority.low,
        dueDate: now,
        isCompleted: true,
        createdAt: now,
      ),
    ];

    final provider = TaskProvider(repository: mockRepo);
    await provider.loadTasks();

    await tester.pumpWidget(PocketTasksApp(
      taskProvider: provider,
      home: const MainNavigationScreen(),
    ));
    await tester.pumpAndSettle();

    // Verify greetings and headers
    expect(find.text("Let's get things done."), findsOneWidget);
    expect(find.text("Today's Tasks"), findsOneWidget);

    // Verify statistics cards are dynamically calculated
    expect(find.text('Total Tasks'), findsOneWidget);
    expect(find.text('2'), findsWidgets); // Total tasks count & Today's tasks badge
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);

    // Verify navigation destinations
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Productivity'), findsOneWidget);

    // Switch to Tasks Screen
    await tester.tap(find.byIcon(Icons.check_box_outlined));
    await tester.pumpAndSettle();
    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('Search tasks by title...'), findsOneWidget);

    // Switch to Productivity Screen
    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Productivity Overview'), findsOneWidget);
  });

  testWidgets('Task form validates required title field', (WidgetTester tester) async {
    final mockRepo = MockTaskRepository();
    final provider = TaskProvider(repository: mockRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: PocketTasksApp(taskProvider: provider),
      ),
    );
    await tester.pumpAndSettle();

    // Open Task Form directly
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Task Title *'), findsOneWidget);

    // Scroll into view and tap Create Task with empty title
    final createButton = find.text('Create Task');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    // Verify validation error
    expect(find.text('Task title is required.'), findsOneWidget);
  });
}
