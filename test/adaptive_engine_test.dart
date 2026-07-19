import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop_mobile/adaptive_engine.dart';

void main() {
  test('fragile and overdue subjects are prioritized', () {
    final plan = AdaptiveEngine.prioritize(AdaptiveEngine.seedSubjects());
    expect(plan.first.id, 'math');
  });

  test('a correct answer raises mastery and schedules a later review', () {
    final subject = AdaptiveEngine.seedSubjects().first;
    final updated = AdaptiveEngine.updateProgress(subject, correct: true);

    expect(updated.mastery, greaterThan(subject.mastery));
    expect(updated.attempts, subject.attempts + 1);
    expect(updated.correct, subject.correct + 1);
    expect(updated.dueAt.isAfter(DateTime.now()), isTrue);
  });

  test('an incorrect answer schedules a near-term retry', () {
    final subject = AdaptiveEngine.seedSubjects().first;
    final updated = AdaptiveEngine.updateProgress(subject, correct: false);

    expect(updated.mastery, lessThan(subject.mastery));
    expect(updated.correct, subject.correct);
    expect(
      updated.dueAt.isBefore(DateTime.now().add(const Duration(hours: 12))),
      isTrue,
    );
  });
}
