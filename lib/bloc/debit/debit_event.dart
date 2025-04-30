part of 'debit_bloc.dart';

abstract class DebitEvent extends Equatable {
  const DebitEvent();

  @override
  List<Object?> get props => [];
}

class FetchListDebit extends DebitEvent {
  final String? startDate;
  final String? endDate;
  final int? debitStatus;
  final String? keywords;

  const FetchListDebit({
    this.startDate,
    this.endDate,
    this.debitStatus,
    this.keywords,
  });

  @override
  List<Object?> get props => [startDate, endDate, keywords, debitStatus];
}

class LoadMoreListDebit extends DebitEvent {
  final String? startDate;
  final String? endDate;
  final int? debitStatus;
  final String? keywords;

  const LoadMoreListDebit(
      {this.startDate, this.endDate, this.keywords, this.debitStatus});

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        debitStatus,
        keywords,
      ];
}

class CheckAccountainCodeDebit extends DebitEvent {
  final String key;
  const CheckAccountainCodeDebit({required this.key});

  @override
  List<Object?> get props => [key];
}

class GetDetailDebit extends DebitEvent {
  final String debitCode;
  const GetDetailDebit({required this.debitCode});

  @override
  List<Object?> get props => [debitCode];
}

class FetchListShipmentDebit extends DebitEvent {
  final int? debitID;
  final String? keywords;

  const FetchListShipmentDebit({
    this.debitID,
    this.keywords,
  });

  @override
  List<Object?> get props => [debitID, keywords];
}

class LoadMoreListShipmentDebit extends DebitEvent {
  final int? debitID;
  final String? keywords;

  const LoadMoreListShipmentDebit({
    this.debitID,
    this.keywords,
  });

  @override
  List<Object?> get props => [
        debitID,
        keywords,
      ];
}

class OnHandlePaymentDebit extends DebitEvent {
  final String debitNo;
  final String? debitNote;
  final int debitPaymentMethod;
  final double debitPaymentAmount;
  final double bankAmount;
  final double cashAmount;
  final List<String> debitsImages;

  const OnHandlePaymentDebit({
    required this.debitNo,
    this.debitNote,
    required this.debitPaymentMethod,
    required this.debitPaymentAmount,
    required this.bankAmount,
    required this.cashAmount,
    required this.debitsImages,
  });

  @override
  List<Object?> get props => [
        debitNo,
        debitNote,
        debitPaymentMethod,
        debitPaymentAmount,
        bankAmount,
        cashAmount,
        debitsImages,
      ];
}
