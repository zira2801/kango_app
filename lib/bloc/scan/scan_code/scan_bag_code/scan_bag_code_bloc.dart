import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:equatable/equatable.dart';
import 'package:scan_barcode_app/data/models/scan_code/list_mawb_model.dart';
import 'package:scan_barcode_app/data/models/scan_code/scan_bag_code_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
part 'scan_bag_code_event.dart';
part 'scan_bag_code_state.dart';

class ScanBagCodeBloc extends Bloc<ScanBagCodeEvent, ScanBagCodeState> {
  ScanBagCodeBloc() : super(ScanBagCodeStateInitial()) {
    on<HanldeScanBagCode>(_onHanldeScanBagCode);
  }

  Future<void> _onHanldeScanBagCode(
    HanldeScanBagCode event,
    Emitter<ScanBagCodeState> emit,
  ) async {
    emit(ScanBagCodeStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$scanBagCodeApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'bag_code': event.bagCode,
          'sm_tracktry_id': event.smTracktryID,
        }),
      );

      final data = jsonDecode(response.body);
      var mess = data['message'];

      if (data['status'] == 200) {
        log("_onHanldeScanBagCode Success");
        emit(ScanBagCodeStateSuccess(
            scanBagCodeModel: ScanBagCodeModel.fromJson(data)));
      } else if (data['status'] == 404) {
        log("_onHanldeScanBagCode Not Found");
        // Handle already scanned packages with a specific error message
        final errorMessage =
            mess['text'] ?? 'Package không tồn tại hoặc đã được scan';
        emit(ScanBagCodeStateFailure(message: errorMessage));
      } else {
        log("_onHanldeScanBagCode Error 1");
        final errorMessage = mess['text'] ?? 'Có lỗi xảy ra';
        emit(ScanBagCodeStateFailure(message: errorMessage));
      }
    } catch (error) {
      log("ERROR _onHanldeScanBagCode Error 2 $error");
      String errorMessage = "Có lỗi xảy ra";
      if (error is http.ClientException) {
        errorMessage = "Không thể kết nối đến máy chủ";
      }
      emit(ScanBagCodeStateFailure(message: errorMessage));
    }
  }
}
