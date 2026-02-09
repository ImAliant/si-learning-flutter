import '../entities/category.dart';
import '../entities/question.dart';

abstract class QuizRepository {
  Stream<List<Category>> watchAllCategories();
  Stream<Category?> watchCategoryById(int id);
  Stream<Category?> watchCategoryByName(String name);
  Stream<List<Question>> watchQuestionsByCategoryId(int categoryId);
  Stream<List<Question>> watchQuestionsByCategoryName(String name);
  Stream<List<Question>> watchAllQuestions();
  Stream<Question?> watchQuestionById(int id);
  Stream<List<Question>> watchQuestionsNeedingHelp();

  Future<int> insertCategory(Category category);
  Future<int> insertQuestion(Question question);
  Future<void> updateQuestion(Question question);
}
