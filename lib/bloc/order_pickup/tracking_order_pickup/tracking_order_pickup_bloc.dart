import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'tracking_order_pickup_state.dart';
part 'tracking_order_pickup_event.dart';

class TrackingOrderPickupBloc
    extends Bloc<TrackingOrderPickupEvent, TrackingOrderPickupState> {
  TrackingOrderPickupBloc() : super(TrackingOrderPickupLoading()) {
    on<HanldeTrackingOrderPickup>(_onHanldeTrackingOrderPickup);
  }

  Future<void> _onHanldeTrackingOrderPickup(
    HanldeTrackingOrderPickup event,
    Emitter<TrackingOrderPickupState> emit,
  ) async {
    emit(TrackingOrderPickupLoading());

    final response = await http.post(
      Uri.parse('$baseUrl$getCurrentPositionOfShipper'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'shipper_longitude': event.shipperLongitude,
        'shipper_latitude': event.shipperLatitude,
        'location_address': event.locationAddress,
      }),
    );
    final data = jsonDecode(response.body);
    final mess = data['message'];

    try {
      if (data['status'] == 200) {
        emit(TrackingOrderPickupSuccess());
        log("_onHanldeTrackingOrderPickup OKOK ");
      } else {
        log('_onHanldeTrackingOrderPickup error ${data['message']} 1');
        emit(TrackingOrderPickupFailure(message: mess['text']));
      }
    } catch (error) {
      log('_onHanldeTrackingOrderPickup error 2 $error');

      if (error is http.ClientException) {
        emit(TrackingOrderPickupFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(TrackingOrderPickupFailure(message: error.toString()));
      }
    }
  }
}
