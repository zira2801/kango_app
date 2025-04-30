import 'dart:convert';

PaymentContentModel contentPaymentModelFromJson(String str) =>
    PaymentContentModel.fromJson(json.decode(str));

String contentPaymentModelToJson(PaymentContentModel data) =>
    json.encode(data.toJson());

class PaymentContentModel {
  final int id;
  final String key;
  final String title;
  final double amount;
  final Map<String, dynamic>? data;
  final String content;
  final bool active;

  PaymentContentModel({
    required this.id,
    required this.key,
    required this.title,
    required this.amount,
    this.data,
    required this.content,
    required this.active,
  });

  factory PaymentContentModel.fromJson(Map<String, dynamic> json) {
    return PaymentContentModel(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      data: json['data'],
      content: json['content'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "title": title,
        "amount": amount,
        "data": data,
        "content": content,
        "active": active
      };
}
