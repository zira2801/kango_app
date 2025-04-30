part of 'get_fwd_list_bloc.dart';

abstract class HandleGetListFWDState extends Equatable {
  const HandleGetListFWDState();
  @override
  List<Object?> get props => [];
}

class HandleGetListFWDInitial extends HandleGetListFWDState {}

class HandleGetListFWDLoading extends HandleGetListFWDState {}

class HandleGetListFWDSuccess extends HandleGetListFWDState {
  final List<FWdItemData> data;
  final int page;
  final bool hasReachedMax;
  const HandleGetListFWDSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  HandleGetListFWDSuccess copyWith({
    List<FWdItemData>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return HandleGetListFWDSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class HandleGetListFWDFailure extends HandleGetListFWDState {
  final String message;

  const HandleGetListFWDFailure({required this.message});

  HandleGetListFWDFailure copyWith({String? message}) {
    return HandleGetListFWDFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
