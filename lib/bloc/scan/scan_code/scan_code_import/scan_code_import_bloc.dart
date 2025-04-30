import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:equatable/equatable.dart';
import 'package:scan_barcode_app/data/models/scan_code/details_package.dart';
import 'package:scan_barcode_app/data/models/scan_code/list_all_surchage_goods.dart';
import 'package:scan_barcode_app/data/models/scan_code/surchage_goods_choosed.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
part 'scan_code_import_event.dart';
part 'scan_code_import_state.dart';

class ScanImportBloc extends Bloc<ScanCodeImportEvent, ScanCodeImportState> {
  ScanImportBloc() : super(ScanCodeImportStateInitial()) {
    on<HanldeScanCodeImport>(_onHanldeScanCodeImport);
    on<GetDetailsPackage>(_onGetDetailsPackage);
    on<GetListSurchageGoods>(_onGetListSurchageGoods);
  }

  Future<void> _onHanldeScanCodeImport(
    HanldeScanCodeImport event,
    Emitter<ScanCodeImportState> emit,
  ) async {
    emit(ScanCodeImportStateLoading());
    final response = await http.post(
      Uri.parse('$baseUrl$updateScanStatus'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'code': event.code,
        'status': 1,
        'surchage_goods_choosed': event.listSurchageGoodsChoosed
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    try {
      if (data['status'] == 200) {
        log("_onHanldeScanCodeImport OKOK ");
        emit(ScanCodeImportStateSuccess(message: mess['text']));
      } else if (data['status'] == 404) {
        log("_onHanldeScanCodeImport 404 ");
        emit(ScanCodeImportStateFailure(message: mess['text']));
      } else {
        log("ERROR _onHanldeScanCodeImport 1");
        emit(ScanCodeImportStateFailure(message: mess['text']));
      }
    } catch (error) {
      log("ERROR _onHanldeScanCodeImport $error");
      if (error is http.ClientException) {
        emit(const ScanCodeImportStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(ScanCodeImportStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onGetDetailsPackage(
    GetDetailsPackage event,
    Emitter<ScanCodeImportState> emit,
  ) async {
    emit(GetDetailsPackageStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getDetailsPackage'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({'is_api': true, 'code': event.mawbCode, 'status': 1}),
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
  }

  Future<void> _onGetListSurchageGoods(
    GetListSurchageGoods event,
    Emitter<ScanCodeImportState> emit,
  ) async {
    emit(GetListSurchageGoodsStateLoading());
    final response = await http.post(
      Uri.parse('$baseUrl$getListSurchangeGoods'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    try {
      if (data['status'] == 200) {
        log("_onGetListSurchageGoods OKOK ");
        emit(GetListSurchageGoodsStateSuccess(
            listAllSurchageGoodsModel:
                ListAllSurchageGoodsModel.fromJson(data)));
      } else if (data['status'] == 404) {
        log("_onGetListSurchageGoods 404 ");
        emit(GetListSurchageGoodsStateFailure(message: mess['text']));
      } else {
        log("ERROR _onGetListSurchageGoods 1");
        emit(GetListSurchageGoodsStateFailure(message: mess['text']));
      }
    } catch (error) {
      log("ERROR _onGetListSurchageGoods $error");
      if (error is http.ClientException) {
        emit(const GetListSurchageGoodsStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(GetListSurchageGoodsStateFailure(message: error.toString()));
      }
    }
  }
}
