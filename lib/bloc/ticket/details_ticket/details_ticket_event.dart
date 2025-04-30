part of 'details_ticket_bloc.dart';

abstract class DetailsTicketEvent extends Equatable {
  const DetailsTicketEvent();

  @override
  List<Object?> get props => [];
}

class HandleGetDetailsTicket extends DetailsTicketEvent {
  final int ticketID;
  const HandleGetDetailsTicket({
    required this.ticketID,
  });
  @override
  List<Object?> get props => [
        ticketID,
      ];
}

class HandleSendMessTicket extends DetailsTicketEvent {
  final int ticketID;
  final String mess;
  final String? path;
  const HandleSendMessTicket({
    required this.ticketID,
    required this.mess,
    required this.path,
  });
  @override
  List<Object?> get props => [ticketID, mess, path];
}
