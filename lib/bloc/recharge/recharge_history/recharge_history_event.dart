part of 'recharge_history_bloc.dart';

abstract class ReChargeHistoryEvent extends Equatable {
  const ReChargeHistoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchListReChargeHistory extends ReChargeHistoryEvent {
  final int? status;
  final String? startDate;
  final String? endDate;
  final String? keyType;
  final String? keywords;

  const FetchListReChargeHistory({
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.keyType,
    required this.keywords,
  });
  @override
  List<Object?> get props => [status, startDate, endDate, keyType, keywords];
}

class LoadMoreListReChargeHistory extends ReChargeHistoryEvent {
  final int? status;
  final String? startDate;
  final String? endDate;
  final String? keyType;
  final String? keywords;

  const LoadMoreListReChargeHistory({
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.keyType,
    required this.keywords,
  });
  @override
  List<Object?> get props => [status, startDate, endDate, keyType, keywords];
}

abstract class DetailsReChargeHistoryEvent extends Equatable {
  const DetailsReChargeHistoryEvent();

  @override
  List<Object?> get props => [];
}

class HandleGetDetailsReChargeHistory extends DetailsReChargeHistoryEvent {
  final int? chanrgeID;

  const HandleGetDetailsReChargeHistory({
    required this.chanrgeID,
  });
  @override
  List<Object?> get props => [chanrgeID];
}
