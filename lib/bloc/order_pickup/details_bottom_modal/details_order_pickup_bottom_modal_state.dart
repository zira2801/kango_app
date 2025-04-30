part of 'details_order_pickup_bottom_modal_bloc.dart';

abstract class DetailsOrderPickupModalBottomState extends Equatable {
  const DetailsOrderPickupModalBottomState();
  @override
  List<Object?> get props => [];
}

class HanldeGetDetailsOrderPickupModalBottomLoading
    extends DetailsOrderPickupModalBottomState {}

class HanldeGetDetailsOrderPickupModalBottomSuccess
    extends DetailsOrderPickupModalBottomState {
  final DetailsOrderPickUpModel detailsOrderPickUpModel;
  const HanldeGetDetailsOrderPickupModalBottomSuccess(
      {required this.detailsOrderPickUpModel});

  HanldeGetDetailsOrderPickupModalBottomSuccess copyWith(
      {DetailsOrderPickUpModel? detailsOrderPickUpModel}) {
    return HanldeGetDetailsOrderPickupModalBottomSuccess(
        detailsOrderPickUpModel:
            detailsOrderPickUpModel ?? this.detailsOrderPickUpModel);
  }

  @override
  List<Object?> get props => [detailsOrderPickUpModel];
}

class HanldeGetDetailsOrderPickupModalBottomFailure
    extends DetailsOrderPickupModalBottomState {
  final String message;
  const HanldeGetDetailsOrderPickupModalBottomFailure({required this.message});
  HanldeGetDetailsOrderPickupModalBottomFailure copyWith({String? message}) {
    return HanldeGetDetailsOrderPickupModalBottomFailure(
        message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
