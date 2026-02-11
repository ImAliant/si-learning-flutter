import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/question.dart';
import '../providers/quiz_providers.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key, required this.category});

  final Category category;

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  static const int _maxSeconds = 15;

  final TextEditingController _answerController = TextEditingController();
  Timer? _timer;
  int _currentIndex = 0;
  int _timeLeft = _maxSeconds;
  bool _isComplete = false;
  bool? _isAnswerCorrect;
  bool _timerDone = false;
  bool _answerRevealed = false;
  final Map<int, bool> _revisionOverrides = {};

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _startTimer(int totalQuestions) {
    _timer?.cancel();
    _timeLeft = _maxSeconds;
    _timerDone = false;
    _answerRevealed = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isComplete) {
        timer.cancel();
        return;
      }
      setState(() => _timeLeft -= 1);
      if (_timeLeft <= 0) {
        timer.cancel();
        setState(() {
          _timerDone = true;
        });
      }
    });
  }

  void _goToNextQuestion(int totalQuestions) {
    if (!mounted) return;

    if (_currentIndex + 1 >= totalQuestions) {
      setState(() {
        _isComplete = true;
      });
      _timer?.cancel();
      return;
    }

    setState(() {
      _currentIndex += 1;
      _timeLeft = _maxSeconds;
      _isAnswerCorrect = null;
      _timerDone = false;
      _answerRevealed = false;
    });
    _answerController.clear();
    _startTimer(totalQuestions);
  }

  String _normalizeAnswer(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  void _validateAnswer(Question question) {
    final userAnswer = _normalizeAnswer(_answerController.text);
    final correctAnswer = _normalizeAnswer(question.answer);
    _timer?.cancel();
    setState(() {
      _isAnswerCorrect = userAnswer.isNotEmpty && userAnswer == correctAnswer;
    });
  }

  void _showAnswer() {
    _timer?.cancel();
    setState(() {
      _answerRevealed = true;
      _timeLeft = 0;
    });
  }

  Future<void> _toggleRevision(Question question, bool isRevision) async {
    final updated = Question(
      id: question.id,
      question: question.question,
      answer: question.answer,
      imageKey: question.imageKey,
      categoryId: question.categoryId,
      needHelp: !isRevision,
    );

    setState(() {
      _revisionOverrides[question.id] = !isRevision;
    });

    await ref.read(updateQuestionProvider).call(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !isRevision ? 'Added to "Révision".' : 'Removed from "Révision".',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync =
        widget.category.name == 'Révision'
            ? ref.watch(questionsNeedingHelpProvider)
            : ref.watch(questionsByCategoryProvider(widget.category.id));

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No questions yet.'));
          }

          if (_isComplete) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 48),
                  const SizedBox(height: 24),
                  const Text('All questions completed.'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                        _isComplete = false;
                        _isAnswerCorrect = null;
                        _timerDone = false;
                        _answerRevealed = false;
                      });
                      _answerController.clear();
                      _startTimer(questions.length);
                    },
                    child: const Text('Restart'),
                  ),
                ],
              ),
            );
          }

          if (_currentIndex >= questions.length) {
            _currentIndex = 0;
          }

          final question = questions[_currentIndex];
          final remaining = questions.length - (_currentIndex + 1);

          if (_timer == null) {
            _startTimer(questions.length);
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentIndex + 1} / ${questions.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$remaining left',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _timeLeft / _maxSeconds,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_timeLeft s',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _answerController,
                  enabled: !_timerDone,
                  decoration: const InputDecoration(
                    labelText: 'Your answer',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_timerDone) _validateAnswer(question);
                  },
                ),
                const SizedBox(height: 12),
                if (!_timerDone)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _validateAnswer(question),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Validate'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _answerRevealed ? null : _showAnswer,
                          icon: const Icon(Icons.visibility),
                          label: const Text('Show answer'),
                        ),
                      ),
                    ],
                  ),
                if (_isAnswerCorrect != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _isAnswerCorrect! ? 'Correct!' : 'Wrong answer.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _isAnswerCorrect! ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (_answerRevealed || _timerDone) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correct answer:',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: Colors.blue.shade800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.answer,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_timerDone ||
                    _answerRevealed ||
                    _isAnswerCorrect != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _goToNextQuestion(questions.length),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return Center(child: Text('Failed to load questions: $error'));
        },
      ),
      bottomNavigationBar: questionsAsync.maybeWhen(
        data: (questions) {
          if (questions.isEmpty || _isComplete) {
            return null;
          }

          final safeIndex = _currentIndex.clamp(0, questions.length - 1);
          final question = questions[safeIndex];
          final isRevision =
              _revisionOverrides[question.id] ?? question.needHelp;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                8 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleRevision(question, isRevision),
                      icon: Icon(
                        isRevision
                            ? Icons.bookmark
                            : Icons.bookmark_add_outlined,
                      ),
                      label: const Text('Révision'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }
}
