import 'models.dart';

class AdaptiveEngine {
  static List<SubjectProgress> seedSubjects() {
    final now = DateTime.now();
    return [
      SubjectProgress(
        id: 'math',
        name: 'Mathematics',
        emoji: '∑',
        mastery: .42,
        attempts: 4,
        correct: 2,
        dueAt: now.subtract(const Duration(hours: 4)),
      ),
      SubjectProgress(
        id: 'english',
        name: 'English',
        emoji: 'A',
        mastery: .68,
        attempts: 5,
        correct: 4,
        dueAt: now.add(const Duration(hours: 3)),
      ),
      SubjectProgress(
        id: 'science',
        name: 'Science',
        emoji: '⚗',
        mastery: .81,
        attempts: 4,
        correct: 4,
        dueAt: now.add(const Duration(days: 2)),
      ),
    ];
  }

  static List<SubjectProgress> prioritize(Iterable<SubjectProgress> subjects) {
    final now = DateTime.now();
    final sorted = subjects.toList();
    sorted.sort((a, b) {
      double score(SubjectProgress item) {
        final overdueHours = now.difference(item.dueAt).inHours.clamp(0, 72);
        return (1 - item.mastery) * 60 +
            (1 - item.accuracy) * 25 +
            overdueHours * .8;
      }

      return score(b).compareTo(score(a));
    });
    return sorted;
  }

  static SubjectProgress updateProgress(
    SubjectProgress current, {
    required bool correct,
  }) {
    final attempts = current.attempts + 1;
    final correctCount = current.correct + (correct ? 1 : 0);
    final delta = correct ? .09 : -.035;
    final mastery = (current.mastery + delta).clamp(.05, .98);
    final intervalHours = correct
        ? (12 + mastery * 84).round()
        : (2 + mastery * 8).round();
    return current.copyWith(
      mastery: mastery,
      attempts: attempts,
      correct: correctCount,
      dueAt: DateTime.now().add(Duration(hours: intervalHours)),
    );
  }

  static String reasonFor(SubjectProgress subject) {
    final overdue = subject.dueAt.isBefore(DateTime.now());
    if (overdue && subject.mastery < .55) {
      return 'This review is due and mastery is still fragile.';
    }
    if (subject.accuracy < .65) {
      return 'Recent attempts show that recall is not stable yet.';
    }
    return 'A short recall now will strengthen memory before it fades.';
  }

  static List<QuizQuestion> questionsFor(String subjectId) {
    final all = <QuizQuestion>[
      const QuizQuestion(
        id: 'math-1',
        subjectId: 'math',
        topic: 'Equivalent fractions',
        prompt: 'Which fraction is equivalent to 2/3?',
        options: ['2/6', '3/8', '4/6', '5/12'],
        correctIndex: 2,
        explanation: '4/6 simplifies to 2/3 by dividing both terms by 2.',
      ),
      const QuizQuestion(
        id: 'math-2',
        subjectId: 'math',
        topic: 'Percentages',
        prompt: 'What is 25% of 80?',
        options: ['15', '20', '25', '30'],
        correctIndex: 1,
        explanation: '25% is one quarter, so 80 ÷ 4 = 20.',
      ),
      const QuizQuestion(
        id: 'math-3',
        subjectId: 'math',
        topic: 'Ratios',
        prompt: 'If 3 notebooks cost \$6, how much do 5 notebooks cost?',
        options: ['\$8', '\$9', '\$10', '\$12'],
        correctIndex: 2,
        explanation: 'Each notebook costs \$2, so 5 × \$2 = \$10.',
      ),
      const QuizQuestion(
        id: 'english-1',
        subjectId: 'english',
        topic: 'Irregular verbs',
        prompt: 'What is the past simple form of “go”?',
        options: ['goed', 'gone', 'went', 'goes'],
        correctIndex: 2,
        explanation: '“Went” is past simple; “gone” is the past participle.',
      ),
      const QuizQuestion(
        id: 'english-2',
        subjectId: 'english',
        topic: 'Present perfect',
        prompt: 'Complete: “I ___ never seen this film.”',
        options: ['have', 'has', 'am', 'did'],
        correctIndex: 0,
        explanation: 'With “I”, present perfect uses “have” + past participle.',
      ),
      const QuizQuestion(
        id: 'english-3',
        subjectId: 'english',
        topic: 'Vocabulary',
        prompt: 'Which word means “dependable”?',
        options: ['reliable', 'available', 'comfortable', 'valuable'],
        correctIndex: 0,
        explanation: '“Reliable” means dependable or trustworthy.',
      ),
      const QuizQuestion(
        id: 'science-1',
        subjectId: 'science',
        topic: 'Water cycle',
        prompt: 'What is the change from liquid water to vapor called?',
        options: ['Condensation', 'Evaporation', 'Melting', 'Freezing'],
        correctIndex: 1,
        explanation: 'Evaporation turns liquid water into water vapor.',
      ),
      const QuizQuestion(
        id: 'science-2',
        subjectId: 'science',
        topic: 'The cell',
        prompt: 'Which structure contains the genetic material?',
        options: ['Membrane', 'Cytoplasm', 'Nucleus', 'Vacuole'],
        correctIndex: 2,
        explanation: 'In eukaryotic cells, DNA is contained in the nucleus.',
      ),
      const QuizQuestion(
        id: 'science-3',
        subjectId: 'science',
        topic: 'Energy',
        prompt: 'Which energy source is renewable?',
        options: ['Coal', 'Oil', 'Natural gas', 'Sunlight'],
        correctIndex: 3,
        explanation: 'Solar energy is naturally renewable.',
      ),
    ];
    return all.where((question) => question.subjectId == subjectId).toList();
  }
}
