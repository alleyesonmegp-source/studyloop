import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'adaptive_engine.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  static const _storageKey = 'studyloop_state_v2';

  bool ready = false;
  LearnerProfile? profile;
  LearningGoal? activeGoal;
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

  int get xp => sessions.fold(
    0,
    (total, session) => total + 40 + (session.score * 60).round(),
  );

  int get level => xp ~/ 300 + 1;
  int get xpInLevel => xp % 300;

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
        if (json['activeGoal'] != null) {
          activeGoal = LearningGoal.fromJson(
            json['activeGoal'] as Map<String, dynamic>,
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

  Future<void> saveGoal(LearningGoal goal) async {
    activeGoal = goal;
    await _save();
    notifyListeners();
  }

  Future<void> removeGoal() async {
    activeGoal = null;
    await _save();
    notifyListeners();
  }

  Future<void> recordGoalSession({
    required List<bool> answers,
    required List<QuizQuestion> questions,
  }) async {
    final goal = activeGoal;
    if (goal == null || answers.isEmpty) return;
    final current = subjects[goal.subjectId];
    if (current != null) {
      var updated = current;
      for (final answer in answers) {
        updated = AdaptiveEngine.updateProgress(updated, correct: answer);
      }
      subjects[goal.subjectId] = updated;
    }
    final correct = answers.where((answer) => answer).length;
    final retryById = {
      for (final question in goal.retryQuestions) question.id: question,
    };
    for (var index = 0; index < answers.length; index++) {
      final question = questions[index];
      if (answers[index]) {
        retryById.remove(question.id);
      } else {
        retryById[question.id] = question;
      }
    }
    activeGoal = goal.copyWith(
      completedLoops: goal.completedLoops + 1,
      correctAnswers: goal.correctAnswers + correct,
      totalAnswers: goal.totalAnswers + answers.length,
      retryQuestions: retryById.values.take(6).toList(),
    );
    sessions.insert(
      0,
      StudySession(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        subjectId: goal.subjectId,
        minutes: profile?.focusMinutes ?? 10,
        score: correct / answers.length,
        completedAt: DateTime.now(),
      ),
    );
    await _save();
    notifyListeners();
  }

  double goalReadiness(LearningGoal goal) {
    final subjectMastery = subjects[goal.subjectId]?.mastery ?? .35;
    if (goal.totalAnswers == 0) return subjectMastery * .45;
    final practice = (goal.completedLoops / 5).clamp(0.0, 1.0);
    final retryPenalty = (goal.retryQuestions.length * .04).clamp(0.0, .16);
    return (goal.accuracy * .55 +
            subjectMastery * .25 +
            practice * .20 -
            retryPenalty)
        .clamp(0.0, 1.0);
  }

  Future<void> reset() async {
    profile = null;
    activeGoal = null;
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
        'activeGoal': activeGoal?.toJson(),
        'subjects': subjects.values.map((value) => value.toJson()).toList(),
        'sessions': sessions.take(60).map((value) => value.toJson()).toList(),
      }),
    );
  }
}
