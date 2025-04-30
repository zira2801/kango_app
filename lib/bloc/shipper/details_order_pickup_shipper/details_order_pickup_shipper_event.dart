part of 'details_order_pickup_shipper_bloc.dart';

abstract class DetailsOrderPickupShipperEvent extends Equatable {
  const DetailsOrderPickupShipperEvent();

  @override
  List<Object?> get props => [];
}

class HanldeGetDetailsOrderShipperPickup
    extends DetailsOrderPickupShipperEvent {
  final int orderPickupID;
  HanldeGetDetailsOrderShipperPickup({
    required this.orderPickupID,
  });
  @override
  List<Object?> get props => [orderPickupID];
}
