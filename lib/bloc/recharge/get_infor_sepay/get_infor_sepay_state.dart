part of 'get_infor_sepay_bloc.dart';

abstract class GetInforSePayState extends Equatable {
  const GetInforSePayState();
  @override
  List<Object?> get props => [];
}

class GetInforSePayStateLoading extends GetInforSePayState {}

class GetInforSePayStateSuccess extends GetInforSePayState {
  final GetDataDetailsSePayModel? getDataDetailsSePayModel;

  const GetInforSePayStateSuccess({this.getDataDetailsSePayModel});

  GetInforSePayStateSuccess copyWith(
      {GetDataDetailsSePayModel? getDataDetailsSePayModel}) {
    return GetInforSePayStateSuccess(
        getDataDetailsSePayModel:
            getDataDetailsSePayModel ?? this.getDataDetailsSePayModel);
  }

  @override
  List<Object?> get props => [getDataDetailsSePayModel];
}

class GetInforSePayStateFailure extends GetInforSePayState {
  final String message;

  const GetInforSePayStateFailure({required this.message});

  GetInforSePayStateFailure copyWith({String? message}) {
    return GetInforSePayStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
