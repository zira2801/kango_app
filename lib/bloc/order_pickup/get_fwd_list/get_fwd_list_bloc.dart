import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/fwd/fwd_list_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'get_fwd_list_event.dart';
part 'get_fwd_list_state.dart';

class GetListFWDScreenBloc extends Bloc<FWDScreenEvent, HandleGetListFWDState> {
  GetListFWDScreenBloc() : super(HandleGetListFWDLoading()) {
    on<FetchListFWD>(_onFetchListFWD);
    on<LoadMoreListFWD>(_onLoadMoreListFWD);
  }

  Future<void> _onFetchListFWD(
    FetchListFWD event,
    Emitter<HandleGetListFWDState> emit,
  ) async {
    emit(HandleGetListFWDLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListFwd'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'limit': 15,
          'page': 1,
          'filters': {'keywords': event.keywords}
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final fwdData = FwdListModel.fromJson(data).data.data;
        emit(HandleGetListFWDSuccess(
          data: fwdData,
          page: 1,
          hasReachedMax: fwdData.length < 15,
        ));
      } else {
        emit(HandleGetListFWDFailure(message: data['message']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        emit(const HandleGetListFWDFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(const HandleGetListFWDFailure(message: "Đã có lỗi xảy ra"));
      }
    }
  }

  Future<void> _onLoadMoreListFWD(
    LoadMoreListFWD event,
    Emitter<HandleGetListFWDState> emit,
  ) async {
    if (state is HandleGetListFWDSuccess &&
        !(state as HandleGetListFWDSuccess).hasReachedMax) {
      final currentState = state as HandleGetListFWDSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getListFwd'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'limit': 15,
            'page': currentState.page + 1,
            'filters': {'keywords': event.keywords}
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          final fwdData = FwdListModel.fromJson(data).data.data;
          emit(data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : HandleGetListFWDSuccess(
                  data: currentState.data + fwdData,
                  page: currentState.page + 1,
                  hasReachedMax: fwdData.length < 15,
                ));
        } else {
          emit(HandleGetListFWDFailure(message: data['message']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          emit(const HandleGetListFWDFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          emit(const HandleGetListFWDFailure(message: "Đã có lỗi xảy ra"));
        }
      }
    }
  }
}
