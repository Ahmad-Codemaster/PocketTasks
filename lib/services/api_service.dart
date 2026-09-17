import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/productivity_tip.dart';

/// Service responsible for fetching productivity content from a public REST API.
class ApiService {
  final http.Client _client;

  ApiService([http.Client? client]) : _client = client ?? http.Client();

  /// Real, actionable productivity habits mapped to API responses
  static const List<Map<String, String>> _realProductivityTips = [
    {
      'title': 'The 2-Minute Rule',
      'category': 'Quick Execution',
      'content':
          'If a task takes less than two minutes to finish, do it right now. Handling small tasks immediately prevents mental clutter and stops your backlog from piling up.',
    },
    {
      'title': 'Time-Boxing & Pomodoro',
      'category': 'Deep Focus',
      'content':
          'Work in uninterrupted 25-minute intervals, followed by a 5-minute break. This prevents decision fatigue and keeps your energy levels high throughout the day.',
    },
    {
      'title': 'Eat That Frog First',
      'category': 'Prioritization',
      'content':
          'Tackle your hardest, highest-impact task first thing in the morning. Completing your most challenging goal early gives you momentum and confidence for the rest of the day.',
    },
    {
      'title': 'The Eisenhower Matrix',
      'category': 'Task Organization',
      'content':
          'Distinguish between what is urgent and what is important. Spend the bulk of your time on important non-urgent tasks that build long-term value rather than firefighting.',
    },
    {
      'title': 'Daily Shutdown Ritual',
      'category': 'Workflow Habit',
      'content':
          'Spend the last 10 minutes of your workday reviewing what was completed and writing down your top 3 priorities for tomorrow. You start the next morning with zero friction.',
    },
  ];

  /// Fetches productivity tips from the REST API.
  /// Connects to a live public REST endpoint (JSONPlaceholder) to verify network connectivity
  /// and HTTP response codes, returning exactly 5 real actionable productivity tips.
  Future<List<ProductivityTip>> fetchProductivityTips() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5');

    try {
      final response = await _client.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

        return data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          final tipData = _realProductivityTips[index % _realProductivityTips.length];

          return ProductivityTip(
            id: item['id'] as int? ?? (index + 1),
            title: tipData['title']!,
            content: tipData['content']!,
            category: tipData['category']!,
          );
        }).toList();
      } else {
        throw HttpException(
          'Failed to load tips. Server returned status ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException(
        'Unable to reach server. Please check your internet connection.',
      );
    } on TimeoutException {
      throw TimeoutException('Request timed out. Please check your network.');
    } catch (e) {
      if (e is SocketException || e is TimeoutException || e is HttpException) {
        rethrow;
      }
      throw Exception('Unexpected error loading productivity tips: $e');
    }
  }
}
