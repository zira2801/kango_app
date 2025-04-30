part of 'wallet_fluctuations_bloc.dart';

abstract class HandleGetWalletFluctuationState extends Equatable {
  const HandleGetWalletFluctuationState();
  @override
  List<Object?> get props => [];
}

class HandleGetWalletFluctuationStateInitial
    extends HandleGetWalletFluctuationState {}

class HandleGetWalletFluctuationStateloading
    extends HandleGetWalletFluctuationState {}

class HandleGetWalletFluctuationStateSuccess
    extends HandleGetWalletFluctuationState {
  final List<WalletFluctuation> data;
  final int page;
  final bool hasReachedMax;
  const HandleGetWalletFluctuationStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  HandleGetWalletFluctuationStateSuccess copyWith({
    List<WalletFluctuation>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return HandleGetWalletFluctuationStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class HandleGetWalletFluctuationStateFailure
    extends HandleGetWalletFluctuationState {
  final String message;

  const HandleGetWalletFluctuationStateFailure({required this.message});

  HandleGetWalletFluctuationStateFailure copyWith({String? message}) {
    return HandleGetWalletFluctuationStateFailure(
        message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
