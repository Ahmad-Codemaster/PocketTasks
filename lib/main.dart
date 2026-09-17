import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PocketTasksApp());
}

/// Root application widget for PocketTasks.
class PocketTasksApp extends StatelessWidget {
  final TaskProvider? taskProvider;
  final Widget? home;

  const PocketTasksApp({super.key, this.taskProvider, this.home});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => taskProvider ?? TaskProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'PocketTasks',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: home ?? const SplashScreen(),
      ),
    );
  }
}
