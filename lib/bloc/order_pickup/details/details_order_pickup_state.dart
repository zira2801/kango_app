part of 'details_order_pickup_bloc.dart';

abstract class DetailsOrderPickupState extends Equatable {
  const DetailsOrderPickupState();
  @override
  List<Object?> get props => [];
}

class HanldeGetDetailsOrderPickupLoading extends DetailsOrderPickupState {}

class HanldeGetDetailsOrderPickupSuccess extends DetailsOrderPickupState {
  final DetailsOrderPickUpModel detailsOrderPickUpModel;
  const HanldeGetDetailsOrderPickupSuccess(
      {required this.detailsOrderPickUpModel});

  HanldeGetDetailsOrderPickupSuccess copyWith(
      {DetailsOrderPickUpModel? detailsOrderPickUpModel}) {
    return HanldeGetDetailsOrderPickupSuccess(
        detailsOrderPickUpModel:
            detailsOrderPickUpModel ?? this.detailsOrderPickUpModel);
  }

  @override
  List<Object?> get props => [detailsOrderPickUpModel];
}

class HanldeGetDetailsOrderPickupFailure extends DetailsOrderPickupState {
  final String message;
  const HanldeGetDetailsOrderPickupFailure({required this.message});
  HanldeGetDetailsOrderPickupFailure copyWith({String? message}) {
    return HanldeGetDetailsOrderPickupFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
