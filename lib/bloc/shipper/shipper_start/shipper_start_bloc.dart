import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'shipper_start_event.dart';
part 'shipper_start_state.dart';

class ShipperStartBloc extends Bloc<ShipperStartEvent, ShipperStartState> {
  ShipperStartBloc() : super(ShipperStartInitial()) {
    on<HanldeShipperStart>(_onHanldeShipperStart);
  }

  Future<void> _onHanldeShipperStart(
    HanldeShipperStart event,
    Emitter<ShipperStartState> emit,
  ) async {
    emit(ShipperStartLoading());
    log({
      'shipper_id': event.shipperID,
    }.toString());
    final response = await http.post(
      Uri.parse('$baseUrl$shipperStart'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'shipper_id': event.shipperID,
      }),
    );
    final data = jsonDecode(response.body);
    var messRes = data['message'];
    try {
      if (data['status'] == 200) {
        emit(ShipperStartSuccess(successText: messRes['text']));
        log("_onHanldeTakeOrderPickupShipper OKOK ");
      } else {
        log('_onHanldeTakeOrderPickupShipper error ${messRes['text']} 1');
        emit(ShipperStartFailure(errorText: messRes['text']));
      }
    } catch (error) {
      log('_onHanldeTakeOrderPickupShipper error 2 $error');
      emit(ShipperStartFailure());
      if (error is http.ClientException) {
        emit(ShipperStartFailure(errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(ShipperStartFailure(errorText: "Đã có lỗi xảy ra"));
      }
    }
  }
}
