part of 'tracking_order_pickup_bloc.dart';

abstract class TrackingOrderPickupState extends Equatable {
  const TrackingOrderPickupState();
  @override
  List<Object?> get props => [];
}

class TrackingOrderPickupLoading extends TrackingOrderPickupState {}

class TrackingOrderPickupSuccess extends TrackingOrderPickupState {}

class TrackingOrderPickupFailure extends TrackingOrderPickupState {
  final String message;
  const TrackingOrderPickupFailure({required this.message});
  TrackingOrderPickupFailure copyWith({String? message}) {
    return TrackingOrderPickupFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
