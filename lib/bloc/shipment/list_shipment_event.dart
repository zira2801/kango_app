part of 'list_shipment_bloc.dart';

abstract class ListShipmentEvent extends Equatable {
  const ListShipmentEvent();

  @override
  List<Object?> get props => [];
}

class FetchListShipment extends ListShipmentEvent {
  final String? keywords;
  final String? startDate;
  final String? endDate;
  final int? shipmentServiceId;
  final int? branchId;
  final String searchMethod;
  final int? status;
  final int? statusPayment;
  const FetchListShipment({
    required this.status,
    required this.statusPayment,
    required this.startDate,
    required this.shipmentServiceId,
    required this.endDate,
    required this.branchId,
    required this.keywords,
    required this.searchMethod,
  });
  @override
  List<Object?> get props => [
        keywords,
        startDate,
        endDate,
        shipmentServiceId,
        branchId,
        status,
        searchMethod,
        statusPayment
      ];
}

class LoadMoreListShipment extends ListShipmentEvent {
  final String? keywords;
  final String? startDate;
  final String? endDate;
  final int? branchId;
  final String searchMethod;
  final int? status;
  final int? statusPayment;
  const LoadMoreListShipment({
    required this.status,
    required this.statusPayment,
    required this.startDate,
    required this.endDate,
    required this.branchId,
    required this.keywords,
    required this.searchMethod,
  });
  @override
  List<Object?> get props => [
        keywords,
        startDate,
        endDate,
        branchId,
        status,
        searchMethod,
        statusPayment
      ];
}

abstract class DeleteShipmentEvent extends Equatable {
  const DeleteShipmentEvent();

  @override
  List<Object?> get props => [];
}

class HanldeDeleteShipment extends DeleteShipmentEvent {
  final String? shipmentCode;
  const HanldeDeleteShipment({required this.shipmentCode});
  @override
  List<Object?> get props => [shipmentCode];
}

abstract class DetailsShipmentEvent extends Equatable {
  const DetailsShipmentEvent();

  @override
  List<Object?> get props => [];
}

class HanldeDetailsShipment extends DetailsShipmentEvent {
  final String? shipmentCode;
  final bool? isMoreDetail; // Thêm biến này để phân biệt loại dialog

  const HanldeDetailsShipment({required this.shipmentCode, this.isMoreDetail});

  @override
  List<Object?> get props => [shipmentCode];
}
