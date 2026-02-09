import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

class UpdateQuestion {
  UpdateQuestion(this._repository);

  final QuizRepository _repository;

  Future<void> call(Question question) {
    return _repository.updateQuestion(question);
  }
}
