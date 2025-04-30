part of 'create_ticket_bloc.dart';

abstract class ListTypeTicketEvent extends Equatable {
  const ListTypeTicketEvent();

  @override
  List<Object?> get props => [];
}

class GetListTypeTicket extends ListTypeTicketEvent {
  const GetListTypeTicket();
  @override
  List<Object?> get props => [];
}

class HandleCreateTicket extends ListTypeTicketEvent {
  final int ticketKind;
  final String ticketTransactionCode;
  final String ticketTitle;
  final String ticketMessageContent;
  final String? file0;
  final String? file1;
  final String? file2;
  final String? extension0;
  final String? extension1;
  final String? extension2;
  const HandleCreateTicket({
    required this.ticketKind,
    required this.ticketTransactionCode,
    required this.ticketTitle,
    required this.ticketMessageContent,
    required this.file0,
    required this.file1,
    required this.file2,
    required this.extension0,
    required this.extension1,
    required this.extension2,
  });
  @override
  List<Object?> get props => [
        ticketKind,
        ticketTransactionCode,
        ticketTitle,
        ticketMessageContent,
        file0,
        file1,
        file2,
      ];
}
