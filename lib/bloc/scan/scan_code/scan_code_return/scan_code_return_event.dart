part of 'scan_code_return_bloc.dart';

abstract class ScanCodeReturnEvent extends Equatable {
  const ScanCodeReturnEvent();

  @override
  List<Object?> get props => [];
}

class HanldeScanCodeReturn extends ScanCodeReturnEvent {
  final String code;
  const HanldeScanCodeReturn({required this.code});
  @override
  List<Object?> get props => [code];
}
