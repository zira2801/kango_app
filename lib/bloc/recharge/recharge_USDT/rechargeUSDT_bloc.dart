import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'rechargeUSDT_event.dart';
part 'rechargeUSDT_state.dart';

class ReChargeUSDTBloc extends Bloc<ReChargeUSDTSEvent, ReChargeUSDTState> {
  ReChargeUSDTBloc() : super(RequestReChargeUSDTStateInitial()) {
    on<HandleReChargeUSDT>(_onHandleReChargeUSDT);
  }

  Future<void> _onHandleReChargeUSDT(
    HandleReChargeUSDT event,
    Emitter<ReChargeUSDTState> emit,
  ) async {
    emit(RequestReChargeUSDTStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$requestRechangeMoney'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'usdt_price': event.usdt_price,
          'type': event.type,
          'amount': event.amount,
          'note': event.note,
          'image': event.image,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        log("SUCCESS _onHandleReChargeUSDT $data['message']");
        emit(RequestReChargeUSDTStateSuccess(message: data['message']));
      } else {
        log("ERROR _onHandleReChargeUSDT 1 $data['message']");
        emit(RequestReChargeUSDTFailure(message: data['message']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onHandleReChargeUSDT 2 $error");
        emit(const RequestReChargeUSDTFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onHandleReChargeUSDT 3");
        emit(RequestReChargeUSDTFailure(message: error.toString()));
      }
    }
  }
}
