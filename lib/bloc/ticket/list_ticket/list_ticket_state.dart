part of 'list_ticket_bloc.dart';

abstract class ListTicketState extends Equatable {
  const ListTicketState();
  @override
  List<Object?> get props => [];
}

class ListTicketStateInitial extends ListTicketState {}

class ListTicketStatusPendingStateLoading extends ListTicketState {}

class ListTicketStatusPendingStateSuccess extends ListTicketState {
  final List<DetailsItemTicket> data;
  final int page;
  final bool hasReachedMax;
  const ListTicketStatusPendingStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  ListTicketStatusPendingStateSuccess copyWith({
    List<DetailsItemTicket>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return ListTicketStatusPendingStateSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class ListTicketStatusPendingStateFailure extends ListTicketState {
  final String message;

  const ListTicketStatusPendingStateFailure({required this.message});

  ListTicketStatusPendingStateFailure copyWith({String? message}) {
    return ListTicketStatusPendingStateFailure(
        message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class ListTicketStatusProcessingStateLoading extends ListTicketState {}

class ListTicketStatusProcessingStateSuccess extends ListTicketState {
  final List<DetailsItemTicket> data;
  final int page;
  final bool hasReachedMax;
  const ListTicketStatusProcessingStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  ListTicketStatusProcessingStateSuccess copyWith({
    List<DetailsItemTicket>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return ListTicketStatusProcessingStateSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class ListTicketStatusProcessingStateFailure extends ListTicketState {
  final String message;

  const ListTicketStatusProcessingStateFailure({required this.message});

  ListTicketStatusProcessingStateFailure copyWith({String? message}) {
    return ListTicketStatusProcessingStateFailure(
        message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class ListTicketStatusDoneStateLoading extends ListTicketState {}

class ListTicketStatusDoneStateSuccess extends ListTicketState {
  final List<DetailsItemTicket> data;
  final int page;
  final bool hasReachedMax;
  const ListTicketStatusDoneStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });
  ListTicketStatusDoneStateSuccess copyWith({
    List<DetailsItemTicket>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return ListTicketStatusDoneStateSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax];
}

class ListTicketStatusDoneStateFailure extends ListTicketState {
  final String message;

  const ListTicketStatusDoneStateFailure({required this.message});

  ListTicketStatusDoneStateFailure copyWith({String? message}) {
    return ListTicketStatusDoneStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
