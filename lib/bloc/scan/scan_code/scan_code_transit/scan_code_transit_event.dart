part of 'scan_code_transit_bloc.dart';

abstract class InTransitScanEvent extends Equatable {
  const InTransitScanEvent();

  @override
  List<Object> get props => [];
}

class PerformInTransitScanEvent extends InTransitScanEvent {
  final String code;
  final int smTracktryID;
  final String bagCode;

  const PerformInTransitScanEvent({
    required this.code,
    required this.bagCode,
    required this.smTracktryID,
  });

  @override
  List<Object> get props => [code, bagCode, smTracktryID];
}
/*
class GetDetailsPackage extends InTransitScanEvent {
  final String mawbCode;
  final int status;
  const GetDetailsPackage({required this.mawbCode, required this.status});

  @override
  List<Object> get props => [mawbCode];
}*/
