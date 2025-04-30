part of 'scan_code_import_bloc.dart';

abstract class ScanCodeImportState extends Equatable {
  const ScanCodeImportState();
  @override
  List<Object?> get props => [];
}

class ScanCodeImportStateInitial extends ScanCodeImportState {}

class ScanCodeImportStateLoading extends ScanCodeImportState {}

class ScanCodeImportStateSuccess extends ScanCodeImportState {
  final String message;

  const ScanCodeImportStateSuccess({required this.message});

  ScanCodeImportStateSuccess copyWith({String? message}) {
    return ScanCodeImportStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class ScanCodeImportStateFailure extends ScanCodeImportState {
  final String message;

  const ScanCodeImportStateFailure({required this.message});

  ScanCodeImportStateFailure copyWith({String? message}) {
    return ScanCodeImportStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class GetDetailsPackageStateLoading extends ScanCodeImportState {}

class GetDetailsPackageStateSuccess extends ScanCodeImportState {
  final DetailsPackageScanCodeModel detailsPackageScanCodeModel;
  const GetDetailsPackageStateSuccess(
      {required this.detailsPackageScanCodeModel});

  GetDetailsPackageStateSuccess copyWith(
      {DetailsPackageScanCodeModel? detailsPackageScanCodeModel}) {
    return GetDetailsPackageStateSuccess(
        detailsPackageScanCodeModel:
            detailsPackageScanCodeModel ?? this.detailsPackageScanCodeModel);
  }

  @override
  List<Object?> get props => [detailsPackageScanCodeModel];
}

class GetDetailsPackageStateFailure extends ScanCodeImportState {
  final String message;
  const GetDetailsPackageStateFailure({required this.message});
  GetDetailsPackageStateFailure copyWith({String? message}) {
    return GetDetailsPackageStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class GetListSurchageGoodsStateLoading extends ScanCodeImportState {}

class GetListSurchageGoodsStateSuccess extends ScanCodeImportState {
  final ListAllSurchageGoodsModel listAllSurchageGoodsModel;
  const GetListSurchageGoodsStateSuccess(
      {required this.listAllSurchageGoodsModel});

  GetListSurchageGoodsStateSuccess copyWith(
      {ListAllSurchageGoodsModel? listAllSurchageGoodsModel}) {
    return GetListSurchageGoodsStateSuccess(
        listAllSurchageGoodsModel:
            listAllSurchageGoodsModel ?? this.listAllSurchageGoodsModel);
  }

  @override
  List<Object?> get props => [listAllSurchageGoodsModel];
}

class GetListSurchageGoodsStateFailure extends ScanCodeImportState {
  final String message;
  const GetListSurchageGoodsStateFailure({required this.message});
  GetListSurchageGoodsStateFailure copyWith({String? message}) {
    return GetListSurchageGoodsStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
