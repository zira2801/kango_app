part of 'list_scan_import_bloc.dart';

abstract class ListScanOver48HEvent extends Equatable {
  const ListScanOver48HEvent();

  @override
  List<Object?> get props => [];
}

class FetchListScanOver48H extends ListScanOver48HEvent {
  final String? keyWords;
  final int status;
  const FetchListScanOver48H({
    required this.keyWords,
    required this.status,
  });
  @override
  List<Object?> get props => [keyWords, status];
}

class LoadMoreListScanOver48H extends ListScanOver48HEvent {
  final String? keyWords;
  final int status;
  const LoadMoreListScanOver48H({
    required this.keyWords,
    required this.status,
  });
  @override
  List<Object?> get props => [keyWords, status];
}
