part of 'list_shipment_bloc.dart';

abstract class ListShipmentState extends Equatable {
  const ListShipmentState();
  @override
  List<Object?> get props => [];
}

class ListShipmentStateInitial extends ListShipmentState {}

class ListShipmentStateLoading extends ListShipmentState {}

class ListShipmentStateSuccess extends ListShipmentState {
  final List<ShipmentItemData> data;
  final int page;
  final bool hasReachedMax;
  const ListShipmentStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  ListShipmentStateSuccess copyWith({
    List<ShipmentItemData>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return ListShipmentStateSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class ListShipmentStateFailure extends ListShipmentState {
  final String message;

  const ListShipmentStateFailure({required this.message});

  ListShipmentStateFailure copyWith({String? message}) {
    return ListShipmentStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class DeleteShipmentState extends Equatable {
  const DeleteShipmentState();
  @override
  List<Object?> get props => [];
}

class DeleteShipmentStateInitial extends DeleteShipmentState {}

class DeleteShipmentStateLoading extends DeleteShipmentState {}

class DeleteShipmentStateSuccess extends DeleteShipmentState {
  final String message;
  const DeleteShipmentStateSuccess({
    required this.message,
  });
  DeleteShipmentStateSuccess copyWith({String? message}) {
    return DeleteShipmentStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class DeleteShipmentStateFailure extends DeleteShipmentState {
  final String message;

  const DeleteShipmentStateFailure({required this.message});

  DeleteShipmentStateFailure copyWith({String? message}) {
    return DeleteShipmentStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class DetailsShipmentState extends Equatable {
  const DetailsShipmentState();
  @override
  List<Object?> get props => [];
}

class DetailsShipmentStateInitial extends DetailsShipmentState {}

class DetailsShipmentStateLoading extends DetailsShipmentState {}

class DetailsShipmentStateSuccess extends DetailsShipmentState {
  final DetailsShipmentModel detailsShipmentModel;
  final bool isMoreDetail; // Thêm biến này để xác định loại dialog

  const DetailsShipmentStateSuccess({
    required this.detailsShipmentModel,
    required this.isMoreDetail, // Bắt buộc truyền vào
  });

  DetailsShipmentStateSuccess copyWith({
    DetailsShipmentModel? detailsShipmentModel,
    bool? isMoreDetail,
  }) {
    return DetailsShipmentStateSuccess(
      detailsShipmentModel: detailsShipmentModel ?? this.detailsShipmentModel,
      isMoreDetail: isMoreDetail ?? this.isMoreDetail, // Copy lại giá trị
    );
  }

  @override
  List<Object?> get props => [detailsShipmentModel, isMoreDetail];
}

class DetailsShipmentStateFailure extends DetailsShipmentState {
  final String message;

  const DetailsShipmentStateFailure({required this.message});

  DetailsShipmentStateFailure copyWith({String? message}) {
    return DetailsShipmentStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
