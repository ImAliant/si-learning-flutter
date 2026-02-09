import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

class GetQuestionsNeedingHelp {
  GetQuestionsNeedingHelp(this._repository);

  final QuizRepository _repository;

  Stream<List<Question>> call() {
    return _repository.watchQuestionsNeedingHelp();
  }
}
