part of 'shipper_start_bloc.dart';

abstract class ShipperStartState extends Equatable {
  const ShipperStartState();
  @override
  List<Object?> get props => [];
}

class ShipperStartInitial extends ShipperStartState {}

class ShipperStartLoading extends ShipperStartState {}

class ShipperStartSuccess extends ShipperStartState {
  final String? successText;
  ShipperStartSuccess({
    this.successText,
  });
}

class ShipperStartFailure extends ShipperStartState {
  final String? errorText;
  ShipperStartFailure({this.errorText});
}
