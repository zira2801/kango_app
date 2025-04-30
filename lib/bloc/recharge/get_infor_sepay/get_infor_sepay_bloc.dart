import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/recharge/get_data_detail_sepay_model.dart';
import 'package:scan_barcode_app/data/models/recharge/infor_payment_sepay_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
part 'get_infor_sepay_state.dart';
part 'get_infor_sepay_event.dart';

class GetInforSePayBloc extends Bloc<GetInforSePayEvent, GetInforSePayState> {
  GetInforSePayBloc() : super(GetInforSePayStateLoading()) {
    on<HanldeGetInforSePayEvent>(_onHanldeGetInforSePayEvent);
  }

  void _onHanldeGetInforSePayEvent(
    HanldeGetInforSePayEvent event,
    Emitter<GetInforSePayState> emit,
  ) async {
    emit(GetInforSePayStateLoading());
    try {
      // Fix URL format
      final response = await http.get(
        Uri.parse(
            'https://logis.websitehoconline.com/sepay/recharge/${event.rechargeID}'), // Sửa URL và thêm /api/
        headers: ApiUtils.getHeaders(isNeedToken: true),
      );

      log('Status Code: ${response.statusCode}');
      log('Response headers: ${response.headers}');
      log('Response body: ${response.body}');

      // Kiểm tra content-type trước khi parse JSON
      final contentType = response.headers['content-type'];
      if (contentType?.contains('text/html') ?? false) {
        emit(const GetInforSePayStateFailure(
            message: 'Dữ liệu trả về không hợp lệ'));
        return;
      }

      // Parse JSON chỉ khi chắc chắn response là JSON
      final data = jsonDecode(response.body);

      if (response.statusCode == 404) {
        emit(GetInforSePayStateFailure(message: data['message']));
        return;
      }

      if (response.statusCode != 200) {
        emit(GetInforSePayStateFailure(
            message: 'Lỗi server: ${data['message']}'));
        return;
      }

      if (data['status'] == 200) {
        emit(GetInforSePayStateSuccess(
            getDataDetailsSePayModel: GetDataDetailsSePayModel.fromJson(data)));
      } else {
        var message = data['message'];
        String errorMessage = message is Map
            ? message['text'] ?? 'Lỗi không xác định'
            : message?.toString() ?? 'Lỗi không xác định';
        emit(GetInforSePayStateFailure(message: errorMessage));
      }
    } catch (error) {
      log("ERROR _onHanldeGetInforSePayEvent: $error");
      String errorMessage = 'Có lỗi xảy ra!';

      if (error is FormatException) {
        errorMessage = 'Dữ liệu trả về không đúng định dạng';
      }

      emit(GetInforSePayStateFailure(message: errorMessage));
    }
  }
}
