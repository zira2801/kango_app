import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:equatable/equatable.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
part 'scan_code_return_event.dart';
part 'scan_code_return_state.dart';

class ScanReturnBloc extends Bloc<ScanCodeReturnEvent, ScanCodeReturnState> {
  ScanReturnBloc() : super(ScanCodeReturnStateInitial()) {
    on<HanldeScanCodeReturn>(_onHanldeScanCodeReturn);
  }

  Future<void> _onHanldeScanCodeReturn(
    HanldeScanCodeReturn event,
    Emitter<ScanCodeReturnState> emit,
  ) async {
    emit(ScanCodeReturnStateLoading());
    final response = await http.post(
      Uri.parse('$baseUrl$updateScanStatus'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'code': event.code,
        'status': 3,
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    try {
      if (data['status'] == 200) {
        log("_onHanldeScanCodeReturn OKOK ");
        emit(ScanCodeReturnStateSuccess(message: mess['text']));
      } else if (data['status'] == 404) {
        log("_onHanldeScanCodeReturn 404 ");
        emit(ScanCodeReturnStateFailure(message: mess['text']));
      } else {
        log("ERROR _onHanldeScanCodeReturn 1");
        emit(ScanCodeReturnStateFailure(message: mess['text']));
      }
    } catch (error) {
      log("ERROR _onHanldeScanCodeReturn $error");
      if (error is http.ClientException) {
        emit(const ScanCodeReturnStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(ScanCodeReturnStateFailure(message: error.toString()));
      }
    }
  }
}
