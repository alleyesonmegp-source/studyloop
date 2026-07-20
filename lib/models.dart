import 'dart:convert';

class LearnerProfile {
  const LearnerProfile({
    required this.name,
    required this.grade,
    required this.focusMinutes,
  });

  final String name;
  final String grade;
  final int focusMinutes;

  Map<String, dynamic> toJson() => {
    'name': name,
    'grade': grade,
    'focusMinutes': focusMinutes,
  };

  factory LearnerProfile.fromJson(Map<String, dynamic> json) => LearnerProfile(
    name: json['name'] as String? ?? 'Alex',
    grade: json['grade'] as String? ?? 'Scuola media',
    focusMinutes: json['focusMinutes'] as int? ?? 20,
  );
}

class LearningGoal {
  const LearningGoal({
    required this.id,
    required this.subjectId,
    required this.topic,
    required this.material,
    required this.examDate,
    required this.createdAt,
    this.completedLoops = 0,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    this.retryQuestions = const [],
  });

  final String id;
  final String subjectId;
  final String topic;
  final String material;
  final DateTime examDate;
  final DateTime createdAt;
  final int completedLoops;
  final int correctAnswers;
  final int totalAnswers;
  final List<QuizQuestion> retryQuestions;

  double get accuracy => totalAnswers == 0 ? 0 : correctAnswers / totalAnswers;

  int get daysRemaining {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = DateTime(examDate.year, examDate.month, examDate.day);
    return end.difference(start).inDays.clamp(0, 3650);
  }

  LearningGoal copyWith({
    int? completedLoops,
    int? correctAnswers,
    int? totalAnswers,
    List<QuizQuestion>? retryQuestions,
  }) => LearningGoal(
    id: id,
    subjectId: subjectId,
    topic: topic,
    material: material,
    examDate: examDate,
    createdAt: createdAt,
    completedLoops: completedLoops ?? this.completedLoops,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    totalAnswers: totalAnswers ?? this.totalAnswers,
    retryQuestions: retryQuestions ?? this.retryQuestions,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectId': subjectId,
    'topic': topic,
    'material': material,
    'examDate': examDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'completedLoops': completedLoops,
    'correctAnswers': correctAnswers,
    'totalAnswers': totalAnswers,
    'retryQuestions': retryQuestions
        .map((question) => question.toJson())
        .toList(),
  };

  factory LearningGoal.fromJson(Map<String, dynamic> json) => LearningGoal(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    topic: json['topic'] as String,
    material: json['material'] as String? ?? '',
    examDate: DateTime.parse(json['examDate'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    completedLoops: json['completedLoops'] as int? ?? 0,
    correctAnswers: json['correctAnswers'] as int? ?? 0,
    totalAnswers: json['totalAnswers'] as int? ?? 0,
    retryQuestions: (json['retryQuestions'] as List? ?? const [])
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class SubjectProgress {
  const SubjectProgress({
    required this.id,
    required this.name,
    required this.emoji,
    required this.mastery,
    required this.attempts,
    required this.correct,
    required this.dueAt,
  });

  final String id;
  final String name;
  final String emoji;
  final double mastery;
  final int attempts;
  final int correct;
  final DateTime dueAt;

  double get accuracy => attempts == 0 ? 0 : correct / attempts;

  SubjectProgress copyWith({
    double? mastery,
    int? attempts,
    int? correct,
    DateTime? dueAt,
  }) => SubjectProgress(
    id: id,
    name: name,
    emoji: emoji,
    mastery: mastery ?? this.mastery,
    attempts: attempts ?? this.attempts,
    correct: correct ?? this.correct,
    dueAt: dueAt ?? this.dueAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'mastery': mastery,
    'attempts': attempts,
    'correct': correct,
    'dueAt': dueAt.toIso8601String(),
  };

  factory SubjectProgress.fromJson(Map<String, dynamic> json) =>
      SubjectProgress(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        mastery: (json['mastery'] as num).toDouble(),
        attempts: json['attempts'] as int,
        correct: json['correct'] as int,
        dueAt: DateTime.parse(json['dueAt'] as String),
      );
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.subjectId,
    required this.topic,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.source = 'curated',
  });

  final String id;
  final String subjectId;
  final String topic;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String source;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectId': subjectId,
    'topic': topic,
    'prompt': prompt,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
    'source': source,
  };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    topic: json['topic'] as String,
    prompt: json['prompt'] as String,
    options: (json['options'] as List).cast<String>(),
    correctIndex: json['correctIndex'] as int,
    explanation: json['explanation'] as String,
    source: json['source'] as String? ?? 'gpt-5.6-sol',
  );
}

class StudySession {
  const StudySession({
    required this.id,
    required this.subjectId,
    required this.minutes,
    required this.score,
    required this.completedAt,
  });

  final String id;
  final String subjectId;
  final int minutes;
  final double score;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectId': subjectId,
    'minutes': minutes,
    'score': score,
    'completedAt': completedAt.toIso8601String(),
  };

  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
    id: json['id'] as String,
    subjectId: json['subjectId'] as String,
    minutes: json['minutes'] as int,
    score: (json['score'] as num).toDouble(),
    completedAt: DateTime.parse(json['completedAt'] as String),
  );
}

class StudyPack {
  const StudyPack({
    required this.title,
    required this.microLesson,
    required this.whyItMatters,
    required this.questions,
    required this.aiGenerated,
  });

  final String title;
  final String microLesson;
  final String whyItMatters;
  final List<QuizQuestion> questions;
  final bool aiGenerated;

  Map<String, dynamic> toJson() => {
    'title': title,
    'microLesson': microLesson,
    'whyItMatters': whyItMatters,
    'questions': questions.map((question) => question.toJson()).toList(),
    'aiGenerated': aiGenerated,
  };

  factory StudyPack.fromJson(Map<String, dynamic> json) => StudyPack(
    title: json['title'] as String,
    microLesson: json['microLesson'] as String,
    whyItMatters: json['whyItMatters'] as String,
    questions: (json['questions'] as List)
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList(),
    aiGenerated: json['aiGenerated'] as bool? ?? true,
  );
}

Map<String, dynamic> decodeMap(String value) =>
    jsonDecode(value) as Map<String, dynamic>;
