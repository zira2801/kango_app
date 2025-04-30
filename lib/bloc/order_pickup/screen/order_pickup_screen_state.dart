part of 'order_pickup_screen_bloc.dart';

abstract class HandleGetListOrderPickupState extends Equatable {
  const HandleGetListOrderPickupState();
  @override
  List<Object?> get props => [];
}

class HandleGetListOrderPickupInitial extends HandleGetListOrderPickupState {}

class HandleGetListOrderPickupLoading extends HandleGetListOrderPickupState {}

class HandleGetListOrderPickupSuccess extends HandleGetListOrderPickupState {
  final List<OrdersPickupItemData> data;
  final int page;
  final bool hasReachedMax;
  final bool isEdit;
  const HandleGetListOrderPickupSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
    required this.isEdit,
  });
  HandleGetListOrderPickupSuccess copyWith({
    List<OrdersPickupItemData>? data,
    int? page,
    bool? hasReachedMax,
    bool? isEdit,
  }) {
    return HandleGetListOrderPickupSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isEdit: isEdit ?? this.isEdit,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class HandleGetListOrderPickupFailure extends HandleGetListOrderPickupState {
  final String message;

  const HandleGetListOrderPickupFailure({required this.message});

  HandleGetListOrderPickupFailure copyWith({String? message}) {
    return HandleGetListOrderPickupFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class HandleDeleteOrderPickUpLoading extends HandleGetListOrderPickupState {}

class HandleDeleteOrderPickUpSuccess extends HandleGetListOrderPickupState {
  final String message;
  const HandleDeleteOrderPickUpSuccess({required this.message});

  HandleDeleteOrderPickUpSuccess copyWith({String? message}) {
    return HandleDeleteOrderPickUpSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class HandleDeleteOrderPickUpFailure extends HandleGetListOrderPickupState {
  final String message;

  const HandleDeleteOrderPickUpFailure({required this.message});

  HandleDeleteOrderPickUpFailure copyWith({String? message}) {
    return HandleDeleteOrderPickUpFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
