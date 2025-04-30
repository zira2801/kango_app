part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationStateInitial extends NotificationState {}

class NotificationStateloading extends NotificationState {}

class NotificationStateSuccess extends NotificationState {
  final List<NotificationItem> data;
  final int page;
  final bool hasReachedMax;
  const NotificationStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  NotificationStateSuccess copyWith({
    List<NotificationItem>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return NotificationStateSuccess(
        data: data ?? this.data,
        page: page ?? this.page,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class NotificationStateFailure extends NotificationState {
  final String message;

  const NotificationStateFailure({required this.message});

  NotificationStateFailure copyWith({String? message}) {
    return NotificationStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class GetDetailsNotificationState extends Equatable {
  const GetDetailsNotificationState();
  @override
  List<Object?> get props => [];
}

class HandleGetDetailsNotificationStateInitial
    extends GetDetailsNotificationState {}

class HandleGetDetailsNotificationLoading extends GetDetailsNotificationState {}

class HandleGetDetailsNotificationSuccess extends GetDetailsNotificationState {
  final NotificationModel data;
  const HandleGetDetailsNotificationSuccess({required this.data});
  HandleGetDetailsNotificationSuccess copyWith({
    NotificationModel? data,
  }) {
    return HandleGetDetailsNotificationSuccess(
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [data];
}

class HandleGetDetailsNotificationFailure extends GetDetailsNotificationState {
  final String message;

  const HandleGetDetailsNotificationFailure({required this.message});

  HandleGetDetailsNotificationFailure copyWith({String? message}) {
    return HandleGetDetailsNotificationFailure(
        message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class CreateNotificationtState extends Equatable {
  const CreateNotificationtState();
  @override
  List<Object?> get props => [];
}

class CreateNotificationStateInitial extends CreateNotificationtState {}

class CreateNotificationStateLoading extends CreateNotificationtState {}

class CreateNotificationStateSuccess extends CreateNotificationtState {
  final String message;

  const CreateNotificationStateSuccess({required this.message});

  CreateNotificationStateSuccess copyWith({String? message}) {
    return CreateNotificationStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class CreateNotificationStateFailure extends CreateNotificationtState {
  final String message;

  const CreateNotificationStateFailure({required this.message});

  CreateNotificationStateFailure copyWith({String? message}) {
    return CreateNotificationStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class UpdateNotificationtState extends Equatable {
  const UpdateNotificationtState();
  @override
  List<Object?> get props => [];
}

class UpdateNotificationtStateInitial extends UpdateNotificationtState {}

class UpdateNotificationtStateLoading extends UpdateNotificationtState {}

class UpdateNotificationtStateSuccess extends UpdateNotificationtState {
  final String message;

  const UpdateNotificationtStateSuccess({required this.message});

  UpdateNotificationtStateSuccess copyWith({String? message}) {
    return UpdateNotificationtStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class UpdateNotificationStateFailure extends UpdateNotificationtState {
  final String message;

  const UpdateNotificationStateFailure({required this.message});

  UpdateNotificationStateFailure copyWith({String? message}) {
    return UpdateNotificationStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class DeleteNotificationtState extends Equatable {
  const DeleteNotificationtState();
  @override
  List<Object?> get props => [];
}

class DeleteNotificationtStateInitial extends DeleteNotificationtState {}

class DeleteNotificationtStateLoading extends DeleteNotificationtState {}

class DeleteNotificationtStateSuccess extends DeleteNotificationtState {
  final String message;

  const DeleteNotificationtStateSuccess({required this.message});

  DeleteNotificationtStateSuccess copyWith({String? message}) {
    return DeleteNotificationtStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class DeleteNotificationtStateFailure extends DeleteNotificationtState {
  final String message;

  const DeleteNotificationtStateFailure({required this.message});

  DeleteNotificationtStateFailure copyWith({String? message}) {
    return DeleteNotificationtStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
