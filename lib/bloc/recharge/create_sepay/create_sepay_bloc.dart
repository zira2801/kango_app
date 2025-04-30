import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/recharge/infor_payment_sepay_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
part 'create_sepay_state.dart';
part 'create_sepay_event.dart';

class CreateSePayBloc extends Bloc<CreateSePayEvent, CreateSePayState> {
  CreateSePayBloc() : super(CreateSePayStateLoading()) {
    on<HanldeCreateSePayEvent>(_onHanldeCreateSePayEvent);
  }

  void _onHanldeCreateSePayEvent(
    HanldeCreateSePayEvent event,
    Emitter<CreateSePayState> emit,
  ) async {
    emit(CreateSePayStateLoading());
    try {
      final requestBody = {
        'is_api': true,
        'type': event.type,
        'amount': event.amount,
        'note': event.note,
      };

      log('Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl$createSePay'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode(requestBody),
      );

      log('Status Code: ${response.statusCode}');
      log('Response headers: ${response.headers}');
      log('Response body: ${response.body}');

      if (response.statusCode != 200) {
        emit(CreateSePayStateFailure(
            message: 'Lỗi server: ${response.statusCode}'));
        return;
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        emit(CreateSePayStateSuccess(
            inforPaymentSePayModel: InforPaymentSePayModel.fromJson(data)));
      } else {
        var message = data['message'];
        String errorMessage = message is Map
            ? message['text'] ?? 'Lỗi không xác định'
            : message?.toString() ?? 'Lỗi không xác định';
        emit(CreateSePayStateFailure(message: errorMessage));
      }
    } catch (error) {
      log("ERROR _onHanldeCreateSePayEvent: $error");
      String errorMessage = 'Có lỗi xảy ra!';

      if (error is FormatException) {
        errorMessage = 'Dữ liệu trả về không đúng định dạng';
      }

      emit(CreateSePayStateFailure(message: errorMessage));
    }
  }
}
