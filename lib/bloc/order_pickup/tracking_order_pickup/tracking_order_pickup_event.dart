part of 'tracking_order_pickup_bloc.dart';

abstract class TrackingOrderPickupEvent extends Equatable {
  const TrackingOrderPickupEvent();

  @override
  List<Object?> get props => [];
}

class HanldeTrackingOrderPickup extends TrackingOrderPickupEvent {
  final double shipperLatitude;
  final double shipperLongitude;
  final String locationAddress;
  HanldeTrackingOrderPickup({
    required this.shipperLatitude,
    required this.shipperLongitude,
    required this.locationAddress,
  });
  @override
  List<Object?> get props =>
      [shipperLatitude, shipperLongitude, locationAddress];
}
