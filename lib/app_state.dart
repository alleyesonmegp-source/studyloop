import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'adaptive_engine.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  static const _storageKey = 'studyloop_state_v2';

  bool ready = false;
  LearnerProfile? profile;
  final Map<String, SubjectProgress> subjects = {};
  final List<StudySession> sessions = [];

  bool get onboarded => profile != null;
  List<SubjectProgress> get plan => AdaptiveEngine.prioritize(subjects.values);

  int get todaySessions {
    final now = DateTime.now();
    return sessions
        .where(
          (session) =>
              session.completedAt.year == now.year &&
              session.completedAt.month == now.month &&
              session.completedAt.day == now.day,
        )
        .length;
  }

  int get totalMinutes =>
      sessions.fold(0, (total, session) => total + session.minutes);

  int get streak {
    if (sessions.isEmpty) return 0;
    final days = sessions
        .map(
          (session) => DateTime(
            session.completedAt.year,
            session.completedAt.month,
            session.completedAt.day,
          ),
        )
        .toSet();
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        if (json['profile'] != null) {
          profile = LearnerProfile.fromJson(
            json['profile'] as Map<String, dynamic>,
          );
        }
        for (final item in (json['subjects'] as List? ?? const [])) {
          final subject = SubjectProgress.fromJson(
            item as Map<String, dynamic>,
          );
          subjects[subject.id] = subject;
        }
        sessions.addAll(
          (json['sessions'] as List? ?? const []).map(
            (item) => StudySession.fromJson(item as Map<String, dynamic>),
          ),
        );
      } catch (_) {
        subjects.clear();
        sessions.clear();
      }
    }
    if (subjects.isEmpty) {
      for (final subject in AdaptiveEngine.seedSubjects()) {
        subjects[subject.id] = subject;
      }
    }
    ready = true;
    notifyListeners();
  }

  Future<void> finishOnboarding(LearnerProfile value) async {
    profile = value;
    await _save();
    notifyListeners();
  }

  Future<void> recordSession({
    required String subjectId,
    required int minutes,
    required List<bool> answers,
  }) async {
    final current = subjects[subjectId];
    if (current == null || answers.isEmpty) return;
    var updated = current;
    for (final answer in answers) {
      updated = AdaptiveEngine.updateProgress(updated, correct: answer);
    }
    subjects[subjectId] = updated;
    sessions.insert(
      0,
      StudySession(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        subjectId: subjectId,
        minutes: minutes,
        score: answers.where((answer) => answer).length / answers.length,
        completedAt: DateTime.now(),
      ),
    );
    await _save();
    notifyListeners();
  }

  Future<void> recordAiQuiz({
    required List<bool> answers,
    required List<QuizQuestion> questions,
  }) async {
    for (var index = 0; index < answers.length; index++) {
      final subjectId = questions[index].subjectId;
      final current = subjects[subjectId];
      if (current != null) {
        subjects[subjectId] = AdaptiveEngine.updateProgress(
          current,
          correct: answers[index],
        );
      }
    }
    sessions.insert(
      0,
      StudySession(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        subjectId: questions.first.subjectId,
        minutes: 5,
        score: answers.where((answer) => answer).length / answers.length,
        completedAt: DateTime.now(),
      ),
    );
    await _save();
    notifyListeners();
  }

  Future<void> reset() async {
    profile = null;
    subjects
      ..clear()
      ..addEntries(
        AdaptiveEngine.seedSubjects().map(
          (subject) => MapEntry(subject.id, subject),
        ),
      );
    sessions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode({
        'profile': profile?.toJson(),
        'subjects': subjects.values.map((value) => value.toJson()).toList(),
        'sessions': sessions.take(60).map((value) => value.toJson()).toList(),
      }),
    );
  }
}
