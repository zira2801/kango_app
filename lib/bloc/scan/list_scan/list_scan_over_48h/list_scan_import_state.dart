part of 'list_scan_import_bloc.dart';

abstract class ListScanOver48HState extends Equatable {
  const ListScanOver48HState();
  @override
  List<Object?> get props => [];
}

class ListScanOver48HStateInitial extends ListScanOver48HState {}

class ListScanOver48HStateLoading extends ListScanOver48HState {}

class ListScanOver48HStateSuccess extends ListScanOver48HState {
  final List<DataItemImportScan> data;
  final int page;
  final bool hasReachedMax;
  const ListScanOver48HStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  ListScanOver48HStateSuccess copyWith({
    List<DataItemImportScan>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return ListScanOver48HStateSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class ListScanOver48HStateFailure extends ListScanOver48HState {
  final String message;

  const ListScanOver48HStateFailure({required this.message});

  ListScanOver48HStateFailure copyWith({String? message}) {
    return ListScanOver48HStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
