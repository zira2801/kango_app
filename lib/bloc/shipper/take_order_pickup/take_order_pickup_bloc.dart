import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'take_order_pickup_event.dart';
part 'take_order_pickup_state.dart';

class TakeOrderPickupBloc
    extends Bloc<TakeOrderPickupEvent, TakeOrderPickupState> {
  TakeOrderPickupBloc() : super(TakeOrderPickupInitial()) {
    on<HanldeTakeOrderPickupShipper>(_onHanldeTakeOrderPickupShipper);
  }

  Future<void> _onHanldeTakeOrderPickupShipper(
    HanldeTakeOrderPickupShipper event,
    Emitter<TakeOrderPickupState> emit,
  ) async {
    emit(TakeOrderPickupLoading());
    print({
      'is_api': true,
      'shipper_id': event.shipperID,
      'order_pickup_id': event.orderPickUpID,
      'shipper_longitude': event.shipperLongitude,
      'shipper_latitude': event.shipperLatitude,
      'location_address': event.locationAddress,
    });
    final response = await http.post(
      Uri.parse('$baseUrl$shipperTakeOrderPickup'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'shipper_id': event.shipperID,
        'order_pickup_id': event.orderPickUpID,
        'shipper_longitude': event.shipperLongitude,
        'shipper_latitude': event.shipperLatitude,
        'location_address': event.locationAddress,
      }),
    );
    final data = jsonDecode(response.body);
    var messRes = data['message'];
    try {
      if (data['status'] == 200) {
        emit(TakeOrderPickupSuccess(successText: messRes['text']));
        log("_onHanldeTakeOrderPickupShipper OKOK ");
      } else {
        log('_onHanldeTakeOrderPickupShipper error ${messRes['text']} 1');
        emit(TakeOrderPickupFailure(errorText: messRes['text']));
      }
    } catch (error) {
      log('_onHanldeTakeOrderPickupShipper error 2 $error');
      emit(TakeOrderPickupFailure());
      if (error is http.ClientException) {
        emit(
            TakeOrderPickupFailure(errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(TakeOrderPickupFailure(errorText: "Đã có lỗi xảy ra"));
      }
    }
  }
}
