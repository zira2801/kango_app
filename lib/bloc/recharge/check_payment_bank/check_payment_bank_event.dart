part of 'check_payment_bank_bloc.dart';

abstract class CheckPaymentBankEvent extends Equatable {
  const CheckPaymentBankEvent();

  @override
  List<Object?> get props => [];
}

class HandleCheckPaymentBank extends CheckPaymentBankEvent {
  final String orderId;

  const HandleCheckPaymentBank({required this.orderId});
  @override
  List<Object> get props => [orderId];
}
