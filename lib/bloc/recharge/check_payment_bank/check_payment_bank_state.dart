part of 'check_payment_bank_bloc.dart';

abstract class CheckPaymentBankState extends Equatable {
  const CheckPaymentBankState();
  @override
  List<Object?> get props => [];
}

class CheckPaymentBankStateLoading extends CheckPaymentBankState {}

class CheckPaymentBankStateSuccess extends CheckPaymentBankState {}

class CheckPaymentBankStateFailure extends CheckPaymentBankState {}
