part of 'scan_code_export_bloc.dart';

abstract class ScanCodeExportState extends Equatable {
  const ScanCodeExportState();
  @override
  List<Object?> get props => [];
}

class ScanCodeExportStateInitial extends ScanCodeExportState {}

class ScanCodeExportStateLoading extends ScanCodeExportState {}

class ScanCodeExportStateSuccess extends ScanCodeExportState {
  final String message;

  const ScanCodeExportStateSuccess({required this.message});

  ScanCodeExportStateSuccess copyWith({String? message}) {
    return ScanCodeExportStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class ScanCodeExportStateFailure extends ScanCodeExportState {
  final String message;

  const ScanCodeExportStateFailure({required this.message});

  ScanCodeExportStateFailure copyWith({String? message}) {
    return ScanCodeExportStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
