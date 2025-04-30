import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'details_order_pickup_state.dart';
part 'details_order_pickup_event.dart';

class DetailsOrderPickupBloc
    extends Bloc<DetailsOrderPickupEvent, DetailsOrderPickupState> {
  DetailsOrderPickupBloc() : super(HanldeGetDetailsOrderPickupLoading()) {
    on<HanldeGetDetailsOrderPickup>(_onHanldeGetDetailsOrderPickup);
  }

  Future<void> _onHanldeGetDetailsOrderPickup(
    HanldeGetDetailsOrderPickup event,
    Emitter<DetailsOrderPickupState> emit,
  ) async {
    emit(HanldeGetDetailsOrderPickupLoading());
    log("event.orderPickupID");
    log({
      'order_pickup_id': event.orderPickupID,
    }.toString());
    final response = await http.post(
      Uri.parse('$baseUrl$detailsOrderPickUpAPI'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'order_pickup_id': event.orderPickupID,
      }),
    );
    /*// In ra body của phản hồi từ API
    log('Response body: ${response.body}');
*/
    final data = jsonDecode(response.body);
    /*log('Decoded data: $data');*/
    var mess = data['message'];
    try {
      if (data['status'] == 200) {
        emit(HanldeGetDetailsOrderPickupSuccess(
            detailsOrderPickUpModel: DetailsOrderPickUpModel.fromJson(data)));
        log("_onHanldeGetDetailsOrderPickup OKOK ");
      } else {
        log('_onHanldeGetDetailsOrderPickup error ${data['message']} 1');
        emit(HanldeGetDetailsOrderPickupFailure(message: mess));
      }
    } catch (error) {
      log('_onHanldeGetDetailsOrderPickup error 2 $error');
      if (error is http.ClientException) {
        emit(HanldeGetDetailsOrderPickupFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(HanldeGetDetailsOrderPickupFailure(message: error.toString()));
      }
    }
  }
}
