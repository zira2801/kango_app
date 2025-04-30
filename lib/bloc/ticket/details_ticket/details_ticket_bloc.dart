import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/ticket/details_ticket.dart';
import 'package:scan_barcode_app/data/models/ticket/res_mess.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'details_ticket_event.dart';
part 'details_ticket_state.dart';

class DetailsTicketBloc extends Bloc<DetailsTicketEvent, DetailsTicketState> {
  DetailsTicketBloc() : super(DetailsTicketStateInitial()) {
    on<HandleGetDetailsTicket>(_onHandleGetDetailsTicket);
    on<HandleSendMessTicket>(_onHandleSendMessTicket);
  }

  Future<void> _onHandleGetDetailsTicket(
    HandleGetDetailsTicket event,
    Emitter<DetailsTicketState> emit,
  ) async {
    emit(DetailsTicketStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getDetailTicketApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'ticket_id': event.ticketID,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        log("_onHandleGetDetailsTicket OKOK");
        final dataDetailsTicket = DetailsTicketModel.fromJson(data);
        emit(DetailsTicketStateSuccess(detailsTicketModel: dataDetailsTicket));
      } else {
        log("ERROR _onHandleGetDetailsTicket 1");
        emit(const DetailsTicketStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onHandleGetDetailsTicket 2 $error");
      if (error is http.ClientException) {
        emit(const DetailsTicketStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(DetailsTicketStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onHandleSendMessTicket(
    HandleSendMessTicket event,
    Emitter<DetailsTicketState> emit,
  ) async {
    emit(SendMessTicketStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$sendMessTicket'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'ticket_id': event.ticketID,
          'ticket_message_content': event.mess,
          'ticket_message_content_extension': event.path
        }),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        log("_onHandleGetDetailsTicket OKOK");
        final dataResMessTicket = ResMessTicketModel.fromJson(data);
        emit(SendMessTicketStateSuccess(resMessTicketModel: dataResMessTicket));
      } else {
        log("ERROR _onHandleGetDetailsTicket 1");
        emit(const SendMessTicketStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onHandleGetDetailsTicket 2 $error");
      if (error is http.ClientException) {
        emit(const SendMessTicketStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(SendMessTicketStateFailure(message: error.toString()));
      }
    }
  }
}
