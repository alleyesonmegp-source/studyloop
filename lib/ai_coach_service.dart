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
      return offlinePack(topic: topic, subjectId: subjectId);
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

  StudyPack offlinePack({required String topic, required String subjectId}) {
    final questions = AdaptiveEngine.questionsFor(subjectId);
    return StudyPack(
      title: topic.isEmpty ? 'Ripasso intelligente' : topic,
      microLesson:
          'Concentrati sull’idea centrale, richiamala senza guardare e poi '
          'controlla con un esempio. Il recupero attivo rende il ricordo più '
          'stabile della semplice rilettura.',
      whyItMatters:
          'StudyLoop ha scelto questo argomento perché combina priorità, '
          'padronanza e tempo trascorso dall’ultimo ripasso.',
      questions: questions,
      aiGenerated: false,
    );
  }
}
