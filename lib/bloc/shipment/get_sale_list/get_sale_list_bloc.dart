import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/sale/sale_list_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'get_sale_list_event.dart';
part 'get_sale_list_state.dart';

class GetListSaleScreenBloc
    extends Bloc<SaleScreenEvent, HandleGetListSaleState> {
  GetListSaleScreenBloc() : super(HandleGetListSaleLoading()) {
    on<FetchListSale>(_onFetchListFWD);
    on<LoadMoreListSale>(_onLoadMoreListFWD);
  }

  Future<void> _onFetchListFWD(
    FetchListSale event,
    Emitter<HandleGetListSaleState> emit,
  ) async {
    emit(HandleGetListSaleLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListSale'),
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
        final saleData = SaleListModel.fromJson(data).data.data;
        emit(HandleGetListSaleSuccess(
          data: saleData,
          page: 1,
          hasReachedMax: saleData.length < 15,
        ));
      } else {
        log("ERROR _onFetchListFWD 1 $data['message']");
        emit(HandleGetListSaleFailure(message: data['message']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onFetchListFWD 2");
        emit(const HandleGetListSaleFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onFetchListFWD 3");
        emit(const HandleGetListSaleFailure(message: "Đã có lỗi xảy ra"));
      }
    }
  }

  Future<void> _onLoadMoreListFWD(
    LoadMoreListSale event,
    Emitter<HandleGetListSaleState> emit,
  ) async {
    if (state is HandleGetListSaleSuccess &&
        !(state as HandleGetListSaleSuccess).hasReachedMax) {
      final currentState = state as HandleGetListSaleSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getListSale'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'limit': 15,
            'page': currentState.page + 1,
            'filters': {'keywords': event.keywords}
          }),
        );

        // Log the raw response for debugging
        log("LoadMore Raw response: ${response.body}");

        // Check if response body is empty or invalid
        if (response.body.isEmpty) {
          emit(const HandleGetListSaleFailure(
              message: "Không nhận được dữ liệu từ máy chủ"));
          return;
        }

        final data = jsonDecode(response.body);

        // Validate that data is a Map and has a 'status' field
        if (data is! Map<String, dynamic> || data['status'] == null) {
          emit(const HandleGetListSaleFailure(
              message: "Dữ liệu phản hồi không hợp lệ"));
          return;
        }

        if (data['status'] == 200) {
          final saleData = SaleListModel.fromJson(data).data.data ?? [];
          emit(saleData.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : HandleGetListSaleSuccess(
                  data: currentState.data + saleData,
                  page: currentState.page + 1,
                  hasReachedMax: saleData.length < 15,
                ));
        } else {
          // Safely handle missing 'message' field
          final errorMessage = data['message']['text'] as String? ??
              "Lỗi không xác định từ máy chủ";
          emit(HandleGetListSaleFailure(message: errorMessage));
        }
      } catch (error) {
        // Detailed error handling
        if (error is http.ClientException) {
          log("LoadMore Error: Network issue - $error");
          emit(const HandleGetListSaleFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else if (error is FormatException) {
          log("LoadMore Error: JSON parsing failed - $error");
          emit(const HandleGetListSaleFailure(
              message: "Dữ liệu không đúng định dạng"));
        } else {
          log("LoadMore Error: Unexpected error - $error");
          emit(HandleGetListSaleFailure(message: "Đã có lỗi xảy ra: $error"));
        }
      }
    }
  }
}
