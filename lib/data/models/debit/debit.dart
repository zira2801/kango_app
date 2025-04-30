import 'dart:convert';

DebitResponse debitModelFromJson(String str) =>
    DebitResponse.fromJson(json.decode(str));

String debitModelToJson(DebitResponse data) => json.encode(data.toJson());

class DebitResponse {
  final int status;
  final List<Debit> debits;

  DebitResponse({
    required this.status,
    required this.debits,
  });

  factory DebitResponse.fromJson(Map<String, dynamic> json) => DebitResponse(
        status: json["status"],
        debits: List<Debit>.from(json["debits"].map((x) => Debit.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "debits": List<dynamic>.from(debits.map((x) => x.toJson())),
      };
}

class Debit {
  final int debitId;
  final String debitNo;
  final int paymentByStatement;
  final int? statementId;
  final int customerId;
  final int createdBy;
  final String? debitNote;
  final int debitStatus;
  final int debitType;
  final String debitFsc;
  final String? debitAdvanceDate;
  final String? debitAdvanceNote;
  final String? debitAdvanceImages;
  final int debitAdvanceAmount;
  final String? debitPaymentDate;
  final int debitPaymentAmount;
  final int debitAccount;
  final int activeFlg;
  final int deleteFlg;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? debitImages;
  final int paymentMethod;
  final int checkedPaymentStatus;
  final int totalPrice;
  final int totalVat;
  final int totalAmountCustomer;
  final int totalNoConfirm;
  final String statusLabel;
  final String typeLabel;

  Debit({
    required this.debitId,
    required this.debitNo,
    required this.paymentByStatement,
    this.statementId,
    required this.customerId,
    required this.createdBy,
    this.debitNote,
    required this.debitStatus,
    required this.debitType,
    required this.debitFsc,
    this.debitAdvanceDate,
    this.debitAdvanceNote,
    this.debitAdvanceImages,
    required this.debitAdvanceAmount,
    this.debitPaymentDate,
    required this.debitPaymentAmount,
    required this.debitAccount,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    this.debitImages,
    required this.paymentMethod,
    required this.checkedPaymentStatus,
    required this.totalPrice,
    required this.totalVat,
    required this.totalAmountCustomer,
    required this.totalNoConfirm,
    required this.statusLabel,
    required this.typeLabel,
  });

  factory Debit.fromJson(Map<String, dynamic> json) => Debit(
        debitId: json["debit_id"],
        debitNo: json["debit_no"],
        paymentByStatement: json["payment_by_statement"],
        statementId: json["statement_id"],
        customerId: json["customer_id"],
        createdBy: json["created_by"],
        debitNote: json["debit_note"],
        debitStatus: json["debit_status"],
        debitType: json["debit_type"],
        debitFsc: json["debit_fsc"],
        debitAdvanceDate: json["debit_advance_date"],
        debitAdvanceNote: json["debit_advance_note"],
        debitAdvanceImages: json["debit_advance_images"],
        debitAdvanceAmount: json["debit_advance_amount"],
        debitPaymentDate: json["debit_payment_date"],
        debitPaymentAmount: json["debit_payment_amount"],
        debitAccount: json["debit_account"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        debitImages: json["debit_images"],
        paymentMethod: json["payment_method"],
        checkedPaymentStatus: json["checked_payment_status"],
        totalPrice: json["total_price"],
        totalVat: json["total_vat"],
        totalAmountCustomer: json["total_amount_customer"],
        totalNoConfirm: json["total_no_confirm"],
        statusLabel: json["status_label"],
        typeLabel: json["type_label"],
      );

  Map<String, dynamic> toJson() => {
        "debit_id": debitId,
        "debit_no": debitNo,
        "payment_by_statement": paymentByStatement,
        "statement_id": statementId,
        "customer_id": customerId,
        "created_by": createdBy,
        "debit_note": debitNote,
        "debit_status": debitStatus,
        "debit_type": debitType,
        "debit_fsc": debitFsc,
        "debit_advance_date": debitAdvanceDate,
        "debit_advance_note": debitAdvanceNote,
        "debit_advance_images": debitAdvanceImages,
        "debit_advance_amount": debitAdvanceAmount,
        "debit_payment_date": debitPaymentDate,
        "debit_payment_amount": debitPaymentAmount,
        "debit_account": debitAccount,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "debit_images": debitImages,
        "payment_method": paymentMethod,
        "checked_payment_status": checkedPaymentStatus,
        "total_price": totalPrice,
        "total_vat": totalVat,
        "total_amount_customer": totalAmountCustomer,
        "total_no_confirm": totalNoConfirm,
        "status_label": statusLabel,
        "type_label": typeLabel,
      };
}
