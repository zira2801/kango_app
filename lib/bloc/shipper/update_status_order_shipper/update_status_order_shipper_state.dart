part of 'update_status_order_shipper_bloc.dart';

abstract class UpdateStatusOrderPickupShipperState extends Equatable {
  const UpdateStatusOrderPickupShipperState();
  @override
  List<Object?> get props => [];
}

class UpdateStatusOrderPickupShipperInitial
    extends UpdateStatusOrderPickupShipperState {}

class UpdateStatusOrderPickupShipperLoading
    extends UpdateStatusOrderPickupShipperState {}

class UpdateStatusOrderPickupShipperSuccess
    extends UpdateStatusOrderPickupShipperState {}

class UpdateStatusOrderPickupShipperFailure
    extends UpdateStatusOrderPickupShipperState {
  final String? errorText;
  UpdateStatusOrderPickupShipperFailure({this.errorText});
}
