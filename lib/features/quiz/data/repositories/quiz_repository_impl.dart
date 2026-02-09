import '../../domain/entities/category.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_local_datasource.dart';
import '../db/app_database.dart';

class QuizRepositoryImpl implements QuizRepository {
  QuizRepositoryImpl(this._local);

  final QuizLocalDataSource _local;

  @override
  Stream<List<Category>> watchAllCategories() {
    return _local.watchAllCategories().map(
      (items) => items.map((entry) => entry.toDomain()).toList(),
    );
  }

  @override
  Stream<Category?> watchCategoryById(int id) {
    return _local.watchCategoryById(id).map((entry) => entry?.toDomain());
  }

  @override
  Stream<Category?> watchCategoryByName(String name) {
    return _local.watchCategoryByName(name).map((entry) => entry?.toDomain());
  }

  @override
  Stream<List<Question>> watchQuestionsByCategoryId(int categoryId) {
    return _local
        .watchQuestionsByCategoryId(categoryId)
        .map((items) => items.map((entry) => entry.toDomain()).toList());
  }

  @override
  Stream<List<Question>> watchQuestionsByCategoryName(String name) {
    return _local
        .watchQuestionsByCategoryName(name)
        .map((items) => items.map((entry) => entry.toDomain()).toList());
  }

  @override
  Stream<List<Question>> watchAllQuestions() {
    return _local.watchAllQuestions().map(
      (items) => items.map((entry) => entry.toDomain()).toList(),
    );
  }

  @override
  Stream<Question?> watchQuestionById(int id) {
    return _local.watchQuestionById(id).map((entry) => entry?.toDomain());
  }

  @override
  Stream<List<Question>> watchQuestionsNeedingHelp() {
    return _local.watchQuestionsNeedingHelp().map(
      (items) => items.map((entry) => entry.toDomain()).toList(),
    );
  }

  @override
  Future<int> insertCategory(Category category) {
    return _local.insertCategory(category.toEntry());
  }

  @override
  Future<int> insertQuestion(Question question) {
    return _local.insertQuestion(question.toEntry());
  }

  @override
  Future<void> updateQuestion(Question question) {
    return _local.updateQuestion(question.toEntry());
  }
}

extension CategoryEntryMapper on CategoryEntry {
  Category toDomain() {
    return Category(id: id, name: name);
  }
}

extension QuestionEntryMapper on QuestionEntry {
  Question toDomain() {
    return Question(
      id: id,
      question: question,
      answer: answer,
      imageKey: imageKey,
      categoryId: categoryId,
      needHelp: needHelp,
    );
  }
}

extension CategoryMapper on Category {
  CategoryEntry toEntry() {
    return CategoryEntry(id: id, name: name);
  }
}

extension QuestionMapper on Question {
  QuestionEntry toEntry() {
    return QuestionEntry(
      id: id,
      question: question,
      answer: answer,
      imageKey: imageKey,
      categoryId: categoryId,
      needHelp: needHelp,
    );
  }
}
