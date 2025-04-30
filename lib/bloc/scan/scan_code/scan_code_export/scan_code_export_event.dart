part of 'scan_code_export_bloc.dart';

abstract class ScanCodeExportEvent extends Equatable {
  const ScanCodeExportEvent();

  @override
  List<Object?> get props => [];
}

class HanldeScanCodeExport extends ScanCodeExportEvent {
  final String code;
  final int smTracktryID;
  final String packageImage;
  final String bagCode;
  const HanldeScanCodeExport(
      {required this.code,
      required this.bagCode,
      required this.smTracktryID,
      required this.packageImage});
  @override
  List<Object?> get props => [code, bagCode, smTracktryID, packageImage];
}
