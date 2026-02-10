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

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _startTimer(int totalQuestions) {
    _timer?.cancel();
    _timeLeft = _maxSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isComplete) {
        timer.cancel();
        return;
      }
      setState(() => _timeLeft -= 1);
      if (_timeLeft <= 0) {
        timer.cancel();
        _goToNextQuestion(totalQuestions);
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
    });
    _answerController.clear();
    _startTimer(totalQuestions);
  }

  Future<void> _markForRevision(Question question) async {
    if (question.needHelp) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Already in "Révision".')));
      return;
    }

    await ref
        .read(updateQuestionProvider)
        .call(
          Question(
            id: question.id,
            question: question.question,
            answer: question.answer,
            imageKey: question.imageKey,
            categoryId: question.categoryId,
            needHelp: true,
          ),
        );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to "Révision".')));
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
                  const SizedBox(height: 12),
                  const Text('All questions completed.'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                        _isComplete = false;
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
                  decoration: const InputDecoration(
                    labelText: 'Your answer',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _goToNextQuestion(questions.length),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _markForRevision(question),
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: const Text('Révision'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _goToNextQuestion(questions.length),
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Skip'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return Center(child: Text('Failed to load questions: $error'));
        },
      ),
    );
  }
}
