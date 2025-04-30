part of 'get_shipper_list_bloc.dart';

abstract class ShipperFreeScreenEvent extends Equatable {
  const ShipperFreeScreenEvent();

  @override
  List<Object?> get props => [];
}

class FetchListShipperFree extends ShipperFreeScreenEvent {
  final String? keywords;

  const FetchListShipperFree({
    required this.keywords,
  });
  @override
  List<Object?> get props => [keywords];
}

class LoadMoreListShipperFree extends ShipperFreeScreenEvent {
  final String? keywords;

  const LoadMoreListShipperFree({
    required this.keywords,
  });
  @override
  List<Object?> get props => [keywords];
}
