part of 'shipper_start_bloc.dart';

abstract class ShipperStartEvent extends Equatable {
  const ShipperStartEvent();

  @override
  List<Object?> get props => [];
}

class HanldeShipperStart extends ShipperStartEvent {
  final int shipperID;

  HanldeShipperStart({
    required this.shipperID,
  });
  @override
  List<Object?> get props => [
        shipperID,
      ];
}
