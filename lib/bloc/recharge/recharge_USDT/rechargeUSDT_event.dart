part of 'rechargeUSDT_bloc.dart';

abstract class ReChargeUSDTSEvent extends Equatable {
  const ReChargeUSDTSEvent();

  @override
  List<Object?> get props => [];
}

class HandleReChargeUSDT extends ReChargeUSDTSEvent {
  final int? amount;
  final double? usdt_price;
  final int? type;
  final String? note;
  final String? image;
  const HandleReChargeUSDT({
    required this.amount,
    required this.note,
    required this.image,
    this.usdt_price,
    required this.type,
  });
  @override
  List<Object?> get props => [amount, note, image];
}
