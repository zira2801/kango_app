part of 'list_ticket_bloc.dart';

abstract class ListTicketEvent extends Equatable {
  const ListTicketEvent();

  @override
  List<Object?> get props => [];
}

class FetchListTicketStatusPending extends ListTicketEvent {
  const FetchListTicketStatusPending();
  @override
  List<Object?> get props => [];
}

class LoadMoreListTicketStatusPending extends ListTicketEvent {
  const LoadMoreListTicketStatusPending();
  @override
  List<Object?> get props => [];
}

class FetchListTicketStatusProcessing extends ListTicketEvent {
  const FetchListTicketStatusProcessing();
  @override
  List<Object?> get props => [];
}

class LoadMoreListTicketStatusProcessing extends ListTicketEvent {
  const LoadMoreListTicketStatusProcessing();
  @override
  List<Object?> get props => [];
}

class FetchListTicketStatusDone extends ListTicketEvent {
  const FetchListTicketStatusDone();
  @override
  List<Object?> get props => [];
}

class LoadMoreListTicketStatusDone extends ListTicketEvent {
  const LoadMoreListTicketStatusDone();
  @override
  List<Object?> get props => [];
}
