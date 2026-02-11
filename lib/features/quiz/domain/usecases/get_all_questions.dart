import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

class GetAllQuestions {
  GetAllQuestions(this._repository);

  final QuizRepository _repository;

  Stream<List<Question>> call() {
    return _repository.watchAllQuestions();
  }
}
