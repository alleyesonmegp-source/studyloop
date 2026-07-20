import 'dart:convert';

import 'package:http/http.dart' as http;

import 'adaptive_engine.dart';
import 'models.dart';

class AiCoachService {
  static const baseUrl = String.fromEnvironment('STUDYLOOP_API_URL');

  bool get isConfigured => baseUrl.trim().isNotEmpty;

  Future<StudyPack> createPack({
    required String topic,
    required String notes,
    required String grade,
    required String subjectId,
  }) async {
    if (!isConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      return offlinePack(topic: topic, notes: notes, subjectId: subjectId);
    }
    final response = await http
        .post(
          Uri.parse('$baseUrl/v1/study-pack'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'topic': topic,
            'notes': notes,
            'grade': grade,
            'subjectId': subjectId,
          }),
        )
        .timeout(const Duration(seconds: 35));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Backend non disponibile (${response.statusCode})');
    }
    return StudyPack.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  StudyPack offlinePack({
    required String topic,
    String notes = '',
    required String subjectId,
  }) {
    final normalized = '$topic $notes'.toLowerCase();
    if (normalized.contains('fotosintesi') ||
        normalized.contains('clorofilla')) {
      return StudyPack(
        title: topic.isEmpty ? 'Fotosintesi clorofilliana' : topic,
        microLesson:
            'La fotosintesi avviene nei cloroplasti: la clorofilla cattura '
            'l’energia della luce e la pianta usa acqua e anidride carbonica '
            'per produrre glucosio. L’ossigeno viene liberato come prodotto. '
            'Il glucosio conserva energia chimica utile alla pianta.',
        whyItMatters:
            'Questa missione usa esattamente i concetti presenti nei tuoi '
            'appunti e li trasforma in recupero attivo.',
        questions: const [
          QuizQuestion(
            id: 'goal-photo-1',
            subjectId: 'science',
            topic: 'Fotosintesi',
            prompt: 'In quale organulo avviene principalmente la fotosintesi?',
            options: ['Nucleo', 'Cloroplasto', 'Mitocondrio', 'Ribosoma'],
            correctIndex: 1,
            explanation:
                'La fotosintesi avviene nei cloroplasti, che contengono clorofilla.',
            source: 'offline-grounded-demo',
          ),
          QuizQuestion(
            id: 'goal-photo-2',
            subjectId: 'science',
            topic: 'Fotosintesi',
            prompt: 'Quali sostanze usa la pianta per produrre glucosio?',
            options: [
              'Acqua e anidride carbonica',
              'Ossigeno e azoto',
              'Glucosio e ossigeno',
              'Sali e proteine',
            ],
            correctIndex: 0,
            explanation:
                'Acqua e anidride carbonica, grazie all’energia luminosa, '
                'sono utilizzate per produrre glucosio.',
            source: 'offline-grounded-demo',
          ),
          QuizQuestion(
            id: 'goal-photo-3',
            subjectId: 'science',
            topic: 'Fotosintesi',
            prompt: 'Quale gas viene liberato durante la fotosintesi?',
            options: ['Azoto', 'Metano', 'Ossigeno', 'Idrogeno'],
            correctIndex: 2,
            explanation: 'Durante la fotosintesi viene liberato ossigeno.',
            source: 'offline-grounded-demo',
          ),
        ],
        aiGenerated: false,
      );
    }
    final questions = AdaptiveEngine.questionsFor(subjectId);
    return StudyPack(
      title: topic.isEmpty ? 'Ripasso intelligente' : topic,
      microLesson:
          'Concentrati sull’idea centrale di “$topic”, richiamala senza '
          'guardare e poi '
          'controlla con un esempio. Il recupero attivo rende il ricordo più '
          'stabile della semplice rilettura.',
      whyItMatters:
          'La demo offline non interpreta liberamente gli appunti: propone '
          'un richiamo della materia senza inventare informazioni.',
      questions: questions,
      aiGenerated: false,
    );
  }
}
