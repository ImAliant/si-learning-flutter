import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:si_learning_flutter/features/quiz/domain/entities/question.dart';

import '../../domain/entities/category.dart';
import '../providers/quiz_providers.dart';

class QuizPage extends ConsumerWidget {
  const QuizPage({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRevision = category.name == 'Révision';
    final questionsAsync =
        isRevision
            ? ref.watch(questionsNeedingHelpProvider)
            : ref.watch(questionsByCategoryProvider(category.id));

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No questions yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final question = questions[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.question,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.answer,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (isRevision) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () async {
                              await ref
                                  .read(updateQuestionProvider)
                                  .call(
                                    Question(
                                      id: question.id,
                                      question: question.question,
                                      answer: question.answer,
                                      imageKey: question.imageKey,
                                      categoryId: question.categoryId,
                                      needHelp: false,
                                    ),
                                  );

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Removed from "Révision".'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bookmark_remove_outlined),
                            label: const Text('Remove'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: questions.length,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) =>
                Center(child: Text('Failed to load questions: $error')),
      ),
    );
  }
}
