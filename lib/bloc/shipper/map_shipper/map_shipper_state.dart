part of 'map_shipper_bloc.dart';

abstract class MapShipperState extends Equatable {
  const MapShipperState();
  @override
  List<Object?> get props => [];
}

class MapShipperStateInitial extends MapShipperState {}

class MapShipperStateLoading extends MapShipperState {}

class MapShipperStateSuccess extends MapShipperState {}

class MapShipperStateFailure extends MapShipperState {}
