part of 'debit_bloc.dart';

abstract class HandleGetDebitState extends Equatable {
  const HandleGetDebitState();
  @override
  List<Object?> get props => [];
}

class HandleGetDebitStateInitial extends HandleGetDebitState {}

class HandleGetDebitStateloading extends HandleGetDebitState {}

class HandleGetDebitStateSuccess extends HandleGetDebitState {
  final List<Debit> data;
  final int page;
  final bool hasReachedMax;
  const HandleGetDebitStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  HandleGetDebitStateSuccess copyWith({
    List<Debit>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return HandleGetDebitStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class HandleGetDebitStateFailure extends HandleGetDebitState {
  final String message;

  const HandleGetDebitStateFailure({required this.message});

  HandleGetDebitStateFailure copyWith({String? message}) {
    return HandleGetDebitStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class CheckAccountainCodeDebitState extends Equatable {
  const CheckAccountainCodeDebitState();
  @override
  List<Object?> get props => [];
}

class CheckAccountainCodeDebitInitial extends CheckAccountainCodeDebitState {}

class CheckAccountainCodeDebitloading extends CheckAccountainCodeDebitState {}

class CheckAccountainCodeDebitSuccess extends CheckAccountainCodeDebitState {
  final String message;
  const CheckAccountainCodeDebitSuccess({required this.message});
  CheckAccountainCodeDebitSuccess copyWith({String? message}) {
    return CheckAccountainCodeDebitSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class CheckAccountainCodeDebitFailure extends CheckAccountainCodeDebitState {
  final String message;

  const CheckAccountainCodeDebitFailure({required this.message});

  CheckAccountainCodeDebitFailure copyWith({String? message}) {
    return CheckAccountainCodeDebitFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class GetDetailDebitState extends Equatable {
  const GetDetailDebitState();
  @override
  List<Object?> get props => [];
}

class GetDetailDebitInitial extends GetDetailDebitState {}

class GetDetailDebitloading extends GetDetailDebitState {}

class GetDetailDebitSuccess extends GetDetailDebitState {
  final DebitDetailResponse debitDetailResponse;
  const GetDetailDebitSuccess({required this.debitDetailResponse});
  GetDetailDebitSuccess copyWith({DebitDetailResponse? debitDetailResponse}) {
    return GetDetailDebitSuccess(
        debitDetailResponse: debitDetailResponse ?? this.debitDetailResponse);
  }

  @override
  List<Object?> get props => [debitDetailResponse];
}

class GetDetailDebitFailure extends GetDetailDebitState {
  final String message;

  const GetDetailDebitFailure({required this.message});

  GetDetailDebitFailure copyWith({String? message}) {
    return GetDetailDebitFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class GetListShipmentDebitStateInitial extends GetDetailDebitState {}

class GetListShipmentDebitStateloading extends GetDetailDebitState {}

class GetListShipmentDebitStateSuccess extends GetDetailDebitState {
  final List<DebitShipment> data;
  final int page;
  final bool hasReachedMax;
  const GetListShipmentDebitStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  GetListShipmentDebitStateSuccess copyWith({
    List<DebitShipment>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return GetListShipmentDebitStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class GetListShipmentDebitStateFailure extends GetDetailDebitState {
  final String message;

  const GetListShipmentDebitStateFailure({required this.message});

  GetListShipmentDebitStateFailure copyWith({String? message}) {
    return GetListShipmentDebitStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class PaymentDebitState extends Equatable {
  const PaymentDebitState();
  @override
  List<Object?> get props => [];
}

class PaymentDebitStateInitial extends PaymentDebitState {}

class PaymentDebitStateloading extends PaymentDebitState {}

class PaymentDebitStateSuccess extends PaymentDebitState {
  final String message;
  const PaymentDebitStateSuccess({required this.message});
  PaymentDebitStateSuccess copyWith({String? message}) {
    return PaymentDebitStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class PaymentDebitStateFailure extends PaymentDebitState {
  final String message;

  const PaymentDebitStateFailure({required this.message});

  PaymentDebitStateFailure copyWith({String? message}) {
    return PaymentDebitStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
