import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'shipper_finish_event.dart';
part 'shipper_finish_state.dart';

class ShipperFinishBloc extends Bloc<ShipperFinishEvent, ShipperFinishState> {
  ShipperFinishBloc() : super(ShipperFinishInitial()) {
    on<HanldeShipperFinish>(_onHanldeShipperFinish);
  }

  Future<void> _onHanldeShipperFinish(
    HanldeShipperFinish event,
    Emitter<ShipperFinishState> emit,
  ) async {
    emit(ShipperFinishLoading());
    log({
      'shipper_longitude': event.shipperLongitude,
      'shipper_latitude': event.shipperLatitude,
      'location_address': event.shipperLocation,
    }.toString());
    final response = await http.post(
      Uri.parse('$baseUrl$shipperFinish'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'shipper_longitude': event.shipperLongitude,
        'shipper_latitude': event.shipperLatitude,
        'location_address': event.shipperLocation,
      }),
    );
    final data = jsonDecode(response.body);
    var messRes = data['message'];
    try {
      if (data['status'] == 200) {
        emit(ShipperFinishSuccess(successText: messRes['text']));
        log("_onHanldeTakeOrderPickupShipper OKOK ");
      } else {
        log('_onHanldeTakeOrderPickupShipper error ${messRes['text']} 1');
        emit(ShipperFinishFailure(errorText: messRes['text']));
      }
    } catch (error) {
      log('_onHanldeTakeOrderPickupShipper error 2 $error');
      emit(ShipperFinishFailure());
      if (error is http.ClientException) {
        emit(ShipperFinishFailure(errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(ShipperFinishFailure(errorText: "Đã có lỗi xảy ra"));
      }
    }
  }
}
