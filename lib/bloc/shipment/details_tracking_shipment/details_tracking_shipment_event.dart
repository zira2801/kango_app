part of 'details_tracking_shipment_bloc.dart';

abstract class DetailsTrackingShipmentEvent extends Equatable {
  const DetailsTrackingShipmentEvent();

  @override
  List<Object?> get props => [];
}

class GetDetailsTrackingShipmentEvent extends DetailsTrackingShipmentEvent {
  final String packageHawbCode;
  const GetDetailsTrackingShipmentEvent({
    required this.packageHawbCode,
  });
  @override
  List<Object?> get props => [packageHawbCode];
}
