import 'package:equatable/equatable.dart';

abstract class MapEvent2 extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchLocation extends MapEvent2 {
  final String query;

  SearchLocation(this.query);

  @override
  List<Object> get props => [query];
}

class SelectPlace extends MapEvent2 {
  final String placeId;

  SelectPlace(this.placeId);

  @override
  List<Object> get props => [placeId];
}

class UpdateSelectedPosition extends MapEvent2 {
  final double latitude;
  final double longitude;
  final String description;

  UpdateSelectedPosition(this.latitude, this.longitude, this.description);

  @override
  List<Object> get props => [latitude, longitude, description];
}

class FetchLocationDetails extends MapEvent2 {
  final double latitude;
  final double longitude;

  FetchLocationDetails(this.latitude, this.longitude);

  @override
  List<Object> get props => [latitude, longitude];
}
