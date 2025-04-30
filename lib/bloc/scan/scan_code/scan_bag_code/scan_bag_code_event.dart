part of 'scan_bag_code_bloc.dart';

abstract class ScanBagCodeEvent extends Equatable {
  const ScanBagCodeEvent();

  @override
  List<Object?> get props => [];
}

class HanldeScanBagCode extends ScanBagCodeEvent {
  final String bagCode;
  final int smTracktryID;
  const HanldeScanBagCode({
    required this.bagCode,
    required this.smTracktryID,
  });
  @override
  List<Object?> get props => [bagCode, smTracktryID];
}
