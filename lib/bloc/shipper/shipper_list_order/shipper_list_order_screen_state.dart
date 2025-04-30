part of 'shipper_list_order_screen_bloc.dart';

abstract class HandleGetShipperListOrderScreenState extends Equatable {
  const HandleGetShipperListOrderScreenState();
  @override
  List<Object?> get props => [];
}

class HandleGetShipperListOrderScreenInitial
    extends HandleGetShipperListOrderScreenState {}

class HandleGetShipperListOrderScreenLoading
    extends HandleGetShipperListOrderScreenState {}

class HandleGetShipperListOrderScreenSuccess
    extends HandleGetShipperListOrderScreenState {
  final List<OrdersPickupShipperItemData> data;
  final int page;
  final bool hasReachedMax;
  final bool isEdit;
  const HandleGetShipperListOrderScreenSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
    required this.isEdit,
  });
  HandleGetShipperListOrderScreenSuccess copyWith({
    List<OrdersPickupShipperItemData>? data,
    int? page,
    bool? hasReachedMax,
    bool? isEdit,
  }) {
    return HandleGetShipperListOrderScreenSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isEdit: isEdit ?? this.isEdit,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class HandleGetShipperListOrderScreenFailure
    extends HandleGetShipperListOrderScreenState {
  final String message;

  const HandleGetShipperListOrderScreenFailure({required this.message});

  HandleGetShipperListOrderScreenFailure copyWith({String? message}) {
    return HandleGetShipperListOrderScreenFailure(
        message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
