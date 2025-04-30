import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/shipment/details_tracking.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'details_tracking_shipment_event.dart';
part 'details_tracking_shipment_state.dart';

class DetailsTrackingShipmentBloc
    extends Bloc<DetailsTrackingShipmentEvent, DetailsTrackingShipmentState> {
  DetailsTrackingShipmentBloc() : super(DetailsTrackingShipmentStateInitial()) {
    on<GetDetailsTrackingShipmentEvent>(_onGetDetailsTrackingShipmentEvent);
  }

  Future<void> _onGetDetailsTrackingShipmentEvent(
    GetDetailsTrackingShipmentEvent event,
    Emitter<DetailsTrackingShipmentState> emit,
  ) async {
    log("PackageCode: ${event.packageHawbCode}");
    emit(DetailsTrackingShipmentStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl2$getShipmentTrackingDetails'),
        headers: ApiUtils.getHeaders(isNeedToken: false),
        body: jsonEncode({
          'is_api': true,
          'package_hawb_code': event.packageHawbCode,
        }),
      );

      log("Response status code: ${response.statusCode}");
      final data = jsonDecode(response.body);
      log("Response data type: ${data.runtimeType}");

      if (data['status'] == 200) {
        final dataDetailsTracking = DetailsTrackingModel.fromJson(data);
        emit(DetailsTrackingShipmentStateSuccess(data: dataDetailsTracking));
      } else {
        log("Error response: $data");
        emit(DetailsTrackingShipmentStateFailure(
            message: data['message'] ??
                "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error, stackTrace) {
      log("ERROR _onGetDetailsTrackingShipmentEvent: $error");
      log("Stack trace: $stackTrace");

      if (error is FormatException) {
        emit(DetailsTrackingShipmentStateFailure(
            message: "Dữ liệu không hợp lệ từ máy chủ"));
      } else if (error is http.ClientException) {
        emit(DetailsTrackingShipmentStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(DetailsTrackingShipmentStateFailure(
            message: "Đã xảy ra lỗi trong quá trình xử lý dữ liệu"));
      }
    }
  }
}
