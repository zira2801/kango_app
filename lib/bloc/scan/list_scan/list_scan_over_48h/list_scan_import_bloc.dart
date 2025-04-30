import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/scan_code/list_import_scan.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'list_scan_import_event.dart';
part 'list_scan_import_state.dart';

class ListScanOver48HBloc
    extends Bloc<ListScanOver48HEvent, ListScanOver48HState> {
  ListScanOver48HBloc() : super(ListScanOver48HStateInitial()) {
    on<FetchListScanOver48H>(_onFetchListScanImport);
    on<LoadMoreListScanOver48H>(_onMoreListScanImport);
  }

  Future<void> _onFetchListScanImport(
    FetchListScanOver48H event,
    Emitter<ListScanOver48HState> emit,
  ) async {
    emit(ListScanOver48HStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$historyScan'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          "paginate": {"limit": 10, "page": 1},
          "filters": {"keywords": event.keyWords},
          "over_time": "48",
          "status": event.status
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final scanImportData = ListImportScanModel.fromJson(data).data;
        emit(ListScanOver48HStateSuccess(
            data: scanImportData,
            page: 1,
            hasReachedMax: scanImportData.length < 10));
      } else {
        log("ERROR _onListScanImportEvent 1");
        emit(const ListScanOver48HStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onListScanImportEvent 2 $error");
      if (error is http.ClientException) {
        emit(const ListScanOver48HStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(ListScanOver48HStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onMoreListScanImport(
    LoadMoreListScanOver48H event,
    Emitter<ListScanOver48HState> emit,
  ) async {
    if (state is ListScanOver48HStateSuccess &&
        !(state as ListScanOver48HStateSuccess).hasReachedMax) {
      final currentState = state as ListScanOver48HStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$historyScan'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            "paginate": {"limit": 10, "page": currentState.page + 1},
            "filters": {"key_words": event.keyWords},
            "over_time": "48",
            "status": event.status
            // "status": 5
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          final scanImportData = ListImportScanModel.fromJson(data).data;
          emit(data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : ListScanOver48HStateSuccess(
                  data: currentState.data + scanImportData,
                  page: currentState.page + 1,
                  hasReachedMax: scanImportData.length < 10,
                ));
        } else {
          log("ERROR _onListScanImportEvent 1");
          emit(const ListScanOver48HStateFailure(
              message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
        }
      } catch (error) {
        log("ERROR _onListScanImportEvent 2 $error");
        if (error is http.ClientException) {
          emit(const ListScanOver48HStateFailure(
              message: "Không thể kết nối với máy chủ"));
        } else {
          emit(ListScanOver48HStateFailure(message: error.toString()));
        }
      }
    }
  }
}
