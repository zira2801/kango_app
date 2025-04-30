part of 'create_ticket_bloc.dart';

abstract class CreateTicketState extends Equatable {
  const CreateTicketState();
  @override
  List<Object?> get props => [];
}

class ListTypeTicketStateInitial extends CreateTicketState {}

class ListTypeTicketStateLoading extends CreateTicketState {}

class ListTypeTicketStateSuccess extends CreateTicketState {
  final ListTypeTicketModel listTypeTicketModel;

  const ListTypeTicketStateSuccess({
    required this.listTypeTicketModel,
  });
  ListTypeTicketStateSuccess copyWith({
    ListTypeTicketModel? listTypeTicketModel,
  }) {
    return ListTypeTicketStateSuccess(
      listTypeTicketModel: listTypeTicketModel ?? this.listTypeTicketModel,
    );
  }

  @override
  List<Object?> get props => [listTypeTicketModel];
}

class ListTypeTicketStateFailure extends CreateTicketState {
  final String message;

  const ListTypeTicketStateFailure({required this.message});

  ListTypeTicketStateFailure copyWith({String? message}) {
    return ListTypeTicketStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class HandleCreateTicketStateLoading extends CreateTicketState {}

class HandleCreateTicketStateSuccess extends CreateTicketState {
  final String message;

  const HandleCreateTicketStateSuccess({required this.message});

  HandleCreateTicketStateSuccess copyWith({String? message}) {
    return HandleCreateTicketStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class HandleCreateTicketStateFailure extends CreateTicketState {
  final String message;

  const HandleCreateTicketStateFailure({required this.message});

  HandleCreateTicketStateFailure copyWith({String? message}) {
    return HandleCreateTicketStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
