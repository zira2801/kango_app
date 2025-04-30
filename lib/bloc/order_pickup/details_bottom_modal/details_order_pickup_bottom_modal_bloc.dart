import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'details_order_pickup_bottom_modal_state.dart';
part 'details_order_pickup_bottom_modal_event.dart';

class DetailsOrderPickupModalBottomBloc extends Bloc<
    DetailsOrderPickupModalBottomEvent, DetailsOrderPickupModalBottomState> {
  DetailsOrderPickupModalBottomBloc()
      : super(HanldeGetDetailsOrderPickupModalBottomLoading()) {
    on<HanldeGetDetailsOrderPickupModalBottom>(
        _onHanldeGetDetailsOrderPickupModalBottom);
  }

  Future<void> _onHanldeGetDetailsOrderPickupModalBottom(
    HanldeGetDetailsOrderPickupModalBottom event,
    Emitter<DetailsOrderPickupModalBottomState> emit,
  ) async {
    emit(HanldeGetDetailsOrderPickupModalBottomLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$detailsOrderPickUpAPI'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'order_pickup_id': event.orderPickupID,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          emit(HanldeGetDetailsOrderPickupModalBottomSuccess(
            detailsOrderPickUpModel: DetailsOrderPickUpModel.fromJson(data),
          ));
          log("_onHanldeGetDetailsOrderPickupModalBottom OKOK");
        } else {
          // Kiểm tra kiểu dữ liệu của message
          String errorMessage;
          if (data['message'] is Map) {
            // Nếu là Map, lấy text làm message
            errorMessage = data['message']['text'] ?? "Có lỗi xảy ra";
          } else {
            // Nếu là String hoặc kiểu khác
            errorMessage = data['message']?.toString() ?? "Có lỗi xảy ra";
          }
          log('_onHanldeGetDetailsOrderPickupModalBottom error 1 ${data['message']}');
          emit(HanldeGetDetailsOrderPickupModalBottomFailure(
              message: errorMessage));
        }
      } else {
        log('API response failed with status code: ${response.statusCode}');
        emit(const HanldeGetDetailsOrderPickupModalBottomFailure(
            message: "Lỗi kết nối đến máy chủ"));
      }
    } catch (error) {
      log('_onHanldeGetDetailsOrderPickupModalBottom error 2: $error');
      if (error is FormatException) {
        emit(const HanldeGetDetailsOrderPickupModalBottomFailure(
            message: "Dữ liệu phản hồi không hợp lệ"));
      } else {
        emit(HanldeGetDetailsOrderPickupModalBottomFailure(
            message: error.toString()));
      }
    }
  }
}
