import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:equatable/equatable.dart';
import 'package:scan_barcode_app/data/models/scan_code/list_mawb_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
part 'scan_code_export_event.dart';
part 'scan_code_export_state.dart';

class ScanExportBloc extends Bloc<ScanCodeExportEvent, ScanCodeExportState> {
  ScanExportBloc() : super(ScanCodeExportStateInitial()) {
    on<HanldeScanCodeExport>(_onHanldeScanCodeExport);
  }

  Future<void> _onHanldeScanCodeExport(
    HanldeScanCodeExport event,
    Emitter<ScanCodeExportState> emit,
  ) async {
    emit(ScanCodeExportStateLoading());
    log({
      'code': event.code,
      'status': 2,
      'sm_tracktry_id': event.smTracktryID,
      // 'package_image': event.packageImage,
      'bag_code': event.bagCode
    }.toString());
    final response = await http.post(
      Uri.parse('$baseUrl$updateScanStatus'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'code': event.code,
        'status': 2,
        'sm_tracktry_id': event.smTracktryID,
        'package_image': event.packageImage,
        'bag_code': event.bagCode
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    try {
      if (data['status'] == 200) {
        log("_onHanldeScanCodeExport OKOK ");
        emit(ScanCodeExportStateSuccess(message: mess['text']));
      } else if (data['status'] == 404) {
        log("_onHanldeScanCodeExport 404 ");
        emit(ScanCodeExportStateFailure(message: mess['text']));
      } else {
        log("ERROR _onHanldeScanCodeExport 1");
        emit(ScanCodeExportStateFailure(message: mess['text']));
      }
    } catch (error) {
      log("ERROR _onHanldeScanCodeExport $error");
      if (error is http.ClientException) {
        emit(const ScanCodeExportStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(ScanCodeExportStateFailure(message: error.toString()));
      }
    }
  }
}
