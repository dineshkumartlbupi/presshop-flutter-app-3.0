import 'package:equatable/equatable.dart';

class FAQ extends Equatable {
  final String id;
  final String question;
  final String answer;
  final String category;
  final bool selected;

  const FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.selected = false,
  });

  @override
  List<Object?> get props => [id, question, answer, category, selected];

  FAQ copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    bool? selected,
  }) {
    return FAQ(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      selected: selected ?? this.selected,
    );
  }
}
