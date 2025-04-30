import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/ticket/list_type_ticket.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'create_ticket_event.dart';
part 'create_ticket_state.dart';

class ListTypeTicketBloc extends Bloc<ListTypeTicketEvent, CreateTicketState> {
  ListTypeTicketBloc() : super(ListTypeTicketStateInitial()) {
    on<GetListTypeTicket>(_onGetListTypeTicket);
    on<HandleCreateTicket>(_onHandleCreateTicket);
  }

  Future<void> _onGetListTypeTicket(
    GetListTypeTicket event,
    Emitter<CreateTicketState> emit,
  ) async {
    emit(ListTypeTicketStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListTypeTicket'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        log("_onGetListTypeTicket OKOK");
        emit(ListTypeTicketStateSuccess(
            listTypeTicketModel: ListTypeTicketModel.fromJson(data)));
      } else {
        log("ERROR _onGetListTypeTicket 1");
        emit(const ListTypeTicketStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onGetListTypeTicket 2 $error");
      if (error is http.ClientException) {
        emit(const ListTypeTicketStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(ListTypeTicketStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onHandleCreateTicket(
    HandleCreateTicket event,
    Emitter<CreateTicketState> emit,
  ) async {
    emit(HandleCreateTicketStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$createTicketApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'ticket_kind': event.ticketKind,
          'ticket_transaction_code': event.ticketTransactionCode,
          'ticket_title': event.ticketTitle,
          'ticket_message_content': event.ticketMessageContent,
          'file_0': event.file0,
          'file_1': event.file1,
          'file_2': event.file2,
          'extension_0': event.extension0,
          'extension_1': event.extension1,
          'extension_2': event.extension2,
        }),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        log("_onGetListTypeTicket OKOK");
        emit(HandleCreateTicketStateSuccess(message: "message"));
      } else {
        log("ERROR _onHandleCreateTicket 1");
        emit(const HandleCreateTicketStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onHandleCreateTicket 2 $error");
      if (error is http.ClientException) {
        emit(const HandleCreateTicketStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(HandleCreateTicketStateFailure(message: error.toString()));
      }
    }
  }
}
