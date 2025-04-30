part of 'details_ticket_bloc.dart';

abstract class DetailsTicketState extends Equatable {
  const DetailsTicketState();
  @override
  List<Object?> get props => [];
}

class DetailsTicketStateInitial extends DetailsTicketState {}

class DetailsTicketStateLoading extends DetailsTicketState {}

class DetailsTicketStateSuccess extends DetailsTicketState {
  final DetailsTicketModel detailsTicketModel;

  const DetailsTicketStateSuccess({
    required this.detailsTicketModel,
  });
  DetailsTicketStateSuccess copyWith({
    DetailsTicketModel? detailsTicketModel,
  }) {
    return DetailsTicketStateSuccess(
      detailsTicketModel: detailsTicketModel ?? this.detailsTicketModel,
    );
  }

  @override
  List<Object?> get props => [detailsTicketModel];
}

class DetailsTicketStateFailure extends DetailsTicketState {
  final String message;

  const DetailsTicketStateFailure({required this.message});

  DetailsTicketStateFailure copyWith({String? message}) {
    return DetailsTicketStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class SendMessTicketStateLoading extends DetailsTicketState {}

class SendMessTicketStateSuccess extends DetailsTicketState {
  final ResMessTicketModel resMessTicketModel;

  const SendMessTicketStateSuccess({
    required this.resMessTicketModel,
  });
  SendMessTicketStateSuccess copyWith({
    ResMessTicketModel? resMessTicketModel,
  }) {
    return SendMessTicketStateSuccess(
      resMessTicketModel: resMessTicketModel ?? this.resMessTicketModel,
    );
  }

  @override
  List<Object?> get props => [resMessTicketModel];
}

class SendMessTicketStateFailure extends DetailsTicketState {
  final String message;

  const SendMessTicketStateFailure({required this.message});

  SendMessTicketStateFailure copyWith({String? message}) {
    return SendMessTicketStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
