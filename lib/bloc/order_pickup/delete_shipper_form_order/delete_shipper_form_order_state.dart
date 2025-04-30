part of 'delete_shipper_form_order_bloc.dart';

abstract class DeleteShipperFormOrderState extends Equatable {
  const DeleteShipperFormOrderState();
  @override
  List<Object?> get props => [];
}

class DeleteShipperFormOrderStateInitial extends DeleteShipperFormOrderState {}

class DeleteShipperFormOrderStateLoading extends DeleteShipperFormOrderState {}

class DeleteShipperFormOrderStateSuccess extends DeleteShipperFormOrderState {
  final String message;

  const DeleteShipperFormOrderStateSuccess({required this.message});

  DeleteShipperFormOrderStateSuccess copyWith({String? message}) {
    return DeleteShipperFormOrderStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class DeleteShipperFormOrderStateFailure extends DeleteShipperFormOrderState {
  final String message;

  const DeleteShipperFormOrderStateFailure({required this.message});

  DeleteShipperFormOrderStateFailure copyWith({String? message}) {
    return DeleteShipperFormOrderStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
