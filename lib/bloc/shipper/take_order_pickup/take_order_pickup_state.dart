part of 'take_order_pickup_bloc.dart';

abstract class TakeOrderPickupState extends Equatable {
  const TakeOrderPickupState();
  @override
  List<Object?> get props => [];
}

class TakeOrderPickupInitial extends TakeOrderPickupState {}

class TakeOrderPickupLoading extends TakeOrderPickupState {}

class TakeOrderPickupSuccess extends TakeOrderPickupState {
  final String? successText;
  TakeOrderPickupSuccess({
    this.successText,
  });
}

class TakeOrderPickupFailure extends TakeOrderPickupState {
  final String? errorText;
  TakeOrderPickupFailure({this.errorText});
}
