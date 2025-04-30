import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/recharge/details_recharge_model.dart';
import 'package:scan_barcode_app/data/models/recharge/recharge_list_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'recharge_history_event.dart';
part 'recharge_history_state.dart';

class ReChargeHistoryBloc
    extends Bloc<ReChargeHistoryEvent, ReChargeHistoryState> {
  ReChargeHistoryBloc() : super(HandleGetListReChargeStateInitial()) {
    on<FetchListReChargeHistory>(_onFetchListReChargeHistory);
    on<LoadMoreListReChargeHistory>(_onLoadMoreListReChargeHistory);
  }

  Future<void> _onFetchListReChargeHistory(
    FetchListReChargeHistory event,
    Emitter<ReChargeHistoryState> emit,
  ) async {
    emit(HandleGetListReChargeStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$listRechangeMoney'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'limit': 10,
          'page': 1,
          'filters': {
            'status': event.status,
            'start_date': event.startDate,
            'end_date': event.endDate,
            'keywords': event.keywords,
            'filter_by': event.keyType
          }
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final reChargeHistoryData = RechargeListModel.fromJson(data).data;
        emit(HandleGetListReChargeStateSuccess(
            data: reChargeHistoryData,
            page: 1,
            hasReachedMax: reChargeHistoryData.length < 10));
      } else {
        log("ERROR _onFetchListReChargeHistory 1");
        emit(HandleGetListReChargeStateFailure(message: data['message']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onFetchListReChargeHistory 2 $error");
        emit(const HandleGetListReChargeStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onFetchListReChargeHistory 3");
        emit(HandleGetListReChargeStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListReChargeHistory(
    LoadMoreListReChargeHistory event,
    Emitter<ReChargeHistoryState> emit,
  ) async {
    if (state is HandleGetListReChargeStateSuccess &&
        !(state as HandleGetListReChargeStateSuccess).hasReachedMax) {
      final currentState = state as HandleGetListReChargeStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$listRechangeMoney'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'limit': 10,
            'page': currentState.page + 1,
            'fillter': {
              'status': event.status,
              'start_date': event.startDate,
              'end_date': event.endDate,
              'key_word': event.keywords,
              'key_type': event.keyType
            }
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          final reChargeHistoryData = RechargeListModel.fromJson(data).data;
          emit(data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : HandleGetListReChargeStateSuccess(
                  data: currentState.data + reChargeHistoryData,
                  page: currentState.page + 1,
                  hasReachedMax: reChargeHistoryData.length < 10,
                ));
        } else {
          log("ERROR _onLoadMoreListReChargeHistory 1");
          emit(HandleGetListReChargeStateFailure(message: data['message']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onLoadMoreListReChargeHistory 2 $error");
          emit(const HandleGetListReChargeStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreListReChargeHistory 3");
          emit(HandleGetListReChargeStateFailure(message: error.toString()));
        }
      }
    }
  }
}

class DetailsReChargeHistoryBloc
    extends Bloc<DetailsReChargeHistoryEvent, GetDetailsReChargeHistoryState> {
  DetailsReChargeHistoryBloc() : super(HandleGetDetailsReChargeStateInitial()) {
    on<HandleGetDetailsReChargeHistory>(_onHandleGetDetailsReChargeHistory);
  }

  Future<void> _onHandleGetDetailsReChargeHistory(
    HandleGetDetailsReChargeHistory event,
    Emitter<GetDetailsReChargeHistoryState> emit,
  ) async {
    emit(HandleGetDetailsReChargeLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$detailsRechangeMoney'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({'is_api': true, 'recharge_id': event.chanrgeID}),
      );

      final data = jsonDecode(response.body);
      log("Response data: $data");

      if (data['status'] == 200) {
        try {
          final detailsDataRechargeData =
              DetailsDataRechargeModel.fromJson(data);
          emit(HandleGetDetailsReChargeSuccess(data: detailsDataRechargeData));
        } catch (parseError) {
          log("ERROR: Data parsing failed: $parseError");
          emit(HandleGetDetailsReChargeFailure(
              message: "Lỗi xử lý dữ liệu: $parseError"));
        }
      } else {
        log("ERROR: API returned status ${data['status']}");
        emit(HandleGetDetailsReChargeFailure(
            message: data['message'] ?? "Lỗi không xác định"));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR: Network error: $error");
        emit(const HandleGetDetailsReChargeFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR: Unexpected error: $error");
        emit(HandleGetDetailsReChargeFailure(message: error.toString()));
      }
    }
  }
}
