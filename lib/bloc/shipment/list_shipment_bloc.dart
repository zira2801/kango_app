import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/list_shipment.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'list_shipment_event.dart';
part 'list_shipment_state.dart';

class ListShipmentBloc extends Bloc<ListShipmentEvent, ListShipmentState> {
  ListShipmentBloc() : super(ListShipmentStateInitial()) {
    on<FetchListShipment>(_onFetchListShipment);
    on<LoadMoreListShipment>(_onLoadMoreListShipment);
  }

  Future<void> _onFetchListShipment(
    FetchListShipment event,
    Emitter<ListShipmentState> emit,
  ) async {
    emit(ListShipmentStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListShipment'),
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
            'shipment_branch_id': event.branchId,
            'shipment_status': event.status,
            'shipment_payment_status': event.statusPayment,
            'shipment_service_id': event.shipmentServiceId,
            'keywords': event.keywords,
            'filter_by': event.searchMethod
          }
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final listShipmentData =
            ListShipmentModel.fromJson(data).shipments.data;

        emit(ListShipmentStateSuccess(
            data: listShipmentData,
            page: 1,
            hasReachedMax: listShipmentData.length < 10));
      } else {
        log("ERROR _onFetchListShipment 1");
        emit(const ListShipmentStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onFetchListShipment 2 $error");
      if (error is http.ClientException) {
        emit(const ListShipmentStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(ListShipmentStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListShipment(
    LoadMoreListShipment event,
    Emitter<ListShipmentState> emit,
  ) async {
    if (state is ListShipmentStateSuccess &&
        !(state as ListShipmentStateSuccess).hasReachedMax) {
      final currentState = state as ListShipmentStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getListShipment'),
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
              'shipment_branch_id': event.branchId,
              'shipment_status': event.status,
              'shipment_payment_status': event.statusPayment,
              'keywords': event.keywords,
              'filter_by': event.searchMethod
            }
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          final listShipmentData =
              ListShipmentModel.fromJson(data).shipments.data;
          emit(data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : ListShipmentStateSuccess(
                  data: currentState.data + listShipmentData,
                  page: currentState.page + 1,
                  hasReachedMax: listShipmentData.length < 10,
                ));
        } else {
          log("ERROR _onLoadMoreListShipment 1");
          emit(const ListShipmentStateFailure(
              message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
        }
      } catch (error) {
        log("ERROR _onLoadMoreListShipment 2 $error");
        if (error is http.ClientException) {
          emit(const ListShipmentStateFailure(
              message: "Không thể kết nối với máy chủ"));
        } else {
          emit(ListShipmentStateFailure(message: error.toString()));
        }
      }
    }
  }
}

class DeleteShipmentBloc
    extends Bloc<DeleteShipmentEvent, DeleteShipmentState> {
  DeleteShipmentBloc() : super(DeleteShipmentStateInitial()) {
    on<HanldeDeleteShipment>(_onDeleteShipmentEvent);
  }

  Future<void> _onDeleteShipmentEvent(
    HanldeDeleteShipment event,
    Emitter<DeleteShipmentState> emit,
  ) async {
    emit(DeleteShipmentStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$deleteShipmentApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'shipment_code': event.shipmentCode,
        }),
      );
      final data = jsonDecode(response.body);
      var mess = data['message'];
      var mesRes = mess['text'];
      if (data['status'] == 200) {
        emit(DeleteShipmentStateSuccess(message: mesRes));
      } else {
        log("ERROR _onDeleteShipmentEvent 1");
        emit(DeleteShipmentStateFailure(message: mesRes));
      }
    } catch (error) {
      log("ERROR _onDeleteShipmentEvent 2 $error");
      if (error is http.ClientException) {
        emit(const DeleteShipmentStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(DeleteShipmentStateFailure(message: error.toString()));
      }
    }
  }
}

class DetailsShipmentBloc
    extends Bloc<DetailsShipmentEvent, DetailsShipmentState> {
  DetailsShipmentBloc() : super(DetailsShipmentStateInitial()) {
    on<HanldeDetailsShipment>(_onHanldeDetailsShipment);
  }

  Future<void> _onHanldeDetailsShipment(
    HanldeDetailsShipment event,
    Emitter<DetailsShipmentState> emit,
  ) async {
    emit(DetailsShipmentStateLoading());
    log(event.shipmentCode.toString());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getDetailsShipmentApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'shipment_code': event.shipmentCode,
        }),
      );
      final data = jsonDecode(response.body);
      // log("Details API Response: $data"); // Thêm log này

      if (data['status'] == 200) {
        final details = DetailsShipmentModel.fromJson(data);
        log("Parsed Package Items: ${details.shipment.packages}"); // Thêm log này
        emit(DetailsShipmentStateSuccess(
          detailsShipmentModel: details,
          isMoreDetail: event.isMoreDetail!,
        ));
      } else {
        String mess = data['message'];
        log("ERROR DetailsShipmentBloc 1 $mess");
        emit(DetailsShipmentStateFailure(message: mess));
      }
    } catch (error) {
      log("ERROR DetailsShipmentBloc 2 $error");
      if (error is http.ClientException) {
        emit(const DetailsShipmentStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(DetailsShipmentStateFailure(message: error.toString()));
      }
    }
  }
}
