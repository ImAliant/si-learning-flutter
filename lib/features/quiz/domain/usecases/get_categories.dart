import '../entities/category.dart';
import '../repositories/quiz_repository.dart';

class GetCategories {
  GetCategories(this._repository);

  final QuizRepository _repository;

  Stream<List<Category>> call() {
    return _repository.watchAllCategories();
  }
}
