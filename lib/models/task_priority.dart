import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Defines the priority levels available for a task.
enum TaskPriority {
  low,
  medium,
  high;

  /// User-facing display label with proper capitalization.
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  /// Theme color associated with each priority level.
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return AppTheme.priorityLow;
      case TaskPriority.medium:
        return AppTheme.priorityMedium;
      case TaskPriority.high:
        return AppTheme.priorityHigh;
    }
  }

  /// Specific urgency icon for each priority level.
  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.keyboard_double_arrow_down_rounded;
      case TaskPriority.medium:
        return Icons.density_medium_rounded;
      case TaskPriority.high:
        return Icons.keyboard_double_arrow_up_rounded;
    }
  }

  /// Serialize priority to string.
  String toJson() => name;

  /// Deserialize priority from string.
  static TaskPriority fromJson(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}
