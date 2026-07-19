import 'package:flutter/material.dart';

import 'app_state.dart';
import 'ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyLoopApp());
}

class StudyLoopApp extends StatefulWidget {
  const StudyLoopApp({super.key});

  @override
  State<StudyLoopApp> createState() => _StudyLoopAppState();
}

class _StudyLoopAppState extends State<StudyLoopApp> {
  final state = AppState();

  @override
  void initState() {
    super.initState();
    state.load();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF4F46E5);
    return MaterialApp(
      title: 'StudyLoop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: AnimatedBuilder(
        animation: state,
        builder: (context, _) {
          if (!state.ready) return const StudyLoopSplash();
          if (!state.onboarded) return OnboardingScreen(state: state);
          return StudyLoopShell(state: state);
        },
      ),
    );
  }
}
