part of 'scan_code_return_bloc.dart';

abstract class ScanCodeReturnState extends Equatable {
  const ScanCodeReturnState();
  @override
  List<Object?> get props => [];
}

class ScanCodeReturnStateInitial extends ScanCodeReturnState {}

class ScanCodeReturnStateLoading extends ScanCodeReturnState {}

class ScanCodeReturnStateSuccess extends ScanCodeReturnState {
  final String message;

  const ScanCodeReturnStateSuccess({required this.message});

  ScanCodeReturnStateSuccess copyWith({String? message}) {
    return ScanCodeReturnStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class ScanCodeReturnStateFailure extends ScanCodeReturnState {
  final String message;

  const ScanCodeReturnStateFailure({required this.message});

  ScanCodeReturnStateFailure copyWith({String? message}) {
    return ScanCodeReturnStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
