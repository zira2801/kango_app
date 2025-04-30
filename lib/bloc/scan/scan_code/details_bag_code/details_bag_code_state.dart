part of 'details_bag_code_bloc.dart';

abstract class DetailsBagCodeState extends Equatable {
  const DetailsBagCodeState();
  @override
  List<Object?> get props => [];
}

class DetailsBagCodeStateInitial extends DetailsBagCodeState {}

class DetailsBagCodeStateLoading extends DetailsBagCodeState {}

class DetailsBagCodeStateSuccess extends DetailsBagCodeState {
  final ScanDetailsBagCodeModel scanDetailsBagCodeModel;

  const DetailsBagCodeStateSuccess({required this.scanDetailsBagCodeModel});

  DetailsBagCodeStateSuccess copyWith(
      {ScanDetailsBagCodeModel? scanDetailsBagCodeModel}) {
    return DetailsBagCodeStateSuccess(
        scanDetailsBagCodeModel:
            scanDetailsBagCodeModel ?? this.scanDetailsBagCodeModel);
  }

  @override
  List<Object?> get props => [scanDetailsBagCodeModel];
}

class DetailsBagCodeStateFailure extends DetailsBagCodeState {
  final String message;

  const DetailsBagCodeStateFailure({required this.message});

  DetailsBagCodeStateFailure copyWith({String? message}) {
    return DetailsBagCodeStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
