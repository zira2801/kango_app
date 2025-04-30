part of 'list_scan_import_bloc.dart';

abstract class ListScanImportState extends Equatable {
  const ListScanImportState();
  @override
  List<Object?> get props => [];
}

class ListScanImportStateInitial extends ListScanImportState {}

class ListScanImportStateLoading extends ListScanImportState {}

class ListScanImportStateSuccess extends ListScanImportState {
  final List<DataItemImportScan> data;
  final int page;
  final bool hasReachedMax;
  const ListScanImportStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  ListScanImportStateSuccess copyWith({
    List<DataItemImportScan>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return ListScanImportStateSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class ListScanImportStateFailure extends ListScanImportState {
  final String message;

  const ListScanImportStateFailure({required this.message});

  ListScanImportStateFailure copyWith({String? message}) {
    return ListScanImportStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class DeleteScanImportState extends Equatable {
  const DeleteScanImportState();
  @override
  List<Object?> get props => [];
}

class DeleteScanImportStateInitial extends DeleteScanImportState {}

class DeleteScanImportStateLoading extends DeleteScanImportState {}

class DeleteScanImportStateSuccess extends DeleteScanImportState {
  final String? successText;
  const DeleteScanImportStateSuccess({this.successText});
}

class DeleteScanImportStateFailure extends DeleteScanImportState {
  final String? errorText;
  const DeleteScanImportStateFailure({this.errorText});
}
