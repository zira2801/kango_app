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

class ListScanImportBloc
    extends Bloc<ListScanImportEvent, ListScanImportState> {
  ListScanImportBloc() : super(ListScanImportStateInitial()) {
    on<FetchListScanImport>(_onFetchListScanImport);
    on<LoadMoreListScanImport>(_onMoreListScanImport);
  }

  Future<void> _onFetchListScanImport(
    FetchListScanImport event,
    Emitter<ListScanImportState> emit,
  ) async {
    emit(ListScanImportStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$historyScan'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          "paginate": {"limit": 10, "page": 1},
          "filters": {"keywords": event.keyWords},
          "over_time": event.overTime,
          "status": event.status
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final scanImportData = ListImportScanModel.fromJson(data).data;
        emit(ListScanImportStateSuccess(
            data: scanImportData,
            page: 1,
            hasReachedMax: scanImportData.length < 10));
      } else {
        log("ERROR _onListScanImportEvent 1");
        emit(const ListScanImportStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onListScanImportEvent 2 $error");
      if (error is http.ClientException) {
        emit(const ListScanImportStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(ListScanImportStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onMoreListScanImport(
    LoadMoreListScanImport event,
    Emitter<ListScanImportState> emit,
  ) async {
    if (state is ListScanImportStateSuccess &&
        !(state as ListScanImportStateSuccess).hasReachedMax) {
      final currentState = state as ListScanImportStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$historyScan'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            "paginate": {"limit": 10, "page": currentState.page + 1},
            "filters": {"key_words": event.keyWords},
            "over_time": event.overTime,
            "status": event.status
            // "status": 5
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          final scanImportData = ListImportScanModel.fromJson(data).data;
          emit(data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : ListScanImportStateSuccess(
                  data: currentState.data + scanImportData,
                  page: currentState.page + 1,
                  hasReachedMax: scanImportData.length < 10,
                ));
        } else {
          log("ERROR _onListScanImportEvent 1");
          emit(const ListScanImportStateFailure(
              message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
        }
      } catch (error) {
        log("ERROR _onListScanImportEvent 2 $error");
        if (error is http.ClientException) {
          emit(const ListScanImportStateFailure(
              message: "Không thể kết nối với máy chủ"));
        } else {
          emit(ListScanImportStateFailure(message: error.toString()));
        }
      }
    }
  }
}

class DeleteScanImportBloc
    extends Bloc<DeleteScanImportEvent, DeleteScanImportState> {
  DeleteScanImportBloc() : super(DeleteScanImportStateInitial()) {
    on<HandleDeleteScanImport>(_onHandleDeleteScanImport);
  }

  Future<void> _onHandleDeleteScanImport(
    HandleDeleteScanImport event,
    Emitter<DeleteScanImportState> emit,
  ) async {
    emit(DeleteScanImportStateLoading());

    final response = await http.post(
      Uri.parse('$baseUrl$deleteScanImport'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        "history_id": event.historyID,
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    var messRes = mess['text'];
    try {
      if (data['status'] == 200) {
        emit(DeleteScanImportStateSuccess(successText: messRes));
      } else {
        log("ERROR _onDeleteScanImportEvent 1");
        emit(DeleteScanImportStateFailure(errorText: messRes));
      }
    } catch (error) {
      log("ERROR _onDeleteScanImportEvent 2 $error");
      if (error is http.ClientException) {
        emit(const DeleteScanImportStateFailure(
            errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(DeleteScanImportStateFailure(errorText: error.toString()));
      }
    }
  }
}
