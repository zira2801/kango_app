import 'package:equatable/equatable.dart';

abstract class MapState2 extends Equatable {
  @override
  List<Object> get props => [];
}

class MapInitial extends MapState2 {}

class MapLoading extends MapState2 {}

class MapLoadSuccess extends MapState2 {
  final List<dynamic> predictions;

  MapLoadSuccess(this.predictions);

  @override
  List<Object> get props => [predictions];
}

class MapLoadFailure extends MapState2 {
  final String error;

  MapLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}

class PlaceSelected extends MapState2 {
  final double latitude;
  final double longitude;
  final String description;

  PlaceSelected(this.latitude, this.longitude, this.description);
}

class LocationDetailsFetched extends MapState2 {
  final String address;

  LocationDetailsFetched(this.address);

  @override
  List<Object> get props => [address];
}
