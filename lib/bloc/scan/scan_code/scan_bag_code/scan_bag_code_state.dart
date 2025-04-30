part of 'scan_bag_code_bloc.dart';

abstract class ScanBagCodeState extends Equatable {
  const ScanBagCodeState();
  @override
  List<Object?> get props => [];
}

class ScanBagCodeStateInitial extends ScanBagCodeState {}

class ScanBagCodeStateLoading extends ScanBagCodeState {}

class ScanBagCodeStateSuccess extends ScanBagCodeState {
  final ScanBagCodeModel? scanBagCodeModel;
  const ScanBagCodeStateSuccess({required this.scanBagCodeModel});

  ScanBagCodeStateSuccess copyWith({ScanBagCodeModel? scanBagCodeModel}) {
    return ScanBagCodeStateSuccess(
        scanBagCodeModel: scanBagCodeModel ?? this.scanBagCodeModel);
  }

  @override
  List<Object?> get props => [scanBagCodeModel];
}

class ScanBagCodeStateFailure extends ScanBagCodeState {
  final String message;

  const ScanBagCodeStateFailure({required this.message});

  ScanBagCodeStateFailure copyWith({String? message}) {
    return ScanBagCodeStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
