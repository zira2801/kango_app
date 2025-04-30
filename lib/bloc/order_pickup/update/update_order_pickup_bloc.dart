import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_event.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_state.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';

class UpdateOrderPickupBloc
    extends Bloc<UpdateOrderPickupEvent, UpdateOrderPickupState> {
  UpdateOrderPickupBloc() : super(UpdateOrderPickupLoading()) {
    on<HanldeUpdateOrderPickup>(_onHanldeUpdateOrderPickup);
  }

  Future<void> _onHanldeUpdateOrderPickup(
    HanldeUpdateOrderPickup event,
    Emitter<UpdateOrderPickupState> emit,
  ) async {
    log({
      'is_api': true,
      'order_pickup_id': event.orderPickUpID,
      'order_pickup_type': event.orderPickUpType,
      'branch_id': event.branchIDEdit,
      'fwd_id': event.fwd,
      'order_pickup_date_time': event.orderPickUpTime,
      'order_pickup_awb': event.orderPickUpAWB,
      'order_pickup_gross_weight': event.orderPickUpGrossWeight,
      'order_pickup_number_packages': event.orderPickUpNumberPackage,
      'order_pickup_phone': event.orderPickUpPhone,
      'order_pickup_name': event.orderPickupName,
      'order_pickup_address': event.orderPickUpAdrees,
      'order_pickup_note': event.orderPickUpNote,
      'order_pickup_status': event.orderPickUpStatus,
      // 'order_pickup_image': event.orderPickUpImage,
      'latitude': event.latitude,
      'longitude': event.longitude,
      'order_pickup_cancel_des': event.orderPickupCancelDes
    }.toString());
    emit(UpdateOrderPickupLoading());
    final response = await http.post(
      Uri.parse('$baseUrl$updateOrderPickUpAPI'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'order_pickup_id': event.orderPickUpID,
        'order_pickup_type': event.orderPickUpType,
        'branch_id': event.branchIDEdit,
        'fwd_id': event.fwd,
        'order_pickup_date_time': event.orderPickUpTime,
        'order_pickup_awb': event.orderPickUpAWB,
        'order_pickup_gross_weight': event.orderPickUpGrossWeight,
        'order_pickup_number_packages': event.orderPickUpNumberPackage,
        'order_pickup_phone': event.orderPickUpPhone,
        'order_pickup_name': event.orderPickupName,
        'order_pickup_address': event.orderPickUpAdrees,
        'order_pickup_note': event.orderPickUpNote,
        'order_pickup_status': event.orderPickUpStatus,
        'order_pickup_image': event.orderPickUpImage,
        'latitude': event.latitude,
        'longitude': event.longitude,
        'order_pickup_cancel_des': event.orderPickupCancelDes
      }),
    );
    final data = jsonDecode(response.body);
    final mess = data['message'];
    try {
      if (data['status'] == 200) {
        emit(UpdateOrderPickupSuccess());
        log("_onHanldeUpdateOrderPickup OKOK ");
      } else {
        log('_onHanldeUpdateOrderPickup error ${data['message']} 1');
        emit(UpdateOrderPickupFailure(errorText: mess['text']));
      }
    } catch (error) {
      log('_onHanldeUpdateOrderPickup error 2 $error');
      emit(UpdateOrderPickupFailure());
      if (error is http.ClientException) {
        emit(UpdateOrderPickupFailure(
            errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(UpdateOrderPickupFailure(errorText: "Đã có lỗi xảy ra"));
      }
    }
  }
}
