import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/order_pickup_list_model.dart';
import 'package:scan_barcode_app/data/models/order_pickup/order_pickup_list_shipper_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'shipper_list_order_screen_event.dart';
part 'shipper_list_order_screen_state.dart';

class GetShipperListOrderScreenBloc extends Bloc<ShipperListOrderScreenEvent,
    HandleGetShipperListOrderScreenState> {
  GetShipperListOrderScreenBloc()
      : super(HandleGetShipperListOrderScreenLoading()) {
    on<FetchListOrderPickupShipper>(_onFetchListOrderPickupShipper);
    on<LoadMoreListOrderPickupShipper>(_onLoadMoreListOrderPickupShipper);
  }

  Future<void> _onFetchListOrderPickupShipper(
    FetchListOrderPickupShipper event,
    Emitter<HandleGetShipperListOrderScreenState> emit,
  ) async {
    emit(HandleGetShipperListOrderScreenLoading());
    log({
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
        'pickup_ship_status': event.pickupShipStatus,
        'shipper_id': event.shipperId,
      }
    }.toString());
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
            'pickup_ship_status': event.pickupShipStatus,
            'shipper_id': event.shipperId,
          }
        }),
      );
      final data = jsonDecode(response.body);
      log(data.toString());
      if (data['status'] == 200) {
        final orderPickUpData =
            OrderPickUpListShipperModel.fromJson(data).ordersPickupShipper.data;
        final isEditOrderPickup =
            OrderPickUpListShipperModel.fromJson(data).isEdit;
        emit(HandleGetShipperListOrderScreenSuccess(
            data: orderPickUpData,
            page: 1,
            hasReachedMax: orderPickUpData.length < 10,
            isEdit: isEditOrderPickup));
      } else {
        log("ERROR _onFetchListOrderPickupShipper 1");
        emit(HandleGetShipperListOrderScreenFailure(message: data['message']));
      }
    } catch (error) {
      log("Error parsing JSON: $error");
      if (error is http.ClientException) {
        log("ERROR _onFetchListOrderPickupShipper 2 $error");
        emit(const HandleGetShipperListOrderScreenFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onFetchListOrderPickupShipper 3 $error");
        emit(const HandleGetShipperListOrderScreenFailure(
            message: "Đã có lỗi xảy ra"));
      }
    }
  }

  Future<void> _onLoadMoreListOrderPickupShipper(
    LoadMoreListOrderPickupShipper event,
    Emitter<HandleGetShipperListOrderScreenState> emit,
  ) async {
    if (state is HandleGetShipperListOrderScreenSuccess &&
        !(state as HandleGetShipperListOrderScreenSuccess).hasReachedMax) {
      final currentState = state as HandleGetShipperListOrderScreenSuccess;
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
              'keywords': event.keywords,
              'pickup_ship_status': event.pickupShipStatus,
              'shipper_id': event.shipperId,
            }
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          final orderPickUpData = OrderPickUpListShipperModel.fromJson(data)
              .ordersPickupShipper
              .data;
          final isEditOrderPickup =
              OrderPickUpListShipperModel.fromJson(data).isEdit;
          emit(data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : HandleGetShipperListOrderScreenSuccess(
                  data: currentState.data + orderPickUpData,
                  page: currentState.page + 1,
                  hasReachedMax: orderPickUpData.length < 10,
                  isEdit: isEditOrderPickup));
        } else {
          log("ERROR _onFetchListOrderPickupShipper 1");
          emit(
              HandleGetShipperListOrderScreenFailure(message: data['message']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onFetchListOrderPickupShipper 2 $error");
          emit(const HandleGetShipperListOrderScreenFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onFetchListOrderPickupShipper 3 $error");
          emit(const HandleGetShipperListOrderScreenFailure(
              message: "Đã có lỗi xảy ra"));
        }
      }
    }
  }
}
