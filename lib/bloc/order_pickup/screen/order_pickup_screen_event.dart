part of 'order_pickup_screen_bloc.dart';

abstract class OrderPickupScreenEvent extends Equatable {
  const OrderPickupScreenEvent();

  @override
  List<Object?> get props => [];
}

class FetchListOrderPickup extends OrderPickupScreenEvent {
  final int? status;
  final String? startDate;
  final String? endDate;
  final int? branchId;
  final String? keywords;
  final int? fwdId;

  const FetchListOrderPickup({
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.branchId,
    required this.keywords,
    required this.fwdId,
  });
  @override
  List<Object?> get props =>
      [status, startDate, endDate, branchId, keywords, fwdId];
}

class LoadMoreListOrderPickup extends OrderPickupScreenEvent {
  final int? status;
  final String? startDate;
  final String? endDate;
  final int? branchId;
  final String? keywords;
  final int? fwdId;

  const LoadMoreListOrderPickup({
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.branchId,
    required this.keywords,
    required this.fwdId,
  });
  @override
  List<Object?> get props =>
      [status, startDate, endDate, branchId, keywords, fwdId];
}

class HandleUpdateOrderPickup extends OrderPickupScreenEvent {
  final int orderPickupID;
  final int status;
  const HandleUpdateOrderPickup({
    required this.orderPickupID,
    required this.status,
  });
}

class HandleDeleteOrderPickUp extends OrderPickupScreenEvent {
  final int orderPickupID;

  final String orderCancelDes;
  const HandleDeleteOrderPickUp({
    required this.orderPickupID,
    required this.orderCancelDes,
  });
}
