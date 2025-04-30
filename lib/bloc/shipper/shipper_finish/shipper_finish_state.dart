part of 'shipper_finish_bloc.dart';

abstract class ShipperFinishState extends Equatable {
  const ShipperFinishState();
  @override
  List<Object?> get props => [];
}

class ShipperFinishInitial extends ShipperFinishState {}

class ShipperFinishLoading extends ShipperFinishState {}

class ShipperFinishSuccess extends ShipperFinishState {
  final String? successText;
  ShipperFinishSuccess({
    this.successText,
  });
}

class ShipperFinishFailure extends ShipperFinishState {
  final String? errorText;
  ShipperFinishFailure({this.errorText});
}
