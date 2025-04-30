part of 'get_shipper_list_bloc.dart';

abstract class HandleGetListShipperFreeState extends Equatable {
  const HandleGetListShipperFreeState();
  @override
  List<Object?> get props => [];
}

class HandleGetListShipperFreeInitial extends HandleGetListShipperFreeState {}

class HandleGetListShipperFreeLoading extends HandleGetListShipperFreeState {}

class HandleGetListShipperFreeSuccess extends HandleGetListShipperFreeState {
  final List<ShipperFreeItemData> data;
  final int page;
  final bool hasReachedMax;
  const HandleGetListShipperFreeSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  HandleGetListShipperFreeSuccess copyWith({
    List<ShipperFreeItemData>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return HandleGetListShipperFreeSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class HandleGetListShipperFreeFailure extends HandleGetListShipperFreeState {
  final String message;

  const HandleGetListShipperFreeFailure({required this.message});

  HandleGetListShipperFreeFailure copyWith({String? message}) {
    return HandleGetListShipperFreeFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
