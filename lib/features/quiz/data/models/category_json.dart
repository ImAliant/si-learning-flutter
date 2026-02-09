import 'question_json.dart';

class CategoryJson {
  CategoryJson({required this.categoryName, required this.questions});

  final String categoryName;
  final List<QuestionJson> questions;

  factory CategoryJson.fromJson(Map<String, dynamic> json) {
    final items = json['questions'] as List<dynamic>;
    return CategoryJson(
      categoryName: json['categoryName'] as String,
      questions:
          items
              .map(
                (item) => QuestionJson.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}
