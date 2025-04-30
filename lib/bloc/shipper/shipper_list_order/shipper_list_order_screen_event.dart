part of 'shipper_list_order_screen_bloc.dart';

abstract class ShipperListOrderScreenEvent extends Equatable {
  const ShipperListOrderScreenEvent();

  @override
  List<Object?> get props => [];
}

class FetchListOrderPickupShipper extends ShipperListOrderScreenEvent {
  final int? status;
  final String? startDate;
  final String? endDate;
  final int? branchId;
  final String? keywords;
  final int? pickupShipStatus;
  final int? shipperId;

  const FetchListOrderPickupShipper({
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.branchId,
    required this.keywords,
    required this.pickupShipStatus,
    required this.shipperId,
  });
  @override
  List<Object?> get props => [
        status,
        startDate,
        endDate,
        branchId,
        keywords,
        pickupShipStatus,
        shipperId,
      ];
}

class LoadMoreListOrderPickupShipper extends ShipperListOrderScreenEvent {
  final int? status;
  final String? startDate;
  final String? endDate;
  final int? branchId;
  final String? keywords;
  final int? pickupShipStatus;
  final int? shipperId;

  const LoadMoreListOrderPickupShipper({
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.branchId,
    required this.keywords,
    required this.pickupShipStatus,
    required this.shipperId,
  });
  @override
  List<Object?> get props => [
        status,
        startDate,
        endDate,
        branchId,
        keywords,
        pickupShipStatus,
        shipperId,
      ];
}
