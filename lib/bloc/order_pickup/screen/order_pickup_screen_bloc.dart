import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_event.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/order_pickup_list_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'order_pickup_screen_event.dart';
part 'order_pickup_screen_state.dart';

class GetListOrderPickupScreenBloc
    extends Bloc<OrderPickupScreenEvent, HandleGetListOrderPickupState> {
  GetListOrderPickupScreenBloc() : super(HandleGetListOrderPickupLoading()) {
    on<FetchListOrderPickup>(_onFetchListOrderPickup);
    on<LoadMoreListOrderPickup>(_onLoadMoreListOrderPickup);
    on<HandleDeleteOrderPickUp>(_onHandleDeleteOrderPickUp);
  }

  Future<void> _onFetchListOrderPickup(
    FetchListOrderPickup event,
    Emitter<HandleGetListOrderPickupState> emit,
  ) async {
    emit(HandleGetListOrderPickupLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$orderPickUpPaginationApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'limit': 10,
          'page': 1,
          'filters': {
            'date_range': {
              'start_date': event.startDate,
              'end_date': event.endDate
            },
            'order_pickup_status': event.status,
            'branch_id': event.branchId,
            'keywords': event.keywords,
            'fwd_id': event.fwdId
          }
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final orderPickUpData =
            OrderPickUpListModel.fromJson(data).ordersPickup.data;
        final isEditOrderPickup = OrderPickUpListModel.fromJson(data).isEdit;
        emit(HandleGetListOrderPickupSuccess(
            data: orderPickUpData,
            page: 1,
            hasReachedMax: orderPickUpData.length < 10,
            isEdit: isEditOrderPickup));
      } else {
        log("_onFetchListOrderPickup ERROR 1");
        emit(HandleGetListOrderPickupFailure(message: data['message']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("_onFetchListOrderPickup ERROR 2 $error");
        emit(const HandleGetListOrderPickupFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("_onFetchListOrderPickup ERROR 3 $error");
        emit(
            const HandleGetListOrderPickupFailure(message: "Đã có lỗi xảy ra"));
      }
    }
  }

  Future<void> _onLoadMoreListOrderPickup(
    LoadMoreListOrderPickup event,
    Emitter<HandleGetListOrderPickupState> emit,
  ) async {
    if (state is HandleGetListOrderPickupSuccess &&
        !(state as HandleGetListOrderPickupSuccess).hasReachedMax) {
      final currentState = state as HandleGetListOrderPickupSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$orderPickUpPaginationApi'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'limit': 10,
            'page': currentState.page + 1,
            'filters': {
              'date_range': {
                'start_date': event.startDate,
                'end_date': event.endDate
              },
              'order_pickup_status': event.status,
              'branch_id': event.branchId,
              'keywords': event.keywords
            }
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          final orderPickUpData =
              OrderPickUpListModel.fromJson(data).ordersPickup.data;
          final isEditOrderPickup = OrderPickUpListModel.fromJson(data).isEdit;
          emit(data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : HandleGetListOrderPickupSuccess(
                  data: currentState.data + orderPickUpData,
                  page: currentState.page + 1,
                  hasReachedMax: orderPickUpData.length < 10,
                  isEdit: isEditOrderPickup));
        } else {
          log("_onLoadMoreListOrderPickup ERROR 1");
          emit(HandleGetListOrderPickupFailure(message: data['message']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("_onLoadMoreListOrderPickup ERROR 2 $error");
          emit(const HandleGetListOrderPickupFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("_onLoadMoreListOrderPickup ERROR 3 $error");
          emit(const HandleGetListOrderPickupFailure(
              message: "Đã có lỗi xảy ra"));
        }
      }
    }
  }

  Future<void> _onHandleDeleteOrderPickUp(
    HandleDeleteOrderPickUp event,
    Emitter<HandleGetListOrderPickupState> emit,
  ) async {
    emit(HandleDeleteOrderPickUpLoading());

    const url = '$baseUrl$deleteOrderPickUpAPI';
    final headers = ApiUtils.getHeaders(isNeedToken: true);
    final body = jsonEncode({
      'is_api': true,
      'order_pickup_id': event.orderPickupID,
      'order_pickup_cancel_des': event.orderCancelDes,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      final data = jsonDecode(response.body);
      var mess = data[
          'message']; // Đây là một Map<String, dynamic>, không phải String.
      log('API URL: $url');
      log('Request Body: $body');
      log('Response Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (data['status'] == 200) {
          var messageText =
              mess['text']; // Lấy thông điệp  từ trường 'text' trong 'message'
          emit(HandleDeleteOrderPickUpSuccess(message: messageText));
          log('_onHandleDeleteOrderPickUp error: $messageText');
        } else {
          var messageText = mess[
              'text']; // Lấy thông điệp lỗi từ trường 'text' trong 'message'
          log('_onHandleDeleteOrderPickUp error: $messageText');
          emit(HandleDeleteOrderPickUpFailure(message: messageText));
        }
      } else {
        var messageText = mess['text'];
        // Nếu mã trạng thái không phải 200, hiển thị thông báo lỗi từ server
        emit(HandleDeleteOrderPickUpFailure(
            message: 'Lỗi: ${messageText}, vui lòng thử lại.'));
      }
    } catch (error) {
      log('_onHandleDeleteOrderPickUp exception: $error');
      if (error is http.ClientException) {
        emit(const HandleDeleteOrderPickUpFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(HandleDeleteOrderPickUpFailure(message: error.toString()));
      }
    }
  }
}
