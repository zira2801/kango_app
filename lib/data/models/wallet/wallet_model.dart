// wallet_response.dart
import 'dart:convert';

WalletResponse walletResponseFromJson(String str) =>
    WalletResponse.fromJson(json.decode(str));

String walletResponseToJson(WalletResponse data) => json.encode(data.toJson());

class WalletResponse {
  final int? status;
  final WalletData? wallet;

  WalletResponse({
    this.status,
    this.wallet,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      status: json['status'],
      wallet:
          json['wallet'] != null ? WalletData.fromJson(json['wallet']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'wallet': wallet?.toJson(),
    };
  }
}

class WalletData {
  final int? walletId;
  final int? userId;
  final double? amount;
  final int? activeFlag;
  final int? deleteFlag;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WalletData({
    this.walletId,
    this.userId,
    this.amount,
    this.activeFlag,
    this.deleteFlag,
    this.createdAt,
    this.updatedAt,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      walletId: json['wallet_id'],
      userId: json['user_id'],
      amount: json['amount'] != null ? json['amount'].toDouble() : null,
      activeFlag: json['active_flg'],
      deleteFlag: json['delete_flg'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'user_id': userId,
      'amount': amount,
      'active_flg': activeFlag,
      'delete_flg': deleteFlag,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
