import '../../domain/entities/faq.dart';

class FAQModel extends FAQ {
  FAQModel({
    required String id,
    required String question,
    required String answer,
    required String category,
    bool selected = false,
  }) : super(
          id: id,
          question: question,
          answer: answer,
          category: category,
          selected: selected,
        );

  factory FAQModel.fromJson(dynamic json) {
    var data = json;
    if (json['_doc'] != null) {
      data = json['_doc'];
    }
    return FAQModel(
      id: data["_id"]?.toString() ?? '',
      question: data["ques"] ?? "",
      answer: data["ans"] ?? "",
      category: data['category'] ?? "",
    );
  }
}
