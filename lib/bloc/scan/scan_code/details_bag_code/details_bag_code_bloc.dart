import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:equatable/equatable.dart';
import 'package:scan_barcode_app/data/models/scan_code/details_bag_code_model.dart';
import 'package:scan_barcode_app/data/models/scan_code/list_mawb_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
part 'details_bag_code_event.dart';
part 'details_bag_code_state.dart';

class DetailsBagCodeBloc
    extends Bloc<DetailsBagCodeEvent, DetailsBagCodeState> {
  DetailsBagCodeBloc() : super(DetailsBagCodeStateInitial()) {
    on<HanldeDetailsBagCode>(_onHanldeDetailsBagCode);
  }

  Future<void> _onHanldeDetailsBagCode(
    HanldeDetailsBagCode event,
    Emitter<DetailsBagCodeState> emit,
  ) async {
    emit(DetailsBagCodeStateLoading());
    final response = await http.post(
      Uri.parse('$baseUrl$scanDetailsExportWithBagCode'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'bag_code': event.bagCode,
        'sm_tracktry_id': event.smTracktryID,
        'code': event.code,
        'status': event.status,
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    log("data: $data");
    try {
      if (data['status'] == 200) {
        log("_onHanldeDetailsCodeExport OKOK ");
        emit(DetailsBagCodeStateSuccess(
            scanDetailsBagCodeModel: ScanDetailsBagCodeModel.fromJson(data)));
      } else {
        log("ERROR _onHanldeDetailsCodeExport 1");
        emit(DetailsBagCodeStateFailure(message: mess['text']));
      }
    } catch (error) {
      log("ERROR _onHanldeDetailsCodeExport $error");
      if (error is http.ClientException) {
        emit(const DetailsBagCodeStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(DetailsBagCodeStateFailure(message: error.toString()));
      }
    }
  }
}
