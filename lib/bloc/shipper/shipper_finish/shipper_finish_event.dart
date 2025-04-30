part of 'shipper_finish_bloc.dart';

abstract class ShipperFinishEvent extends Equatable {
  const ShipperFinishEvent();

  @override
  List<Object?> get props => [];
}

class HanldeShipperFinish extends ShipperFinishEvent {
  final String? shipperLongitude;
  final String? shipperLatitude;
  final String? shipperLocation;

  HanldeShipperFinish({
    required this.shipperLongitude,
    required this.shipperLatitude,
    required this.shipperLocation,
  });
  @override
  List<Object?> get props => [
        shipperLongitude,
        shipperLatitude,
        shipperLocation,
      ];
}
