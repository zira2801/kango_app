part of 'scan_code_transit_bloc.dart';

abstract class InTransitScanState extends Equatable {
  const InTransitScanState();

  @override
  List<Object> get props => [];
}

class InTransitScanStateInitial extends InTransitScanState {}

class InTransitScanStateLoading extends InTransitScanState {}

class InTransitScanStateSuccess extends InTransitScanState {
  final String message;

  const InTransitScanStateSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class InTransitScanStateFailure extends InTransitScanState {
  final String message;

  const InTransitScanStateFailure({required this.message});

  @override
  List<Object> get props => [message];
}
/*
class GetDetailsPackageStateLoading extends InTransitScanState {}

class GetDetailsPackageStateSuccess extends InTransitScanState {
  final DetailsPackageScanCodeModel detailsPackageScanCodeModel;

  const GetDetailsPackageStateSuccess(
      {required this.detailsPackageScanCodeModel});

  @override
  List<Object> get props => [detailsPackageScanCodeModel];
}

class GetDetailsPackageStateFailure extends InTransitScanState {
  final String message;

  const GetDetailsPackageStateFailure({required this.message});

  @override
  List<Object> get props => [message];
}
*/
