import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_priority.dart';
import '../providers/task_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

/// The Tasks management screen offering live search, status and priority filtering,
/// task CRUD actions, and contextual empty states.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text('My Tasks'),
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
          final filtered = provider.filteredTasks;
          final hasTasks = provider.tasks.isNotEmpty;
          final isSearching = provider.searchQuery.trim().isNotEmpty;

          return Column(
            children: [
              // Search and Filter Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => provider.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search tasks by title...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Filter Controls (Status & Priority)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Status filters: All, Pending, Completed
                    ...TaskStatusFilter.values.map((filter) {
                      final isSelected = provider.statusFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(filter.label),
                          selected: isSelected,
                          onSelected: (_) => provider.setStatusFilter(filter),
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(width: 4),
                    Container(
                      height: 24,
                      width: 1,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    const SizedBox(width: 8),

                    // Priority filters
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: const Text('All Priorities'),
                        selected: provider.priorityFilter == null,
                        onSelected: (_) => provider.setPriorityFilter(null),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ...TaskPriority.values.map((priority) {
                      final isSelected = provider.priorityFilter == priority;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(priority.displayName),
                          selected: isSelected,
                          onSelected: (_) {
                            provider.setPriorityFilter(isSelected ? null : priority);
                          },
                          showCheckmark: false,
                          avatar: Icon(
                            priority.icon,
                            size: 16,
                            color: priority.color,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Task List or Empty State
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadTasks(),
                  child: Builder(
                    builder: (context) {
                      if (!hasTasks) {
                        return ListView(
                          children: [
                            const SizedBox(height: 40),
                            EmptyState(
                              icon: Icons.checklist_rounded,
                              title: 'No tasks yet',
                              subtitle:
                                  'Create your first task and start getting things done.',
                              actionText: 'Create Task',
                              onAction: () => _openAddTask(context),
                            ),
                          ],
                        );
                      }

                      if (filtered.isEmpty) {
                        if (isSearching) {
                          return ListView(
                            children: [
                              const SizedBox(height: 40),
                              EmptyState(
                                icon: Icons.search_off_rounded,
                                title: 'No matching tasks',
                                subtitle: 'Try a different search term or clear the filter.',
                                actionText: 'Clear Search',
                                onAction: () {
                                  _searchController.clear();
                                  provider.setSearchQuery('');
                                },
                              ),
                            ],
                          );
                        }

                        if (provider.statusFilter == TaskStatusFilter.completed) {
                          return ListView(
                            children: const [
                              SizedBox(height: 40),
                              EmptyState(
                                icon: Icons.done_all_rounded,
                                title: 'No completed tasks',
                                subtitle: 'Complete a task to view it under completed tasks.',
                              ),
                            ],
                          );
                        }

                        if (provider.statusFilter == TaskStatusFilter.pending) {
                          return ListView(
                            children: const [
                              SizedBox(height: 40),
                              EmptyState(
                                icon: Icons.task_alt_rounded,
                                title: 'All caught up!',
                                subtitle: 'No pending tasks left in this category.',
                              ),
                            ],
                          );
                        }

                        return ListView(
                          children: const [
                            SizedBox(height: 40),
                            EmptyState(
                              icon: Icons.filter_alt_off_rounded,
                              title: 'No matching tasks',
                              subtitle: 'Try changing your filter selections.',
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4, bottom: 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final task = filtered[index];
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
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTask(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
