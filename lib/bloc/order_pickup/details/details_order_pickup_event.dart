part of 'details_order_pickup_bloc.dart';

abstract class DetailsOrderPickupEvent extends Equatable {
  const DetailsOrderPickupEvent();

  @override
  List<Object?> get props => [];
}

class HanldeGetDetailsOrderPickup extends DetailsOrderPickupEvent {
  final int orderPickupID;
  HanldeGetDetailsOrderPickup({
    required this.orderPickupID,
  });
  @override
  List<Object?> get props => [orderPickupID];
}
