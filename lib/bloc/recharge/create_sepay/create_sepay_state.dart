part of 'create_sepay_bloc.dart';

abstract class CreateSePayState extends Equatable {
  const CreateSePayState();
  @override
  List<Object?> get props => [];
}

class CreateSePayStateLoading extends CreateSePayState {}

class CreateSePayStateSuccess extends CreateSePayState {
  final InforPaymentSePayModel? inforPaymentSePayModel;

  const CreateSePayStateSuccess({this.inforPaymentSePayModel});

  CreateSePayStateSuccess copyWith(
      {InforPaymentSePayModel? inforPaymentSePayModel}) {
    return CreateSePayStateSuccess(
        inforPaymentSePayModel:
            inforPaymentSePayModel ?? this.inforPaymentSePayModel);
  }

  @override
  List<Object?> get props => [inforPaymentSePayModel];
}

class CreateSePayStateFailure extends CreateSePayState {
  final String message;

  const CreateSePayStateFailure({required this.message});

  CreateSePayStateFailure copyWith({String? message}) {
    return CreateSePayStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
