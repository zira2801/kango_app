import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'details_order_pickup_shipper_state.dart';
part 'details_order_pickup_shipper_event.dart';

class DetailsOrderPickupShipperBloc extends Bloc<DetailsOrderPickupShipperEvent,
    DetailsOrderPickupShipperState> {
  DetailsOrderPickupShipperBloc()
      : super(HanldeGetDetailsOrderPickupShipperLoading()) {
    on<HanldeGetDetailsOrderShipperPickup>(
        _onHanldeGetDetailsOrderShipperPickup);
  }

  Future<void> _onHanldeGetDetailsOrderShipperPickup(
    HanldeGetDetailsOrderShipperPickup event,
    Emitter<DetailsOrderPickupShipperState> emit,
  ) async {
    emit(HanldeGetDetailsOrderPickupShipperLoading());

    final response = await http.post(
      Uri.parse('$baseUrl$detailsOrderPickUpAPI'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'order_pickup_id': event.orderPickupID,
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    try {
      if (data['status'] == 200) {
        emit(HanldeGetDetailsOrderPickupShipperSuccess(
            detailsOrderPickUpModel: DetailsOrderPickUpModel.fromJson(data)));
        log("_onHanldeGetDetailsOrderShipperPickup OKOK ");
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
        emit(HanldeGetDetailsOrderPickupShipperFailure(message: errorMessage));
      }
    } catch (error) {
      log('_onHanldeGetDetailsOrderShipperPickup error 2 $error');
      if (error is http.ClientException) {
        emit(const HanldeGetDetailsOrderPickupShipperFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(HanldeGetDetailsOrderPickupShipperFailure(
            message: error.toString()));
      }
    }
  }
}
