class QuestionJson {
  QuestionJson({required this.question, required this.answer, this.image});

  final String question;
  final String answer;
  final String? image;

  factory QuestionJson.fromJson(Map<String, dynamic> json) {
    return QuestionJson(
      question: json['question'] as String,
      answer: json['answer'] as String,
      image: json['image'] as String?,
    );
  }
}
