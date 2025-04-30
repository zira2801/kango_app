import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/models/scan_code/details_package.dart';
import 'package:scan_barcode_app/data/models/scan_code/surchage_goods_choose.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';

import '../../../../data/api/index.dart';
import '../../../../data/env/index.dart';

part 'scan_code_transit_event.dart';
part 'scan_code_transit_state.dart';

class ScanInTransitBloc extends Bloc<InTransitScanEvent, InTransitScanState> {
  ScanInTransitBloc() : super(InTransitScanStateInitial()) {
    on<PerformInTransitScanEvent>(_onPerformInTransitScan);
    /* on<GetDetailsPackage>(_onGetDetailsPackage); // Thêm sự kiện này*/
  }

  Future<void> _onPerformInTransitScan(
    PerformInTransitScanEvent event,
    Emitter<InTransitScanState> emit,
  ) async {
    emit(InTransitScanStateLoading());
    final response = await http.post(
      Uri.parse('$baseUrl$updateScanStatus'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'code': event.code,
        'status': 5, // In Transit status
        'bag_code': event.bagCode,
        'sm_tracktry_id': event.smTracktryID,
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    try {
      if (data['status'] == 200) {
        log("_onPerformInTransitScan OKOK ");
        emit(InTransitScanStateSuccess(message: mess['text']));
      } else if (data['status'] == 404) {
        log("_onPerformInTransitScan 404 ");
        emit(InTransitScanStateFailure(message: mess['text']));
      } else {
        log("ERROR _onPerformInTransitScan 1");
        emit(InTransitScanStateFailure(message: mess['text']));
      }
    } catch (error) {
      log("ERROR _onPerformInTransitScan $error");
      if (error is http.ClientException) {
        emit(const InTransitScanStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(InTransitScanStateFailure(message: error.toString()));
      }
    }
  }
/*
  Future<void> _onGetDetailsPackage(
    GetDetailsPackage event,
    Emitter<InTransitScanState> emit,
  ) async {
    emit(GetDetailsPackageStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getDetailsPackage'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode(
            {'is_api': true, 'code': event.mawbCode, 'status': event.status}),
      );

      log('Response status code: ${response.statusCode}');
      log('Response body: ${response.body}');

      final data = jsonDecode(response.body);
      log('Parsed data: $data');

      var mess = data['message'];

      if (data['status'] == 200) {
        log("_onGetDetailsPackage OKOK ");
        emit(GetDetailsPackageStateSuccess(
            detailsPackageScanCodeModel:
                DetailsPackageScanCodeModel.fromJson(data)));
      } else {
        log("ERROR _onGetDetailsPackage: ${mess['text']}");
        emit(GetDetailsPackageStateFailure(
            message: mess['text'] ?? 'Unknown error'));
      }
    } catch (error, stackTrace) {
      log("ERROR _onGetDetailsPackage", error: error, stackTrace: stackTrace);
      if (error is http.ClientException) {
        emit(const GetDetailsPackageStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(GetDetailsPackageStateFailure(message: error.toString()));
      }
    }
  }*/
}
