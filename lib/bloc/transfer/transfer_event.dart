part of 'transfer_bloc.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

class FetchListTransfer extends TransferEvent {
  final String? startDate;
  final String? endDate;
  final String? keywords;

  const FetchListTransfer({
    required this.startDate,
    required this.endDate,
    required this.keywords,
  });
  @override
  List<Object?> get props => [];
}

class LoadMoreListTransfer extends TransferEvent {
  final String? startDate;
  final String? endDate;
  final String? keywords;

  const LoadMoreListTransfer({
    required this.startDate,
    required this.endDate,
    required this.keywords,
  });
  @override
  List<Object?> get props => [];
}

class HandleCreateTransfer extends TransferEvent {
  final int? transferID;
  final String transferContent;
  final Map<String, String> transferImages;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final Map<String, Map<String, String>> transferShipmentCodes;

  const HandleCreateTransfer({
    required this.transferID,
    required this.transferContent,
    required this.transferImages,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.transferShipmentCodes,
  });

  @override
  List<Object?> get props => [
        transferID,
        transferContent,
        transferImages,
        receiverName,
        receiverPhone,
        receiverAddress,
        transferShipmentCodes,
      ];
}

class ApproveTransfer extends TransferEvent {
  final int? transferID;
  const ApproveTransfer({required this.transferID});

  @override
  List<Object?> get props => [transferID];
}

class DeleteTransfer extends TransferEvent {
  final int? transferID;
  const DeleteTransfer({required this.transferID});

  @override
  List<Object?> get props => [transferID];
}
