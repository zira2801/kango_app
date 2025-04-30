import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'update_status_order_shipper_event.dart';
part 'update_status_order_shipper_state.dart';

class UpdateStatusOrderPickupShipperBloc extends Bloc<
    UpdateStatusOrderPickupShipperEvent, UpdateStatusOrderPickupShipperState> {
  UpdateStatusOrderPickupShipperBloc()
      : super(UpdateStatusOrderPickupShipperInitial()) {
    on<HanldeUpdateStatusOrderPickupShipper>(
        _onHanldeUpdateStatusOrderPickupShipper);
  }

  Future<void> _onHanldeUpdateStatusOrderPickupShipper(
    HanldeUpdateStatusOrderPickupShipper event,
    Emitter<UpdateStatusOrderPickupShipperState> emit,
  ) async {
    emit(UpdateStatusOrderPickupShipperLoading());

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

    try {
      if (data['status'] == 200) {
        emit(UpdateStatusOrderPickupShipperSuccess());
        log("_onHanldeUpdateStatusOrderPickupShipper OKOK ");
      } else {
        log('_onHanldeUpdateStatusOrderPickupShipper error ${data['message']} 1');
        emit(UpdateStatusOrderPickupShipperFailure(errorText: data['message']));
      }
    } catch (error) {
      log('_onHanldeUpdateStatusOrderPickupShipper error 2 $error');
      emit(UpdateStatusOrderPickupShipperFailure());
      if (error is http.ClientException) {
        emit(UpdateStatusOrderPickupShipperFailure(
            errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(UpdateStatusOrderPickupShipperFailure(
            errorText: "Đã có lỗi xảy ra"));
      }
    }
  }
}
