import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/quiz_local_datasource.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/usecases/get_all_questions.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_questions_by_category.dart';
import '../../domain/usecases/get_questions_needing_help.dart';
import '../../domain/usecases/update_question.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final quizDaoProvider = Provider<QuizDao>((ref) {
  return ref.watch(databaseProvider).quizDao;
});

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final dao = ref.watch(quizDaoProvider);
  final local = QuizLocalDataSource(dao);
  return QuizRepositoryImpl(local);
});

final getCategoriesProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.watch(quizRepositoryProvider));
});

final getQuestionsByCategoryProvider = Provider<GetQuestionsByCategory>((ref) {
  return GetQuestionsByCategory(ref.watch(quizRepositoryProvider));
});

final getQuestionsNeedingHelpProvider = Provider<GetQuestionsNeedingHelp>((
  ref,
) {
  return GetQuestionsNeedingHelp(ref.watch(quizRepositoryProvider));
});

final updateQuestionProvider = Provider<UpdateQuestion>((ref) {
  return UpdateQuestion(ref.watch(quizRepositoryProvider));
});

final getAllQuestionsProvider = Provider<GetAllQuestions>((ref) {
  return GetAllQuestions(ref.watch(quizRepositoryProvider));
});

final randomQuestionsProvider = StreamProvider<List<Question>>((ref) {
  final seed = DateTime.now().millisecondsSinceEpoch;
  return ref.watch(getAllQuestionsProvider).call().map((questions) {
    final shuffled = List<Question>.from(questions)..shuffle(Random(seed));
    return shuffled.take(25).toList();
  });
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(getCategoriesProvider).call();
});

final questionsByCategoryProvider = StreamProvider.family<List<Question>, int>((
  ref,
  categoryId,
) {
  return ref.watch(getQuestionsByCategoryProvider).byId(categoryId);
});

final questionsNeedingHelpProvider = StreamProvider<List<Question>>((ref) {
  return ref.watch(getQuestionsNeedingHelpProvider).call();
});
