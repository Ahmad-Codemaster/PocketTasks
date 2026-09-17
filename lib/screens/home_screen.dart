import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/statistic_card.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

/// The Home / Dashboard screen displaying dynamic statistics and today's tasks.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  void _openAddTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketTasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Task',
            onPressed: () => _openAddTask(context),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final todayTasks = provider.todayTasks;

          return RefreshIndicator(
            onRefresh: () => provider.loadTasks(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                // Header
                Text(
                  _getGreeting(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Let's get things done.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // Dynamic Statistics Cards
                Row(
                  children: [
                    StatisticCard(
                      title: 'Total Tasks',
                      value: '${provider.totalTasksCount}',
                      icon: Icons.assignment_outlined,
                      iconColor: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    StatisticCard(
                      title: 'Completed',
                      value: '${provider.completedTasksCount}',
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
                    StatisticCard(
                      title: 'Pending',
                      value: '${provider.pendingTasksCount}',
                      icon: Icons.hourglass_empty_rounded,
                      iconColor: AppTheme.warningColor,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Today's Tasks Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Tasks",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${todayTasks.length}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Today's Task List or Empty State
                if (todayTasks.isEmpty)
                  EmptyState(
                    icon: Icons.event_available_rounded,
                    title: 'No tasks for today',
                    subtitle: 'All clear! Create a task scheduled for today to get started.',
                    actionText: 'Add Today’s Task',
                    onAction: () => _openAddTask(context),
                  )
                else
                  ...todayTasks.map((task) {
                    return TaskCard(
                      task: task,
                      onToggleCompletion: (_) =>
                          provider.toggleTaskCompletion(task.id),
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TaskFormScreen(task: task),
                          ),
                        );
                      },
                      onDelete: () => provider.deleteTask(task.id),
                    );
                  }),
                const SizedBox(height: 80), // Padding for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTask(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
    );
  }
}
