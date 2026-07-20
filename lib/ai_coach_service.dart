import 'dart:convert';

import 'package:http/http.dart' as http;

import 'adaptive_engine.dart';
import 'models.dart';

class AiCoachService {
  AiCoachService({String? baseUrl})
    : baseUrl = normalizeUrl(
        baseUrl ?? const String.fromEnvironment('STUDYLOOP_API_URL'),
      );

  final String baseUrl;

  bool get isConfigured {
    final uri = Uri.tryParse(baseUrl);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static String normalizeUrl(String value) =>
      value.trim().replaceFirst(RegExp(r'/+$'), '');

  Future<BackendHealth> checkHealth() async {
    if (!isConfigured) {
      throw const FormatException('Enter a valid http:// or https:// address.');
    }
    final response = await http
        .get(Uri.parse('$baseUrl/health'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('The backend returned ${response.statusCode}.');
    }
    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return BackendHealth(
      configured: body['configured'] as bool? ?? false,
      model: body['model'] as String? ?? 'unknown',
    );
  }

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
      throw StateError('Backend unavailable (${response.statusCode})');
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
    if (normalized.contains('photosynthesis') ||
        normalized.contains('chlorophyll')) {
      return StudyPack(
        title: topic.isEmpty ? 'Photosynthesis' : topic,
        microLesson:
            'Photosynthesis happens in chloroplasts. Chlorophyll captures '
            'light energy, and the plant uses water and carbon dioxide to '
            'produce glucose. Oxygen is released as a product, while glucose '
            'stores chemical energy the plant can use.',
        whyItMatters:
            'This mission uses the concepts in your notes and turns them into '
            'active recall.',
        questions: const [
          QuizQuestion(
            id: 'goal-photo-1',
            subjectId: 'science',
            topic: 'Photosynthesis',
            prompt: 'In which organelle does photosynthesis mainly occur?',
            options: ['Nucleus', 'Chloroplast', 'Mitochondrion', 'Ribosome'],
            correctIndex: 1,
            explanation:
                'Photosynthesis occurs in chloroplasts, which contain chlorophyll.',
            source: 'offline-grounded-demo',
          ),
          QuizQuestion(
            id: 'goal-photo-2',
            subjectId: 'science',
            topic: 'Photosynthesis',
            prompt: 'Which substances does a plant use to produce glucose?',
            options: [
              'Water and carbon dioxide',
              'Oxygen and nitrogen',
              'Glucose and oxygen',
              'Minerals and proteins',
            ],
            correctIndex: 0,
            explanation:
                'With light energy, water and carbon dioxide are used to '
                'produce glucose.',
            source: 'offline-grounded-demo',
          ),
          QuizQuestion(
            id: 'goal-photo-3',
            subjectId: 'science',
            topic: 'Photosynthesis',
            prompt: 'Which gas is released during photosynthesis?',
            options: ['Nitrogen', 'Methane', 'Oxygen', 'Hydrogen'],
            correctIndex: 2,
            explanation: 'Oxygen is released during photosynthesis.',
            source: 'offline-grounded-demo',
          ),
        ],
        aiGenerated: false,
      );
    }
    final questions = AdaptiveEngine.questionsFor(subjectId);
    return StudyPack(
      title: topic.isEmpty ? 'Smart review' : topic,
      microLesson:
          'Focus on the central idea in “$topic”, recall it without looking, '
          'then check it with an example. Active recall builds a more stable '
          'memory than simply rereading.',
      whyItMatters:
          'The offline demo does not freely interpret your notes. It provides '
          'a subject recall without inventing information.',
      questions: questions,
      aiGenerated: false,
    );
  }
}

class BackendHealth {
  const BackendHealth({required this.configured, required this.model});

  final bool configured;
  final String model;
}
