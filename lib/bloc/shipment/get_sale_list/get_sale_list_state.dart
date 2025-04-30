part of 'get_sale_list_bloc.dart';

abstract class HandleGetListSaleState extends Equatable {
  const HandleGetListSaleState();
  @override
  List<Object?> get props => [];
}

class HandleGetListSaleInitial extends HandleGetListSaleState {}

class HandleGetListSaleLoading extends HandleGetListSaleState {}

class HandleGetListSaleSuccess extends HandleGetListSaleState {
  final List<SaleItemData> data;
  final int page;
  final bool hasReachedMax;
  const HandleGetListSaleSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  HandleGetListSaleSuccess copyWith({
    List<SaleItemData>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return HandleGetListSaleSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class HandleGetListSaleFailure extends HandleGetListSaleState {
  final String message;

  const HandleGetListSaleFailure({required this.message});

  HandleGetListSaleFailure copyWith({String? message}) {
    return HandleGetListSaleFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
