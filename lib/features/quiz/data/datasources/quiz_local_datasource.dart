import '../db/app_database.dart';

class QuizLocalDataSource {
  QuizLocalDataSource(this._dao);

  final QuizDao _dao;

  Stream<List<CategoryEntry>> watchAllCategories() {
    return _dao.watchAllCategories();
  }

  Stream<CategoryEntry?> watchCategoryById(int id) {
    return _dao.watchCategoryById(id);
  }

  Stream<CategoryEntry?> watchCategoryByName(String name) {
    return _dao.watchCategoryByName(name);
  }

  Stream<List<QuestionEntry>> watchQuestionsByCategoryId(int categoryId) {
    return _dao.watchQuestionsByCategoryId(categoryId);
  }

  Stream<List<QuestionEntry>> watchQuestionsByCategoryName(String name) {
    return _dao.watchQuestionsByCategoryName(name);
  }

  Stream<QuestionEntry?> watchQuestionById(int id) {
    return _dao.watchQuestionById(id);
  }

  Stream<List<QuestionEntry>> watchAllQuestions() {
    return _dao.watchAllQuestions();
  }

  Stream<List<QuestionEntry>> watchQuestionsNeedingHelp() {
    return _dao.watchQuestionsNeedingHelp();
  }

  Future<int> insertCategory(CategoryEntry entry) {
    return _dao.insertCategory(entry);
  }

  Future<int> insertQuestion(QuestionEntry entry) {
    return _dao.insertQuestion(entry);
  }

  Future<void> updateQuestion(QuestionEntry entry) {
    return _dao.updateQuestion(entry);
  }
}
