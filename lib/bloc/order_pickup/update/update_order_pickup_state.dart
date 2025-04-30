abstract class UpdateOrderPickupState {}

class UpdateOrderPickupLoading extends UpdateOrderPickupState {}

class UpdateOrderPickupSuccess extends UpdateOrderPickupState {}

class UpdateOrderPickupFailure extends UpdateOrderPickupState {
  final String? errorText;
  UpdateOrderPickupFailure({this.errorText});
}
