import 'package:hive/hive.dart';

part 'quiz_entry_model.g.dart';

@HiveType(typeId: 1)
class QuizEntryModel extends HiveObject {
  @HiveField(0)
  String question;

  @HiveField(1)
  String answer;

  @HiveField(2)
  int number;

  QuizEntryModel({
    required this.question,
    required this.answer,
    required this.number,
  });
}
