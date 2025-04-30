part of 'details_order_pickup_bottom_modal_bloc.dart';

abstract class DetailsOrderPickupModalBottomEvent extends Equatable {
  const DetailsOrderPickupModalBottomEvent();

  @override
  List<Object?> get props => [];
}

class HanldeGetDetailsOrderPickupModalBottom
    extends DetailsOrderPickupModalBottomEvent {
  final int orderPickupID;
  HanldeGetDetailsOrderPickupModalBottom({
    required this.orderPickupID,
  });
  @override
  List<Object?> get props => [orderPickupID];
}
