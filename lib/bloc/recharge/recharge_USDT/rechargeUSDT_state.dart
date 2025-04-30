part of 'rechargeUSDT_bloc.dart';

abstract class ReChargeUSDTState extends Equatable {
  const ReChargeUSDTState();
  @override
  List<Object?> get props => [];
}

class RequestReChargeUSDTStateInitial extends ReChargeUSDTState {}

class RequestReChargeUSDTStateLoading extends ReChargeUSDTState {}

class RequestReChargeUSDTStateSuccess extends ReChargeUSDTState {
  final String message;

  const RequestReChargeUSDTStateSuccess({required this.message});

  RequestReChargeUSDTStateSuccess copyWith({String? message}) {
    return RequestReChargeUSDTStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class RequestReChargeUSDTFailure extends ReChargeUSDTState {
  final String message;

  const RequestReChargeUSDTFailure({required this.message});

  RequestReChargeUSDTFailure copyWith({String? message}) {
    return RequestReChargeUSDTFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
