part of 'wallet_fluctuations_bloc.dart';

abstract class WalletFluctuationsEvent extends Equatable {
  const WalletFluctuationsEvent();

  @override
  List<Object?> get props => [];
}

class FetchListWalletFluctuations extends WalletFluctuationsEvent {
  final String? startDate;
  final String? endDate;
  final int? kind;
  final String? keywords;

  const FetchListWalletFluctuations({
    this.startDate,
    this.endDate,
    this.kind,
    this.keywords,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        kind,
        keywords,
      ];
}

class LoadMoreListWalletFluctuations extends WalletFluctuationsEvent {
  final String? startDate;
  final String? endDate;
  final int? kind;
  final String? keywords;

  const LoadMoreListWalletFluctuations({
    this.startDate,
    this.endDate,
    this.kind,
    this.keywords,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        kind,
        keywords,
      ];
}
