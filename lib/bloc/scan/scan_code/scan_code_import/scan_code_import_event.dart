part of 'scan_code_import_bloc.dart';

abstract class ScanCodeImportEvent extends Equatable {
  const ScanCodeImportEvent();

  @override
  List<Object?> get props => [];
}

class HanldeScanCodeImport extends ScanCodeImportEvent {
  final String code;
  final List<SurchageGoodsChoosed> listSurchageGoodsChoosed;
  const HanldeScanCodeImport({
    required this.code,
    required this.listSurchageGoodsChoosed,
  });
  @override
  List<Object?> get props => [code];
}

class GetDetailsPackage extends ScanCodeImportEvent {
  final String mawbCode;
  const GetDetailsPackage({
    required this.mawbCode,
  });
  @override
  List<Object?> get props => [mawbCode];
}

class GetListSurchageGoods extends ScanCodeImportEvent {
  @override
  List<Object?> get props => [];
}
