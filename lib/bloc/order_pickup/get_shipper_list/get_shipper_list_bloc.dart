import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/list_shipper_free/list_shipper_free_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'get_shipper_list_event.dart';
part 'get_shipper_list_state.dart';

class GetListShipperFreeScreenBloc
    extends Bloc<ShipperFreeScreenEvent, HandleGetListShipperFreeState> {
  GetListShipperFreeScreenBloc() : super(HandleGetListShipperFreeLoading()) {
    on<FetchListShipperFree>(_onFetchListFWD);
    on<LoadMoreListShipperFree>(_onLoadMoreListFWD);
  }

  Future<void> _onFetchListFWD(
    FetchListShipperFree event,
    Emitter<HandleGetListShipperFreeState> emit,
  ) async {
    emit(HandleGetListShipperFreeLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$listShipperFree'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'limit': 10,
          'page': 1,
          'filters': {'keywords': event.keywords}
        }),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        final listShipperFreeData =
            ListShipperFreeModel.fromJson(data).shippers.data;
        emit(HandleGetListShipperFreeSuccess(
          data: listShipperFreeData,
          page: 1,
          hasReachedMax: listShipperFreeData.length < 10,
        ));
        log("SHIPPER LIST OKOK");
      } else {
        log("SHIPPER LIST ERROR 1");
        emit(HandleGetListShipperFreeFailure(message: data['message']));
      }
    } catch (error) {
      ;
      if (error is http.ClientException) {
        log("SHIPPER LIST ERROR 2");
        emit(const HandleGetListShipperFreeFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("SHIPPER LIST ERROR $error");
        emit(
            const HandleGetListShipperFreeFailure(message: "Đã có lỗi xảy ra"));
      }
    }
  }

  Future<void> _onLoadMoreListFWD(
    LoadMoreListShipperFree event,
    Emitter<HandleGetListShipperFreeState> emit,
  ) async {
    if (state is HandleGetListShipperFreeSuccess &&
        !(state as HandleGetListShipperFreeSuccess).hasReachedMax) {
      final currentState = state as HandleGetListShipperFreeSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$listShipperFree'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'limit': 10,
            'page': currentState.page + 1,
            'filters': {'keywords': event.keywords}
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          final listShipperFreeData =
              ListShipperFreeModel.fromJson(data).shippers.data;
          emit(data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : HandleGetListShipperFreeSuccess(
                  data: currentState.data + listShipperFreeData,
                  page: currentState.page + 1,
                  hasReachedMax: listShipperFreeData.length < 10,
                ));
          log("MORE SHIPPER LIST OKOK");
        } else {
          log("MORE SHIPPER LIST ERROR 1");
          emit(HandleGetListShipperFreeFailure(message: data['message']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("MORE SHIPPER LIST ERROR 2");
          emit(const HandleGetListShipperFreeFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("MORE SHIPPER LIST ERROR $error");
          emit(const HandleGetListShipperFreeFailure(
              message: "Đã có lỗi xảy ra"));
        }
      }
    }
  }
}
