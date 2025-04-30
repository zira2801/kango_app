part of 'transfer_bloc.dart';

abstract class GetListTransferState extends Equatable {
  const GetListTransferState();
  @override
  List<Object?> get props => [];
}

class GetListTransferStateInitial extends GetListTransferState {}

class GetListTransferStateloading extends GetListTransferState {}

class GetListTransferStateSuccess extends GetListTransferState {
  final List<Transfer> data;
  final int page;
  final bool hasReachedMax;
  const GetListTransferStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  GetListTransferStateSuccess copyWith({
    List<Transfer>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return GetListTransferStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class GetListTransferStateFailure extends GetListTransferState {
  final String message;

  const GetListTransferStateFailure({required this.message});

  GetListTransferStateFailure copyWith({String? message}) {
    return GetListTransferStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class ApproveTransfertState extends Equatable {
  const ApproveTransfertState();
  @override
  List<Object?> get props => [];
}

class ApproveTransfertStateInitial extends ApproveTransfertState {}

class ApproveTransfertStateLoading extends ApproveTransfertState {}

class ApproveTransfertStateSuccess extends ApproveTransfertState {
  final String message;

  const ApproveTransfertStateSuccess({required this.message});

  ApproveTransfertStateSuccess copyWith({String? message}) {
    return ApproveTransfertStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class ApproveTransfertStateFailure extends ApproveTransfertState {
  final String message;

  const ApproveTransfertStateFailure({required this.message});

  ApproveTransfertStateFailure copyWith({String? message}) {
    return ApproveTransfertStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class CreateTransfertState extends Equatable {
  const CreateTransfertState();
  @override
  List<Object?> get props => [];
}

class CreateTransfertStateInitial extends CreateTransfertState {}

class CreateTransfertStateLoading extends CreateTransfertState {}

class CreateTransfertStateSuccess extends CreateTransfertState {
  final String message;

  const CreateTransfertStateSuccess({required this.message});

  CreateTransfertStateSuccess copyWith({String? message}) {
    return CreateTransfertStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class CreateTransfertStateFailure extends CreateTransfertState {
  final String message;

  const CreateTransfertStateFailure({required this.message});

  CreateTransfertStateFailure copyWith({String? message}) {
    return CreateTransfertStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

// abstract class UpdateNotificationtState extends Equatable {
//   const UpdateNotificationtState();
//   @override
//   List<Object?> get props => [];
// }

// class UpdateNotificationtStateInitial extends UpdateNotificationtState {}

// class UpdateNotificationtStateLoading extends UpdateNotificationtState {}

// class UpdateNotificationtStateSuccess extends UpdateNotificationtState {
//   final String message;

//   const UpdateNotificationtStateSuccess({required this.message});

//   UpdateNotificationtStateSuccess copyWith({String? message}) {
//     return UpdateNotificationtStateSuccess(message: message ?? this.message);
//   }

//   @override
//   List<Object?> get props => [message];
// }

// class UpdateNotificationStateFailure extends UpdateNotificationtState {
//   final String message;

//   const UpdateNotificationStateFailure({required this.message});

//   UpdateNotificationStateFailure copyWith({String? message}) {
//     return UpdateNotificationStateFailure(message: message ?? this.message);
//   }

//   @override
//   List<Object?> get props => [message];
// }

abstract class DeleteTransferState extends Equatable {
  const DeleteTransferState();
  @override
  List<Object?> get props => [];
}

class DeleteTransferStateInitial extends DeleteTransferState {}

class DeleteTransferStateLoading extends DeleteTransferState {}

class DeleteTransferStateSuccess extends DeleteTransferState {
  final String message;

  const DeleteTransferStateSuccess({required this.message});

  DeleteTransferStateSuccess copyWith({String? message}) {
    return DeleteTransferStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class DeleteTransferStateFailure extends DeleteTransferState {
  final String message;

  const DeleteTransferStateFailure({required this.message});

  DeleteTransferStateFailure copyWith({String? message}) {
    return DeleteTransferStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
