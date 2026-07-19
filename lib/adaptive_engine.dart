import 'models.dart';

class AdaptiveEngine {
  static List<SubjectProgress> seedSubjects() {
    final now = DateTime.now();
    return [
      SubjectProgress(
        id: 'math',
        name: 'Matematica',
        emoji: '∑',
        mastery: .42,
        attempts: 4,
        correct: 2,
        dueAt: now.subtract(const Duration(hours: 4)),
      ),
      SubjectProgress(
        id: 'english',
        name: 'Inglese',
        emoji: 'A',
        mastery: .68,
        attempts: 5,
        correct: 4,
        dueAt: now.add(const Duration(hours: 3)),
      ),
      SubjectProgress(
        id: 'science',
        name: 'Scienze',
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
      return 'È in scadenza e la padronanza è ancora fragile.';
    }
    if (subject.accuracy < .65) {
      return 'Gli ultimi tentativi mostrano risposte ancora poco stabili.';
    }
    return 'Un richiamo breve ora consolida il ricordo prima che svanisca.';
  }

  static List<QuizQuestion> questionsFor(String subjectId) {
    final all = <QuizQuestion>[
      const QuizQuestion(
        id: 'math-1',
        subjectId: 'math',
        topic: 'Frazioni equivalenti',
        prompt: 'Quale frazione è equivalente a 2/3?',
        options: ['2/6', '3/8', '4/6', '5/12'],
        correctIndex: 2,
        explanation:
            '4/6 si semplifica dividendo numeratore e denominatore per 2.',
      ),
      const QuizQuestion(
        id: 'math-2',
        subjectId: 'math',
        topic: 'Percentuali',
        prompt: 'Quanto vale il 25% di 80?',
        options: ['15', '20', '25', '30'],
        correctIndex: 1,
        explanation: 'Il 25% è un quarto: 80 ÷ 4 = 20.',
      ),
      const QuizQuestion(
        id: 'math-3',
        subjectId: 'math',
        topic: 'Proporzioni',
        prompt: 'Se 3 quaderni costano 6 €, quanto costano 5 quaderni?',
        options: ['8 €', '9 €', '10 €', '12 €'],
        correctIndex: 2,
        explanation: 'Ogni quaderno costa 2 €, quindi 5 × 2 € = 10 €.',
      ),
      const QuizQuestion(
        id: 'english-1',
        subjectId: 'english',
        topic: 'Irregular verbs',
        prompt: 'Qual è il past simple di “go”?',
        options: ['goed', 'gone', 'went', 'goes'],
        correctIndex: 2,
        explanation: '“Went” è il past simple; “gone” è il participio passato.',
      ),
      const QuizQuestion(
        id: 'english-2',
        subjectId: 'english',
        topic: 'Present perfect',
        prompt: 'Completa: “I ___ never seen this film.”',
        options: ['have', 'has', 'am', 'did'],
        correctIndex: 0,
        explanation: 'Con “I” il present perfect usa “have” + participio.',
      ),
      const QuizQuestion(
        id: 'english-3',
        subjectId: 'english',
        topic: 'Vocabulary',
        prompt: 'Quale parola significa “affidabile”?',
        options: ['reliable', 'available', 'comfortable', 'valuable'],
        correctIndex: 0,
        explanation: '“Reliable” significa affidabile o degno di fiducia.',
      ),
      const QuizQuestion(
        id: 'science-1',
        subjectId: 'science',
        topic: 'Ciclo dell’acqua',
        prompt: 'Come si chiama il passaggio da liquido a vapore?',
        options: [
          'Condensazione',
          'Evaporazione',
          'Fusione',
          'Solidificazione',
        ],
        correctIndex: 1,
        explanation: 'L’evaporazione trasforma l’acqua liquida in vapore.',
      ),
      const QuizQuestion(
        id: 'science-2',
        subjectId: 'science',
        topic: 'Cellula',
        prompt: 'Quale struttura contiene il materiale genetico?',
        options: ['Membrana', 'Citoplasma', 'Nucleo', 'Vacuolo'],
        correctIndex: 2,
        explanation:
            'Nelle cellule eucariotiche il DNA è contenuto nel nucleo.',
      ),
      const QuizQuestion(
        id: 'science-3',
        subjectId: 'science',
        topic: 'Energia',
        prompt: 'Quale fonte è rinnovabile?',
        options: ['Carbone', 'Petrolio', 'Gas naturale', 'Sole'],
        correctIndex: 3,
        explanation: 'L’energia solare si rinnova naturalmente.',
      ),
    ];
    return all.where((question) => question.subjectId == subjectId).toList();
  }
}
