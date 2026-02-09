class Question {
  const Question({
    required this.id,
    required this.question,
    required this.answer,
    required this.imageKey,
    required this.categoryId,
    required this.needHelp,
  });

  final int id;
  final String question;
  final String answer;
  final String? imageKey;
  final int categoryId;
  final bool needHelp;
}
