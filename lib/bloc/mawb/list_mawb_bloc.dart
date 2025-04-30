import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_barcode_app/bloc/mawb/list_mawb_event.dart';
import 'package:scan_barcode_app/bloc/mawb/list_mawb_state.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/mawb/mawb.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';

class MAWBListBloc extends Bloc<MAWBListEvent, MAWBListState> {
  MAWBListBloc() : super(MAWBListInitial()) {
    on<FetchMAWBList>(_onFetchMAWBList);
    on<LoadMoreMAWBList>(_onLoadMoreMAWBList);
  }

  Future<void> _onFetchMAWBList(
    FetchMAWBList event,
    Emitter<MAWBListState> emit,
  ) async {
    emit(MAWBListLoading());

    try {
      // Get current year for date range
      final now = DateTime.now();
      final startDate = '01-01-${now.year}';
      final endDate = '31-12-${now.year}';

      final response = await http.post(
        Uri.parse('$baseUrl$getListMAWBApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          "paginate": {"page": 1, "limit": 10},
          "filters": {
            "date_range": {"start_date": startDate, "end_date": endDate},
            "keywords": event.keywords,
            "tracking_status": event.trackingStatus
          }
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final mawbList = MAWBTrackingModel.fromJson(data).shipmentsTracktry;
        emit(MAWBListSuccess(
          data: mawbList,
          page: 1,
          hasReachedMax: mawbList.length < 10,
        ));
      } else {
        log("ERROR _onFetchMAWBList 1");
        emit(const MAWBListFailure(
          message: "Đã xảy ra lỗi trong quá trình xử lý dữ liệu.",
        ));
      }
    } catch (error) {
      log("ERROR _onFetchMAWBList 2 $error");
      if (error is http.ClientException) {
        emit(const MAWBListFailure(
          message: "Không thể kết nối với máy chủ",
        ));
      } else {
        emit(MAWBListFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreMAWBList(
    LoadMoreMAWBList event,
    Emitter<MAWBListState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is MAWBListSuccess) {
        final now = DateTime.now();
        final startDate = '01-01-${now.year}';
        final endDate = '31-12-${now.year}';

        final response = await http.post(
          Uri.parse('$baseUrl$getListMAWBApi'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            "paginate": {"page": event.page, "limit": 10},
            "filters": {
              "date_range": {"start_date": startDate, "end_date": endDate},
              "keywords": event.keywords,
              "tracking_status": event.trackingStatus
            }
          }),
        );

        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          final newItems = MAWBTrackingModel.fromJson(data).shipmentsTracktry;
          emit(MAWBListSuccess(
            data: [...currentState.data, ...newItems],
            page: event.page,
            hasReachedMax: newItems.length < 10,
          ));
        } else {
          log("ERROR _onLoadMoreMAWBList 1");
          emit(const MAWBListFailure(
            message: "Đã xảy ra lỗi trong quá trình xử lý dữ liệu.",
          ));
        }
      }
    } catch (error) {
      log("ERROR _onLoadMoreMAWBList 2 $error");
      if (error is http.ClientException) {
        emit(const MAWBListFailure(
          message: "Không thể kết nối với máy chủ",
        ));
      } else {
        emit(MAWBListFailure(message: error.toString()));
      }
    }
  }
}
