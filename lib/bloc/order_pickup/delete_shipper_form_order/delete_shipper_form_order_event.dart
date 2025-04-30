part of 'delete_shipper_form_order_bloc.dart';

abstract class DeleteShipperFormOrderEvent extends Equatable {
  const DeleteShipperFormOrderEvent();

  @override
  List<Object?> get props => [];
}

class HandleDeleteShipperFormOrder extends DeleteShipperFormOrderEvent {
  final int orderPickupID;
  const HandleDeleteShipperFormOrder({
    required this.orderPickupID,
  });
  @override
  List<Object?> get props => [orderPickupID];
}
