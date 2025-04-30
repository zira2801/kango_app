part of 'details_tracking_shipment_bloc.dart';

abstract class DetailsTrackingShipmentState extends Equatable {
  const DetailsTrackingShipmentState();
  @override
  List<Object?> get props => [];
}

class DetailsTrackingShipmentStateInitial
    extends DetailsTrackingShipmentState {}

class DetailsTrackingShipmentStateLoading
    extends DetailsTrackingShipmentState {}

class DetailsTrackingShipmentStateSuccess extends DetailsTrackingShipmentState {
  final DetailsTrackingModel data;
  DetailsTrackingShipmentStateSuccess({
    required this.data,
  });
  DetailsTrackingShipmentStateSuccess copyWith({
    DetailsTrackingModel? data,
  }) {
    return DetailsTrackingShipmentStateSuccess(
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [data];
}

class DetailsTrackingShipmentStateFailure
    extends DetailsTrackingShipmentStateLoading {
  final String message;

  DetailsTrackingShipmentStateFailure({required this.message});

  DetailsTrackingShipmentStateFailure copyWith({String? message}) {
    return DetailsTrackingShipmentStateFailure(
        message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class GetDeliveryServiceState extends Equatable {
  const GetDeliveryServiceState();
  @override
  List<Object?> get props => [];
}
