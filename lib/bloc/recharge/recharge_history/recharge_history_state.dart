part of 'recharge_history_bloc.dart';

abstract class ReChargeHistoryState extends Equatable {
  const ReChargeHistoryState();
  @override
  List<Object?> get props => [];
}

class HandleGetListReChargeStateInitial extends ReChargeHistoryState {}

class HandleGetListReChargeStateLoading extends ReChargeHistoryState {}

class HandleGetListReChargeStateSuccess extends ReChargeHistoryState {
  final List<ItemRechargeModel> data;
  final int page;
  final bool hasReachedMax;
  const HandleGetListReChargeStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  HandleGetListReChargeStateSuccess copyWith({
    List<ItemRechargeModel>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return HandleGetListReChargeStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class HandleGetListReChargeStateFailure extends ReChargeHistoryState {
  final String message;

  const HandleGetListReChargeStateFailure({required this.message});

  HandleGetListReChargeStateFailure copyWith({String? message}) {
    return HandleGetListReChargeStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class GetDetailsReChargeHistoryState extends Equatable {
  const GetDetailsReChargeHistoryState();
  @override
  List<Object?> get props => [];
}

class HandleGetDetailsReChargeStateInitial
    extends GetDetailsReChargeHistoryState {}

class HandleGetDetailsReChargeLoading extends GetDetailsReChargeHistoryState {}

class HandleGetDetailsReChargeSuccess extends GetDetailsReChargeHistoryState {
  final DetailsDataRechargeModel data;
  const HandleGetDetailsReChargeSuccess({required this.data});
  HandleGetDetailsReChargeSuccess copyWith({
    DetailsDataRechargeModel? data,
  }) {
    return HandleGetDetailsReChargeSuccess(
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [data];
}

class HandleGetDetailsReChargeFailure extends GetDetailsReChargeHistoryState {
  final String message;

  const HandleGetDetailsReChargeFailure({required this.message});

  HandleGetDetailsReChargeFailure copyWith({String? message}) {
    return HandleGetDetailsReChargeFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
