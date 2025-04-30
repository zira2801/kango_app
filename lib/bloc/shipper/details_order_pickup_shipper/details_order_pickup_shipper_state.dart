part of 'details_order_pickup_shipper_bloc.dart';

abstract class DetailsOrderPickupShipperState extends Equatable {
  const DetailsOrderPickupShipperState();
  @override
  List<Object?> get props => [];
}

class HanldeGetDetailsOrderPickupShipperLoading
    extends DetailsOrderPickupShipperState {}

class HanldeGetDetailsOrderPickupShipperSuccess
    extends DetailsOrderPickupShipperState {
  final DetailsOrderPickUpModel detailsOrderPickUpModel;
  const HanldeGetDetailsOrderPickupShipperSuccess(
      {required this.detailsOrderPickUpModel});

  HanldeGetDetailsOrderPickupShipperSuccess copyWith(
      {DetailsOrderPickUpModel? detailsOrderPickUpModel}) {
    return HanldeGetDetailsOrderPickupShipperSuccess(
        detailsOrderPickUpModel:
            detailsOrderPickUpModel ?? this.detailsOrderPickUpModel);
  }

  @override
  List<Object?> get props => [detailsOrderPickUpModel];
}

class HanldeGetDetailsOrderPickupShipperFailure
    extends DetailsOrderPickupShipperState {
  final String message;
  const HanldeGetDetailsOrderPickupShipperFailure({required this.message});
  HanldeGetDetailsOrderPickupShipperFailure copyWith({String? message}) {
    return HanldeGetDetailsOrderPickupShipperFailure(
        message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
