part of 'list_scan_import_bloc.dart';

abstract class ListScanImportEvent extends Equatable {
  const ListScanImportEvent();

  @override
  List<Object?> get props => [];
}

class FetchListScanImport extends ListScanImportEvent {
  final String? keyWords;
  final String? overTime;
  final int status;
  const FetchListScanImport({
    required this.keyWords,
    required this.overTime,
    required this.status,
  });
  @override
  List<Object?> get props => [keyWords, overTime, status];
}

class LoadMoreListScanImport extends ListScanImportEvent {
  final String? keyWords;
  final String? overTime;
  final int status;
  const LoadMoreListScanImport({
    required this.keyWords,
    required this.overTime,
    required this.status,
  });
  @override
  List<Object?> get props => [keyWords, overTime, status];
}

abstract class DeleteScanImportEvent extends Equatable {
  const DeleteScanImportEvent();

  @override
  List<Object?> get props => [];
}

class HandleDeleteScanImport extends DeleteScanImportEvent {
  final int historyID;
  const HandleDeleteScanImport({
    required this.historyID,
  });
  @override
  List<Object?> get props => [historyID];
}
