import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyloop_mobile/ai_coach_service.dart';
import 'package:studyloop_mobile/app_state.dart';
import 'package:studyloop_mobile/models.dart';

void main() {
  test('backend address is normalized and persisted locally', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load();

    await state.setBackendUrl(' http://192.168.1.20:8000/// ');

    expect(state.backendUrl, 'http://192.168.1.20:8000');
    final restored = AppState();
    await restored.load();
    expect(restored.backendUrl, state.backendUrl);
    expect(AiCoachService(baseUrl: restored.backendUrl).isConfigured, isTrue);
  });

  test('offline demo grounds the mission in the supplied material', () {
    final pack = AiCoachService().offlinePack(
      topic: 'Photosynthesis',
      notes: 'Photosynthesis happens in chloroplasts.',
      subjectId: 'science',
    );

    expect(pack.questions, hasLength(3));
    expect(pack.questions.first.prompt, contains('organelle'));
    expect(pack.questions.first.source, 'offline-grounded-demo');
  });

  test('a completed goal mission updates evidence and readiness', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load();
    final goal = LearningGoal(
      id: 'goal-1',
      subjectId: 'science',
      topic: 'Photosynthesis',
      material: 'Photosynthesis happens in chloroplasts and releases oxygen.',
      examDate: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now(),
    );
    await state.saveGoal(goal);
    final before = state.goalReadiness(goal);

    final questions = AiCoachService()
        .offlinePack(
          topic: 'Photosynthesis',
          notes: goal.material,
          subjectId: 'science',
        )
        .questions;
    await state.recordGoalSession(
      answers: [true, true, false],
      questions: questions,
    );

    expect(state.activeGoal!.completedLoops, 1);
    expect(state.activeGoal!.totalAnswers, 3);
    expect(state.activeGoal!.correctAnswers, 2);
    expect(state.activeGoal!.retryQuestions, hasLength(1));
    expect(state.goalReadiness(state.activeGoal!), greaterThan(before));
    expect(state.sessions, hasLength(1));
  });
}
