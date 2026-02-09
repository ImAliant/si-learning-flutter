import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

class GetQuestionsByCategory {
  GetQuestionsByCategory(this._repository);

  final QuizRepository _repository;

  Stream<List<Question>> byId(int categoryId) {
    return _repository.watchQuestionsByCategoryId(categoryId);
  }

  Stream<List<Question>> byName(String name) {
    return _repository.watchQuestionsByCategoryName(name);
  }
}
