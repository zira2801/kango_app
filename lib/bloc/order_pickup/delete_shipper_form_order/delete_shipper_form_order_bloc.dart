import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'delete_shipper_form_order_event.dart';
part 'delete_shipper_form_order_state.dart';

class DeleteShipperFormBloc
    extends Bloc<DeleteShipperFormOrderEvent, DeleteShipperFormOrderState> {
  DeleteShipperFormBloc() : super(DeleteShipperFormOrderStateInitial()) {
    on<HandleDeleteShipperFormOrder>(_onHandleDeleteShipperFormOrder);
  }

  Future<void> _onHandleDeleteShipperFormOrder(
    HandleDeleteShipperFormOrder event,
    Emitter<DeleteShipperFormOrderState> emit,
  ) async {
    emit(DeleteShipperFormOrderStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$deleteShipperFormOrder'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'order_pickup_id': event.orderPickupID,
        }),
      );
      final data = jsonDecode(response.body);
      var mess = data['message'];
      if (data['status'] == 200) {
        log("_onHandleDeleteShipperFormOrder OKOK");
        emit(DeleteShipperFormOrderStateSuccess(message: mess['text']));
      } else {
        log("ERROR _onHandleDeleteShipperFormOrder 1");
        emit(DeleteShipperFormOrderStateFailure(message: mess['text']));
      }
    } catch (error) {
      log("ERROR _onHandleDeleteShipperFormOrder 2 $error");
      if (error is http.ClientException) {
        emit(const DeleteShipperFormOrderStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(DeleteShipperFormOrderStateFailure(message: error.toString()));
      }
    }
  }
}
