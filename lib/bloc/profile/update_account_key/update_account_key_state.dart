part of 'update_account_key_bloc.dart';

abstract class UpdateAccountKeyState extends Equatable {
  const UpdateAccountKeyState();
  @override
  List<Object?> get props => [];
}

class HandleUpdateAccountKeyStateInitial extends UpdateAccountKeyState {}

class HandleUpdateAccountKeyStateLoading extends UpdateAccountKeyState {}

class HandleUpdateAccountKeyStateSuccess extends UpdateAccountKeyState {
  final String message;

  const HandleUpdateAccountKeyStateSuccess({required this.message});

  HandleUpdateAccountKeyStateSuccess copyWith({String? message}) {
    return HandleUpdateAccountKeyStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class HandleUpdateAccountKeyStateFailure extends UpdateAccountKeyState {
  final String message;

  const HandleUpdateAccountKeyStateFailure({required this.message});

  HandleUpdateAccountKeyStateFailure copyWith({String? message}) {
    return HandleUpdateAccountKeyStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
