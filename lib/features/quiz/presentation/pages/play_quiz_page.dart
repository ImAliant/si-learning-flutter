import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../providers/quiz_providers.dart';

class PlayQuizPage extends ConsumerWidget {
  const PlayQuizPage({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsByCategoryProvider(category.id));

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
                child: ExpansionTile(
                  title: Text(
                    question.question,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          question.answer,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
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
