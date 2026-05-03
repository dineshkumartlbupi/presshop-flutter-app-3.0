import '../../domain/entities/faq.dart';

class FAQModel extends FAQ {
  const FAQModel({
    required super.id,
    required super.question,
    required super.answer,
    required super.category,
    super.selected,
  });

  factory FAQModel.fromJson(dynamic json) {
    var data = json;
    if (json['_doc'] != null) {
      data = json['_doc'];
    }
    return FAQModel(
      id: data["id"]?.toString() ?? data["_id"]?.toString() ?? '',
      question: data["question"] ?? data["ques"] ?? "",
      answer: data["answer"] ?? data["ans"] ?? "",
      category: data['category'] ?? "",
    );
  }
}
