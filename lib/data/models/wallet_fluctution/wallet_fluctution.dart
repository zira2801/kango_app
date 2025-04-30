import 'dart:convert';

class WalletFluctuationResponse {
  final int status;
  final List<WalletFluctuation> data;
  final String message;

  WalletFluctuationResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory WalletFluctuationResponse.fromJsonString(String str) =>
      WalletFluctuationResponse.fromJson(json.decode(str));

  factory WalletFluctuationResponse.fromJson(Map<String, dynamic> json) {
    return WalletFluctuationResponse(
      status: json["status"],
      data: (json['data'] as List)
          .map((item) => WalletFluctuation.fromJson(item))
          .toList(),
      message: json["message"],
    );
  }
}

class WalletFluctuation {
  final int walletFluctuationId;
  final int walletId;
  final String secureHash;
  final int userId;
  final num amount;
  final num walletAmount;
  final String content;
  final int kind;
  final int activeFlg;
  final int deleteFlg;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userContactName;
  final String userCode;
  final int positionId;
  final String kindLabel;

  WalletFluctuation({
    required this.walletFluctuationId,
    required this.walletId,
    required this.secureHash,
    required this.userId,
    required this.amount,
    required this.walletAmount,
    required this.content,
    required this.kind,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.userContactName,
    required this.userCode,
    required this.positionId,
    required this.kindLabel,
  });

  factory WalletFluctuation.fromJson(Map<String, dynamic> json) =>
      WalletFluctuation(
        walletFluctuationId: json["wallet_fluctuation_id"],
        walletId: json["wallet_id"],
        secureHash: json["secure_hash"],
        userId: json["user_id"],
        amount: json["amount"],
        walletAmount: json["wallet_amount"],
        content: json["content"],
        kind: json["kind"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        userContactName: json["user_contact_name"],
        userCode: json["user_code"],
        positionId: json["position_id"],
        kindLabel: json["kind_label"],
      );

  Map<String, dynamic> toJson() {
    return {
      "wallet_fluctuation_id": walletFluctuationId,
      "wallet_id": walletId,
      "secure_hash": secureHash,
      "user_id": userId,
      "amount": amount,
      "wallet_amount": walletAmount,
      "content": content,
      "kind": kind,
      "active_flg": activeFlg,
      "delete_flg": deleteFlg,
      "create_at": createdAt,
      "update_at": updatedAt,
      "user_contact_name": userContactName,
      "user_code": userCode,
      "position_id": positionId,
      "kind_label": kindLabel
    };
  }
}
