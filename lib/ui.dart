import 'dart:async';

import 'package:flutter/material.dart';

import 'adaptive_engine.dart';
import 'ai_coach_service.dart';
import 'app_state.dart';
import 'models.dart';

const _ink = Color(0xFF172033);
const _muted = Color(0xFF667085);
const _indigo = Color(0xFF4F46E5);
const _mint = Color(0xFF0F9D78);
const _orange = Color(0xFFEA7A21);

class StudyLoopSplash extends StatelessWidget {
  const StudyLoopSplash({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BrandMark(size: 72),
          SizedBox(height: 18),
          Text(
            'StudyLoop',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 18),
          CircularProgressIndicator(),
        ],
      ),
    ),
  );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.state});
  final AppState state;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();
  String _grade = 'Scuola media';
  int _focusMinutes = 20;
  bool _ageConfirmed = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
        children: [
          const Align(alignment: Alignment.centerLeft, child: _BrandMark()),
          const SizedBox(height: 28),
          const Text(
            'Impara nel momento giusto.',
            style: TextStyle(
              color: _ink,
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'StudyLoop trasforma ogni sessione in un ciclo: focus, verifica, '
            'adattamento e richiamo prima che il ricordo svanisca.',
            style: TextStyle(color: _muted, fontSize: 16, height: 1.45),
          ),
          const SizedBox(height: 30),
          const _FieldLabel('Come vuoi essere chiamato?'),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Il tuo nome',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 22),
          const _FieldLabel('Percorso'),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Scuola media', 'Scuola superiore', 'Università']
                .map(
                  (grade) => ChoiceChip(
                    label: Text(grade),
                    selected: _grade == grade,
                    onSelected: (_) => setState(() => _grade = grade),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(child: _FieldLabel('Durata focus')),
              Text(
                '$_focusMinutes minuti',
                style: const TextStyle(
                  color: _indigo,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: _focusMinutes.toDouble(),
            min: 10,
            max: 40,
            divisions: 6,
            label: '$_focusMinutes min',
            onChanged: (value) => setState(() => _focusMinutes = value.round()),
          ),
          CheckboxListTile(
            value: _ageConfirmed,
            onChanged: (value) =>
                setState(() => _ageConfirmed = value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Ho almeno 14 anni oppure uso StudyLoop con un genitore/tutore.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Il Coach AI genera materiale didattico e può commettere errori: '
              'verifica sempre le informazioni importanti.',
              style: TextStyle(fontSize: 11),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: !_ageConfirmed
                ? null
                : () {
                    final name = _name.text.trim();
                    widget.state.finishOnboarding(
                      LearnerProfile(
                        name: name.isEmpty ? 'Alex' : name,
                        grade: _grade,
                        focusMinutes: _focusMinutes,
                      ),
                    );
                  },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Crea il mio primo loop'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Privacy-first: i progressi restano sul dispositivo. Le richieste '
            'al Coach AI passano da un backend sicuro, mai da una chiave nell’app.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class StudyLoopShell extends StatefulWidget {
  const StudyLoopShell({super.key, required this.state});
  final AppState state;

  @override
  State<StudyLoopShell> createState() => _StudyLoopShellState();
}

class _StudyLoopShellState extends State<StudyLoopShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayScreen(state: widget.state),
      LoopScreen(state: widget.state),
      AiCoachScreen(state: widget.state),
      ProgressScreen(state: widget.state),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Oggi',
          ),
          NavigationDestination(
            icon: Icon(Icons.loop_outlined),
            selectedIcon: Icon(Icons.loop),
            label: 'Loop',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Coach AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progressi',
          ),
        ],
      ),
    );
  }
}

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.state});
  final AppState state;

  Future<void> _editGoal(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => GoalSetupScreen(state: state)),
    );
  }

  Future<void> _startGoal(BuildContext context, LearningGoal goal) async {
    final service = AiCoachService(baseUrl: state.backendUrl);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _PreparingMissionDialog(),
      ),
    );
    StudyPack pack;
    try {
      pack = await service.createPack(
        topic: goal.topic,
        notes: goal.material,
        grade: state.profile!.grade,
        subjectId: goal.subjectId,
      );
    } catch (_) {
      pack = service.offlinePack(
        topic: goal.topic,
        notes: goal.material,
        subjectId: goal.subjectId,
      );
    }
    if (goal.retryQuestions.isNotEmpty) {
      final merged = <QuizQuestion>[
        ...goal.retryQuestions,
        ...pack.questions.where(
          (question) =>
              !goal.retryQuestions.any((retry) => retry.id == question.id),
        ),
      ].take(3).toList();
      pack = StudyPack(
        title: pack.title,
        microLesson: pack.microLesson,
        whyItMatters:
            'Prima recuperiamo gli errori precedenti, poi aggiungiamo un '
            'nuovo richiamo dai tuoi appunti.',
        questions: merged,
        aiGenerated: pack.aiGenerated,
      );
    }
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    final subject = state.subjects[goal.subjectId]!;
    final answers = await Navigator.of(context).push<List<bool>>(
      MaterialPageRoute(
        builder: (_) => FocusScreen(
          subject: subject,
          minutes: state.profile!.focusMinutes,
          questions: pack.questions,
          missionTitle: goal.topic,
          microLesson: pack.microLesson,
          grounded: goal.material.trim().isNotEmpty,
        ),
      ),
    );
    if (answers == null || answers.isEmpty) return;
    await state.recordGoalSession(answers: answers, questions: pack.questions);
    if (!context.mounted) return;
    final score = answers.where((answer) => answer).length;
    await showDialog<void>(
      context: context,
      builder: (_) => _MissionResultDialog(
        score: score,
        total: answers.length,
        readiness: state.goalReadiness(state.activeGoal!),
      ),
    );
  }

  Future<void> _startFocus(
    BuildContext context,
    SubjectProgress subject,
  ) async {
    final answers = await Navigator.of(context).push<List<bool>>(
      MaterialPageRoute(
        builder: (_) =>
            FocusScreen(subject: subject, minutes: state.profile!.focusMinutes),
      ),
    );
    if (answers == null || answers.isEmpty) return;
    await state.recordSession(
      subjectId: subject.id,
      minutes: state.profile!.focusMinutes,
      answers: answers,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loop completato e piano aggiornato.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = state.plan;
    final primary = plan.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        Row(
          children: [
            const _BrandMark(size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ciao, ${state.profile!.name}',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Il piano si è adattato ai tuoi progressi.',
                    style: TextStyle(color: _muted),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              onSelected: (value) {
                if (value == 'reset') state.reset();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'reset',
                  child: Text('Azzera dati e onboarding'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        if (state.activeGoal == null)
          _EmptyGoalCard(onCreate: () => _editGoal(context))
        else
          _GoalMissionCard(
            goal: state.activeGoal!,
            subject: state.subjects[state.activeGoal!.subjectId]!,
            readiness: state.goalReadiness(state.activeGoal!),
            onStart: () => _startGoal(context, state.activeGoal!),
            onEdit: () => _editGoal(context),
          ),
        if (state.activeGoal == null) ...[
          const SizedBox(height: 22),
          _HeroFocusCard(
            subject: primary,
            minutes: state.profile!.focusMinutes,
            reason: AdaptiveEngine.reasonFor(primary),
            onStart: () => _startFocus(context, primary),
          ),
        ],
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _MetricPill(
                icon: Icons.local_fire_department_outlined,
                value: '${state.streak}',
                label: 'giorni',
                color: _orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricPill(
                icon: Icons.check_circle_outline,
                value: '${state.todaySessions}',
                label: 'loop oggi',
                color: _mint,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricPill(
                icon: Icons.schedule,
                value: '${state.totalMinutes}',
                label: 'min totali',
                color: _indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          title: 'Coda intelligente',
          subtitle: 'Ordinata per urgenza, fragilità e decadimento.',
        ),
        const SizedBox(height: 12),
        ...plan.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SubjectTile(
              subject: entry.value,
              rank: entry.key + 1,
              onTap: () => _startFocus(context, entry.value),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyGoalCard extends StatelessWidget {
  const _EmptyGoalCard({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF17153B),
      borderRadius: BorderRadius.circular(26),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.flag_outlined, color: Color(0xFFFFD56A)),
            SizedBox(width: 8),
            Text(
              'NUOVO • MISSIONE VERIFICA',
              style: TextStyle(
                color: Color(0xFFFFD56A),
                fontSize: 11,
                letterSpacing: .8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Dai tuoi appunti a un piano che si adatta.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            height: 1.12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Incolla il materiale, scegli la data e affronta una breve missione '
          'ogni giorno. Gli errori decidono cosa ritorna.',
          style: TextStyle(color: Color(0xFFC7C6DE), height: 1.4),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: const Text('Crea obiettivo verifica'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF7C7DF4),
            minimumSize: const Size.fromHeight(50),
          ),
        ),
      ],
    ),
  );
}

class _GoalMissionCard extends StatelessWidget {
  const _GoalMissionCard({
    required this.goal,
    required this.subject,
    required this.readiness,
    required this.onStart,
    required this.onEdit,
  });

  final LearningGoal goal;
  final SubjectProgress subject;
  final double readiness;
  final VoidCallback onStart;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final percent = (readiness * 100).round();
    final urgency = goal.daysRemaining == 0
        ? 'Verifica oggi'
        : '${goal.daysRemaining} giorni alla verifica';
    final message = goal.completedLoops == 0
        ? 'Prima missione: costruiamo la base.'
        : goal.accuracy < .67
        ? 'Gli errori di ieri diventano il richiamo di oggi.'
        : 'Sei in crescita: consolida prima che il ricordo cali.';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF17153B), Color(0xFF3730A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3317153B),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  urgency.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFFD56A),
                    fontSize: 11,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Modifica obiettivo',
                visualDensity: VisualDensity.compact,
                color: const Color(0xFFC7D2FE),
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),
          Text(
            goal.topic,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${subject.name} • $message',
            style: const TextStyle(color: Color(0xFFD7D8F7), height: 1.35),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox.square(
                dimension: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: readiness,
                      strokeWidth: 7,
                      backgroundColor: Colors.white12,
                      color: const Color(0xFF66E2BA),
                    ),
                    Center(
                      child: Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRONTEZZA STIMATA',
                      style: TextStyle(
                        color: Color(0xFFA5B4FC),
                        fontSize: 10,
                        letterSpacing: .7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${goal.completedLoops} missioni • '
                      '${goal.totalAnswers} richiami',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.bolt),
            label: Text(
              goal.completedLoops == 0
                  ? 'Avvia la prima missione'
                  : 'Continua il piano di oggi',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3730A3),
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreparingMissionDialog extends StatelessWidget {
  const _PreparingMissionDialog();

  @override
  Widget build(BuildContext context) => const AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 18),
        Expanded(
          child: Text(
            'Preparo una missione basata sui tuoi appunti...',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _MissionResultDialog extends StatelessWidget {
  const _MissionResultDialog({
    required this.score,
    required this.total,
    required this.readiness,
  });
  final int score;
  final int total;
  final double readiness;

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: Icon(
      score / total >= .67 ? Icons.verified_outlined : Icons.replay_outlined,
      color: score / total >= .67 ? _mint : _orange,
      size: 42,
    ),
    title: Text(
      score / total >= .67 ? 'Missione completata' : 'Errori salvati',
    ),
    content: Text(
      'Hai richiamato $score concetti su $total.\n\n'
      'Prontezza stimata: ${(readiness * 100).round()}%.\n'
      'StudyLoop userà questo risultato per decidere il prossimo richiamo.',
      textAlign: TextAlign.center,
    ),
    actions: [
      FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Torna al piano'),
      ),
    ],
  );
}

class _GoalEvidenceCard extends StatelessWidget {
  const _GoalEvidenceCard({required this.goal, required this.readiness});
  final LearningGoal goal;
  final double readiness;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, color: _indigo),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  goal.topic,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${(readiness * 100).round()}%',
                style: const TextStyle(
                  color: _indigo,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _EvidenceChip(
                icon: Icons.bolt,
                text: '${goal.completedLoops} missioni',
              ),
              _EvidenceChip(
                icon: Icons.task_alt,
                text: '${(goal.accuracy * 100).round()}% accuratezza',
              ),
              _EvidenceChip(
                icon: Icons.replay,
                text: '${goal.retryQuestions.length} da recuperare',
              ),
            ],
          ),
          if (goal.retryQuestions.isNotEmpty) ...[
            const SizedBox(height: 11),
            const Text(
              'La prossima missione inizierà dagli errori ancora aperti.',
              style: TextStyle(color: _orange, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    ),
  );
}

class _EvidenceChip extends StatelessWidget {
  const _EvidenceChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F4F7),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: _muted),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _HeroFocusCard extends StatelessWidget {
  const _HeroFocusCard({
    required this.subject,
    required this.minutes,
    required this.reason,
    required this.onStart,
  });

  final SubjectProgress subject;
  final int minutes;
  final String reason;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        colors: [Color(0xFF3730A3), Color(0xFF6366F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x334F46E5),
          blurRadius: 24,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFFFD56A), size: 19),
            SizedBox(width: 7),
            Text(
              'PROSSIMA MOSSA',
              style: TextStyle(
                color: Color(0xFFE0E7FF),
                fontSize: 12,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          subject.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 29,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          reason,
          style: const TextStyle(color: Color(0xFFE0E7FF), height: 1.35),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _WhiteTag(icon: Icons.timer_outlined, text: '$minutes min'),
            const SizedBox(width: 8),
            _WhiteTag(
              icon: Icons.battery_charging_full,
              text: '${(subject.mastery * 100).round()}%',
            ),
          ],
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Avvia il loop'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF3730A3),
            minimumSize: const Size.fromHeight(52),
          ),
        ),
      ],
    ),
  );
}

class LoopScreen extends StatelessWidget {
  const LoopScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
    children: [
      const Text(
        'Il tuo Learning Loop',
        style: TextStyle(
          color: _ink,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Niente scatole nere: ogni priorità ha una ragione.',
        style: TextStyle(color: _muted),
      ),
      const SizedBox(height: 22),
      const _LoopDiagram(),
      const SizedBox(height: 24),
      const _SectionTitle(
        title: 'Perché questo ordine?',
        subtitle: 'Il motore combina memoria, accuratezza e scadenza.',
      ),
      const SizedBox(height: 12),
      ...state.plan.map(
        (subject) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ExplainCard(subject: subject),
        ),
      ),
    ],
  );
}

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key, required this.state});
  final AppState state;

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _topic = TextEditingController(text: 'Frazioni equivalenti');
  final _notes = TextEditingController();
  late final TextEditingController _backendUrl;
  String _subjectId = 'math';
  StudyPack? _pack;
  bool _loading = false;
  bool _testingBackend = false;
  BackendHealth? _backendHealth;
  String? _backendMessage;
  String? _error;

  AiCoachService get _service =>
      AiCoachService(baseUrl: widget.state.backendUrl);

  @override
  void initState() {
    super.initState();
    _backendUrl = TextEditingController(text: widget.state.backendUrl);
  }

  @override
  void dispose() {
    _topic.dispose();
    _notes.dispose();
    _backendUrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndTestBackend() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final normalized = AiCoachService.normalizeUrl(_backendUrl.text);
    await widget.state.setBackendUrl(normalized);
    if (!mounted) return;
    setState(() {
      _testingBackend = true;
      _backendHealth = null;
      _backendMessage = null;
    });
    try {
      final health = await _service.checkHealth();
      if (!mounted) return;
      setState(() {
        _backendHealth = health;
        _backendMessage = health.configured
            ? 'Connesso a ${health.model}: API key disponibile sul backend.'
            : 'Backend raggiungibile, ma OPENAI_API_KEY non è configurata.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _backendMessage = 'Connessione non riuscita: $error');
    } finally {
      if (mounted) setState(() => _testingBackend = false);
    }
  }

  Future<void> _useOfflineMode() async {
    _backendUrl.clear();
    await widget.state.setBackendUrl('');
    if (!mounted) return;
    setState(() {
      _backendHealth = null;
      _backendMessage = 'Modalità demo offline attiva.';
    });
  }

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pack = await _service.createPack(
        topic: _topic.text.trim(),
        notes: _notes.text.trim(),
        grade: widget.state.profile!.grade,
        subjectId: _subjectId,
      );
      if (mounted) setState(() => _pack = pack);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = '$error';
          _pack = _service.offlinePack(
            topic: _topic.text.trim(),
            subjectId: _subjectId,
          );
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startPack() async {
    final pack = _pack;
    if (pack == null) return;
    final answers = await Navigator.of(context).push<List<bool>>(
      MaterialPageRoute(
        builder: (_) =>
            QuizScreen(questions: pack.questions, title: pack.title),
      ),
    );
    if (answers == null || answers.isEmpty) return;
    await widget.state.recordAiQuiz(
      answers: answers,
      questions: pack.questions,
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
    children: [
      Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coach AI',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Trasforma un argomento in recupero attivo.',
                  style: TextStyle(color: _muted),
                ),
              ],
            ),
          ),
          _AiStatusChip(
            live: _backendHealth?.configured == true,
            configured: _service.isConfigured,
          ),
        ],
      ),
      const SizedBox(height: 14),
      Card(
        child: ExpansionTile(
          leading: const Icon(Icons.dns_outlined, color: _indigo),
          title: const Text(
            'Connessione GPT-5.6',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(
            _service.isConfigured
                ? _service.baseUrl
                : 'Demo offline • nessuna API key nell’app',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
          children: [
            const Text(
              'Inserisci l’indirizzo del backend StudyLoop. La API key resta '
              'nel file .env del server e non viene mai salvata nell’APK.',
              style: TextStyle(color: _muted, height: 1.35),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _backendUrl,
              keyboardType: TextInputType.url,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Indirizzo backend',
                hintText: 'http://192.168.1.20:8000',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _testingBackend ? null : _saveAndTestBackend,
                    icon: _testingBackend
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_tethering),
                    label: Text(
                      _testingBackend ? 'Verifico...' : 'Salva e verifica',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: _testingBackend ? null : _useOfflineMode,
                  tooltip: 'Usa modalità offline',
                  icon: const Icon(Icons.offline_bolt_outlined),
                ),
              ],
            ),
            if (_backendMessage != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _backendMessage!,
                  style: TextStyle(
                    color: _backendHealth?.configured == true ? _mint : _orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 22),
      DropdownButtonFormField<String>(
        initialValue: _subjectId,
        decoration: const InputDecoration(
          labelText: 'Materia',
          prefixIcon: Icon(Icons.school_outlined),
        ),
        items: widget.state.subjects.values
            .map(
              (subject) => DropdownMenuItem(
                value: subject.id,
                child: Text(subject.name),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _subjectId = value ?? 'math'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _topic,
        decoration: const InputDecoration(
          labelText: 'Argomento',
          prefixIcon: Icon(Icons.lightbulb_outline),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _notes,
        minLines: 3,
        maxLines: 5,
        decoration: const InputDecoration(
          labelText: 'Appunti o difficoltà (facoltativo)',
          alignLabelWithHint: true,
          hintText: 'Es. confondo semplificazione e confronto...',
        ),
      ),
      const SizedBox(height: 14),
      FilledButton.icon(
        onPressed: _loading ? null : _generate,
        icon: _loading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_loading ? 'Creo il pacchetto...' : 'Genera micro-lezione'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
      ),
      if (_error != null) ...[
        const SizedBox(height: 10),
        const Text(
          'Backend AI non raggiungibile: è stato usato il fallback offline.',
          style: TextStyle(color: _orange, fontWeight: FontWeight.w700),
        ),
      ],
      if (_pack != null) ...[
        const SizedBox(height: 22),
        _StudyPackCard(pack: _pack!, onStart: _startPack),
      ],
      const SizedBox(height: 18),
      const _PrivacyCard(),
    ],
  );
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
    children: [
      const Text(
        'Progressi che spiegano',
        style: TextStyle(
          color: _ink,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Non solo tempo: qui vedi cosa sta diventando più stabile.',
        style: TextStyle(color: _muted),
      ),
      const SizedBox(height: 22),
      Row(
        children: [
          Expanded(
            child: _BigMetric(
              value: '${state.totalMinutes}',
              label: 'minuti di focus',
              icon: Icons.timer_outlined,
              color: _indigo,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _BigMetric(
              value: '${state.streak}',
              label: 'giorni di serie',
              icon: Icons.local_fire_department_outlined,
              color: _orange,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Text(
                  '${state.level}',
                  style: const TextStyle(
                    color: _orange,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Livello ${state.level} • ${state.xp} XP',
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    LinearProgressIndicator(
                      value: state.xpInLevel / 300,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                      color: _orange,
                      backgroundColor: const Color(0xFFFFF3D6),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${300 - state.xpInLevel} XP al prossimo livello',
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      if (state.activeGoal != null) ...[
        const SizedBox(height: 12),
        _GoalEvidenceCard(
          goal: state.activeGoal!,
          readiness: state.goalReadiness(state.activeGoal!),
        ),
      ],
      const SizedBox(height: 24),
      const _SectionTitle(
        title: 'Padronanza',
        subtitle: 'Si aggiorna dopo ogni risposta e guida il prossimo loop.',
      ),
      const SizedBox(height: 12),
      ...state.plan.map(
        (subject) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _MasteryCard(subject: subject),
        ),
      ),
      const SizedBox(height: 22),
      const _SectionTitle(
        title: 'Attività recente',
        subtitle: 'Le sessioni restano salvate sul dispositivo.',
      ),
      const SizedBox(height: 12),
      if (state.sessions.isEmpty)
        const _EmptySessions()
      else
        ...state.sessions
            .take(6)
            .map(
              (session) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SessionTile(session: session, state: state),
              ),
            ),
    ],
  );
}

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key, required this.state});
  final AppState state;

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  late final TextEditingController _topic;
  late final TextEditingController _material;
  late String _subjectId;
  late DateTime _examDate;

  @override
  void initState() {
    super.initState();
    final goal = widget.state.activeGoal;
    _topic = TextEditingController(text: goal?.topic ?? '');
    _material = TextEditingController(text: goal?.material ?? '');
    _subjectId = goal?.subjectId ?? 'science';
    _examDate = goal?.examDate ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _topic.dispose();
    _material.dispose();
    super.dispose();
  }

  void _loadDemo() {
    setState(() {
      _subjectId = 'science';
      _examDate = DateTime.now().add(const Duration(days: 7));
      _topic.text = 'Fotosintesi clorofilliana';
      _material.text =
          'La fotosintesi avviene nei cloroplasti. La clorofilla cattura '
          'l’energia della luce. La pianta usa acqua e anidride carbonica '
          'per produrre glucosio e libera ossigeno. Il glucosio conserva '
          'energia chimica utile alla pianta.';
    });
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _examDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Quando hai la verifica?',
    );
    if (value != null) setState(() => _examDate = value);
  }

  Future<void> _save() async {
    final topic = _topic.text.trim();
    final material = _material.text.trim();
    if (topic.length < 3 || material.length < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Inserisci un argomento e almeno 30 caratteri di appunti.',
          ),
        ),
      );
      return;
    }
    final previous = widget.state.activeGoal;
    final sameGoal =
        previous != null &&
        previous.subjectId == _subjectId &&
        previous.topic.trim().toLowerCase() == topic.toLowerCase();
    await widget.state.saveGoal(
      LearningGoal(
        id: sameGoal
            ? previous.id
            : DateTime.now().microsecondsSinceEpoch.toString(),
        subjectId: _subjectId,
        topic: topic,
        material: material,
        examDate: _examDate,
        createdAt: sameGoal ? previous.createdAt : DateTime.now(),
        completedLoops: sameGoal ? previous.completedLoops : 0,
        correctAnswers: sameGoal ? previous.correctAnswers : 0,
        totalAnswers: sameGoal ? previous.totalAnswers : 0,
        retryQuestions: sameGoal ? previous.retryQuestions : const [],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final date =
        '${_examDate.day.toString().padLeft(2, '0')}/'
        '${_examDate.month.toString().padLeft(2, '0')}/${_examDate.year}';
    return Scaffold(
      appBar: AppBar(title: const Text('Obiettivo verifica')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, color: _indigo),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Incolla ciò che devi sapere. StudyLoop lo trasforma in '
                      'micro-missioni e ripropone ciò che ricordi meno.',
                      style: TextStyle(
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _loadDemo,
              icon: const Icon(Icons.science_outlined),
              label: const Text('Carica esempio demo completo'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _subjectId,
              decoration: const InputDecoration(
                labelText: 'Materia',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: widget.state.subjects.values
                  .map(
                    (subject) => DropdownMenuItem(
                      value: subject.id,
                      child: Text(subject.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _subjectId = value ?? _subjectId),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _topic,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Argomento della verifica',
                hintText: 'Es. Fotosintesi clorofilliana',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data della verifica',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                child: Text(
                  date,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _material,
              minLines: 7,
              maxLines: 12,
              maxLength: 3000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Appunti o testo da studiare',
                hintText:
                    'Incolla un riassunto, gli appunti della lezione o il '
                    'testo più importante...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.rocket_launch_outlined),
              label: const Text('Crea il mio piano'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
            if (widget.state.activeGoal != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await widget.state.removeGoal();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Elimina questo obiettivo'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FocusScreen extends StatefulWidget {
  const FocusScreen({
    super.key,
    required this.subject,
    required this.minutes,
    this.questions,
    this.missionTitle,
    this.microLesson,
    this.grounded = false,
  });

  final SubjectProgress subject;
  final int minutes;
  final List<QuizQuestion>? questions;
  final String? missionTitle;
  final String? microLesson;
  final bool grounded;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? _timer;
  late int _seconds;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _seconds = widget.minutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        timer.cancel();
        setState(() {
          _seconds = 0;
          _running = false;
        });
        _verify();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _verify() async {
    _timer?.cancel();
    final answers = await Navigator.of(context).push<List<bool>>(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions:
              widget.questions ??
              AdaptiveEngine.questionsFor(widget.subject.id),
          title: widget.missionTitle ?? widget.subject.name,
        ),
      ),
    );
    if (!mounted || answers == null) return;
    Navigator.of(context).pop(answers);
  }

  @override
  Widget build(BuildContext context) {
    final min = (_seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_seconds % 60).toString().padLeft(2, '0');
    final progress = 1 - _seconds / (widget.minutes * 60);
    return Scaffold(
      backgroundColor: const Color(0xFF17153B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Focus mode'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          children: [
            const SizedBox(height: 10),
            Text(
              widget.missionTitle ?? widget.subject.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFC7D2FE),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.microLesson != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF24214F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF3D3975)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.grounded
                          ? 'MISSIONE DAI TUOI APPUNTI'
                          : 'MICRO-LEZIONE',
                      style: const TextStyle(
                        color: Color(0xFFA5B4FC),
                        fontSize: 11,
                        letterSpacing: .8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.microLesson!,
                      style: const TextStyle(color: Colors.white, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 26),
            Center(
              child: SizedBox.square(
                dimension: 230,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor: const Color(0xFF302E5F),
                      color: const Color(0xFF8B8CF8),
                    ),
                    Center(
                      child: Text(
                        '$min:$sec',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Una cosa alla volta. Alla fine, tre domande renderanno '
              'visibile ciò che hai davvero consolidato.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFB8B7D4), height: 1.45),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _toggle,
              icon: Icon(_running ? Icons.pause : Icons.play_arrow),
              label: Text(_running ? 'Metti in pausa' : 'Avvia focus'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: const Color(0xFF7C7DF4),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _verify,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC7D2FE),
              ),
              child: const Text('Ho finito: verifica ciò che ricordo'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.questions, required this.title});

  final List<QuizQuestion> questions;
  final String title;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int? _selected;
  bool _checked = false;
  final List<bool> _answers = [];

  QuizQuestion get question => widget.questions[_index];

  void _check() {
    if (_selected == null) return;
    final correct = _selected == question.correctIndex;
    setState(() {
      _checked = true;
      _answers.add(correct);
    });
  }

  void _next() {
    if (_index == widget.questions.length - 1) {
      Navigator.of(context).pop(_answers);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _checked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final correct = _selected == question.correctIndex;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: LinearProgressIndicator(
            value: (_index + 1) / widget.questions.length,
            minHeight: 5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'DOMANDA ${_index + 1} DI ${widget.questions.length}',
                    style: const TextStyle(
                      color: _indigo,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  question.topic,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              question.prompt,
              style: const TextStyle(
                color: _ink,
                fontSize: 25,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(question.options.length, (index) {
              Color? border;
              Color? background;
              if (_checked && index == question.correctIndex) {
                border = _mint;
                background = const Color(0xFFE7F7F1);
              } else if (_checked && index == _selected) {
                border = Colors.redAccent;
                background = const Color(0xFFFFECEA);
              } else if (index == _selected) {
                border = _indigo;
                background = const Color(0xFFEEF2FF);
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: _checked
                      ? null
                      : () => setState(() => _selected = index),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: background ?? Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: border ?? const Color(0xFFE4E7EC),
                        width: border == null ? 1 : 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: border?.withValues(alpha: .14),
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              color: border ?? _muted,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.options[index],
                            style: const TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (_checked) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: correct
                      ? const Color(0xFFE7F7F1)
                      : const Color(0xFFFFECEA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      correct ? 'Ricordo consolidato' : 'Errore utile',
                      style: TextStyle(
                        color: correct ? _mint : Colors.redAccent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(question.explanation),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _checked ? _next : (_selected == null ? null : _check),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _checked
                    ? (_index == widget.questions.length - 1
                          ? 'Completa il loop'
                          : 'Prossima domanda')
                    : 'Verifica risposta',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyPackCard extends StatelessWidget {
  const _StudyPackCard({required this.pack, required this.onStart});
  final StudyPack pack;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                pack.aiGenerated ? Icons.auto_awesome : Icons.offline_bolt,
                color: pack.aiGenerated ? _indigo : _orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pack.title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'MICRO-LEZIONE',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              letterSpacing: .8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(pack.microLesson, style: const TextStyle(height: 1.45)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.psychology_alt_outlined, color: _indigo),
                const SizedBox(width: 9),
                Expanded(child: Text(pack.whyItMatters)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.quiz_outlined),
            label: Text('Inizia ${pack.questions.length} domande'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LoopDiagram extends StatelessWidget {
  const _LoopDiagram();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Row(
        children: const [
          Expanded(
            child: _LoopNode(icon: Icons.center_focus_strong, label: 'Focus'),
          ),
          _LoopArrow(),
          Expanded(
            child: _LoopNode(icon: Icons.quiz_outlined, label: 'Recall'),
          ),
          _LoopArrow(),
          Expanded(
            child: _LoopNode(icon: Icons.tune, label: 'Adatta'),
          ),
          _LoopArrow(),
          Expanded(
            child: _LoopNode(icon: Icons.event_repeat, label: 'Ripeti'),
          ),
        ],
      ),
    ),
  );
}

class _LoopNode extends StatelessWidget {
  const _LoopNode({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        backgroundColor: const Color(0xFFEEF2FF),
        foregroundColor: _indigo,
        child: Icon(icon, size: 20),
      ),
      const SizedBox(height: 7),
      FittedBox(
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
    ],
  );
}

class _LoopArrow extends StatelessWidget {
  const _LoopArrow();
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.chevron_right, size: 18, color: _muted);
}

class _ExplainCard extends StatelessWidget {
  const _ExplainCard({required this.subject});
  final SubjectProgress subject;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubjectBadge(subject: subject),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject.name,
                        style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${(subject.mastery * 100).round()}%',
                      style: const TextStyle(
                        color: _indigo,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  AdaptiveEngine.reasonFor(subject),
                  style: const TextStyle(color: _muted, height: 1.35),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: subject.mastery,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(7),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.subject,
    required this.rank,
    required this.onTap,
  });
  final SubjectProgress subject;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Text(
              '$rank',
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 12),
            _SubjectBadge(subject: subject),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AdaptiveEngine.reasonFor(subject),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}

class _MasteryCard extends StatelessWidget {
  const _MasteryCard({required this.subject});
  final SubjectProgress subject;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              _SubjectBadge(subject: subject),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  subject.name,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${(subject.mastery * 100).round()}%',
                style: const TextStyle(
                  color: _indigo,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: subject.mastery,
            minHeight: 9,
            borderRadius: BorderRadius.circular(9),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${(subject.accuracy * 100).round()}% accuratezza',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '${subject.attempts} risposte',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.state});
  final StudySession session;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final subject = state.subjects[session.subjectId];
    final time = session.completedAt;
    final hour =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Card(
      child: ListTile(
        leading: subject == null
            ? const CircleAvatar(child: Icon(Icons.school))
            : _SubjectBadge(subject: subject),
        title: Text(
          subject?.name ?? 'Coach AI',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${session.minutes} min • $hour'),
        trailing: Text(
          '${(session.score * 100).round()}%',
          style: TextStyle(
            color: session.score >= .67 ? _mint : _orange,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SubjectBadge extends StatelessWidget {
  const _SubjectBadge({required this.subject});
  final SubjectProgress subject;

  Color get color => switch (subject.id) {
    'math' => _indigo,
    'english' => _mint,
    _ => _orange,
  };

  @override
  Widget build(BuildContext context) => CircleAvatar(
    backgroundColor: color.withValues(alpha: .12),
    foregroundColor: color,
    child: Text(
      subject.emoji,
      style: const TextStyle(fontWeight: FontWeight.w900),
    ),
  );
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        FittedBox(
          child: Text(
            label,
            style: const TextStyle(color: _muted, fontSize: 10),
          ),
        ),
      ],
    ),
  );
}

class _BigMetric extends StatelessWidget {
  const _BigMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(label, style: const TextStyle(color: _muted)),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: _ink,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 3),
      Text(subtitle, style: const TextStyle(color: _muted, fontSize: 13)),
    ],
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: _ink, fontWeight: FontWeight.w800),
  );
}

class _WhiteTag extends StatelessWidget {
  const _WhiteTag({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _AiStatusChip extends StatelessWidget {
  const _AiStatusChip({required this.live, required this.configured});
  final bool live;
  final bool configured;

  @override
  Widget build(BuildContext context) {
    final color = live ? _mint : (configured ? _indigo : _orange);
    final label = live
        ? 'GPT-5.6 Sol'
        : (configured ? 'Backend salvato' : 'Demo offline');
    final icon = live
        ? Icons.cloud_done_outlined
        : (configured ? Icons.dns_outlined : Icons.offline_bolt_outlined);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF7F2),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.shield_outlined, color: _mint),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Privacy by design: niente chiavi API nell’APK. Il backend riceve '
            'solo materia, livello e appunti inseriti volontariamente.',
            style: TextStyle(height: 1.35),
          ),
        ),
      ],
    ),
  );
}

class _EmptySessions extends StatelessWidget {
  const _EmptySessions();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          Icon(Icons.history, color: _muted, size: 36),
          SizedBox(height: 10),
          Text(
            'Completa il primo loop per vedere qui la tua storia.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted),
          ),
        ],
      ),
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.size = 52});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
      ),
      borderRadius: BorderRadius.circular(size * .3),
    ),
    child: Icon(Icons.loop, color: Colors.white, size: size * .56),
  );
}
