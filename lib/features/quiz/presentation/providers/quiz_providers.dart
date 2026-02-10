import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/quiz_local_datasource.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_questions_by_category.dart';

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

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(getCategoriesProvider).call();
});

final questionsByCategoryProvider = StreamProvider.family<List<Question>, int>((
  ref,
  categoryId,
) {
  return ref.watch(getQuestionsByCategoryProvider).byId(categoryId);
});
