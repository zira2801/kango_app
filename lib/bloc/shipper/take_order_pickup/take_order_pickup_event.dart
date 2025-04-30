part of 'take_order_pickup_bloc.dart';

abstract class TakeOrderPickupEvent extends Equatable {
  const TakeOrderPickupEvent();

  @override
  List<Object?> get props => [];
}

class HanldeTakeOrderPickupShipper extends TakeOrderPickupEvent {
  final int shipperID;
  final int orderPickUpID;
  final double? shipperLongitude;
  final double? shipperLatitude;
  final String? locationAddress;

  HanldeTakeOrderPickupShipper({
    required this.shipperID,
    required this.orderPickUpID,
    required this.shipperLongitude,
    required this.shipperLatitude,
    required this.locationAddress,
  });
  @override
  List<Object?> get props => [
        shipperID,
        orderPickUpID,
        shipperLongitude,
        shipperLatitude,
        locationAddress
      ];
}
