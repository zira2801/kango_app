import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/audit_epacket/audit_epacket.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';

part 'audit_epacket_event.dart';
part 'audit_epacket_state.dart';

class GetListAuditEpacketBloc
    extends Bloc<AuditEpacketEvent, HandleGetAuditEpacketState> {
  GetListAuditEpacketBloc() : super(HandleGetAuditEpacketStateInitial()) {
    on<FetchListAuditEpacket>(_onFetchListAuditEpacket);
    on<LoadMoreListAuditEpacket>(_onLoadMoreListAudiEpacket);
  }

  Future<void> _onFetchListAuditEpacket(
    FetchListAuditEpacket event,
    Emitter<HandleGetAuditEpacketState> emit,
  ) async {
    emit(HandleGetAuditEpacketStateloading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListAuditEpacket'),
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
            'shipment_branch_id': event.shipmentBranchId,
            'shipment_service_id': event.shipmentServiceId,
            'shipment_status': event.shipmentStatus,
            'shipment_payment_status': event.shipmentStatusPayment,
            'keywords': event.keywords,
            'filter_by': event.filterBy
          }
        }),
      );
      final data = jsonDecode(response.body);
      final mess = data['message'];
      if (data['status'] == 200) {
        final response = AuditEpacketResponse.fromJson(data);
        final auditEpacketData = response.shipments.data;
        log(auditEpacketData.toString());
        final pageCurrent = response.shipments.currentPage;
        emit(HandleGetAuditEpacketStateSuccess(
            data: auditEpacketData,
            page: pageCurrent,
            hasReachedMax: auditEpacketData.length < 10));
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log("ERROR _onFetchListAuditEpacket 1");
        emit(HandleGetAuditEpacketStateFailure(message: mess));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onFetchListAuditEpacket 2 $error");
        emit(const HandleGetAuditEpacketStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onFetchListAuditEpacket 3");
        emit(HandleGetAuditEpacketStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListAudiEpacket(
    LoadMoreListAuditEpacket event,
    Emitter<HandleGetAuditEpacketState> emit,
  ) async {
    if (state is HandleGetAuditEpacketStateSuccess &&
        !(state as HandleGetAuditEpacketStateSuccess).hasReachedMax) {
      final currentState = state as HandleGetAuditEpacketStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getListAuditEpacket'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'limit': 10,
            'page': currentState.page + 1,
            'fillter': {
              "date_range": {
                'start_date': event.startDate,
                'end_date': event.endDate
              },
              'shipment_branch_id': event.shipmentBranchId,
              'shipment_service_id': event.shipmentServiceId,
              'shipment_status': event.shipmentStatus,
              'shipment_payment_status': event.shipmentStatusPayment,
              'keywords': event.keywords,
              'filter_by': event.filterBy
            }
          }),
        );
        final data = jsonDecode(response.body);
        final mess = data['message'];
        if (data['status'] == 200) {
          if (data['status'] == 200) {
            final response = AuditEpacketResponse.fromJson(
                data); // Use same parser as in fetch
            final auditEpacketData = response.shipments.data;
            emit(auditEpacketData.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : HandleGetAuditEpacketStateSuccess(
                    data: currentState.data + auditEpacketData,
                    page: currentState.page + 1,
                    hasReachedMax: auditEpacketData.length < 10,
                  ));
          }
        } else {
          log("ERROR _onLoadMoreListAuditEpacket 1");
          emit(HandleGetAuditEpacketStateFailure(message: mess['text']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onLoadMoreListAuditEpacket $error");
          emit(const HandleGetAuditEpacketStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreListAuditEpacket 3");
          emit(HandleGetAuditEpacketStateFailure(message: error.toString()));
        }
      }
    }
  }
}

class DetailsAuditEpacketBloc
    extends Bloc<DetailsAuditEpacketEvent, DetailsAuditEpacketState> {
  DetailsAuditEpacketBloc() : super(DetailsAuditEpacketStateInitial()) {
    on<HanldeDetailsAuditEpacket>(_onHanldeDetailsAuditEpacket);
  }

  Future<void> _onHanldeDetailsAuditEpacket(
    HanldeDetailsAuditEpacket event,
    Emitter<DetailsAuditEpacketState> emit,
  ) async {
    emit(DetailsAuditEpacketStateLoading());
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
      log("Details API Response: $data"); // Thêm log này

      if (data['status'] == 200) {
        final details = DetailsShipmentModel.fromJson(data);
        log("Parsed Package Items: ${details.shipment.packages}"); // Thêm log này
        emit(DetailsAuditEpacketStateSuccess(
          detailsShipmentModel: details,
          isMoreDetail: event.isMoreDetail!,
        ));
      } else {
        log("ERROR DetailsShipmentBloc 1");
        emit(const DetailsAuditEpacketStateFailure(message: 'Có lỗi xảy ra'));
      }
    } catch (error) {
      log("ERROR DetailsShipmentBloc 2 $error");
      if (error is http.ClientException) {
        emit(const DetailsAuditEpacketStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(DetailsAuditEpacketStateFailure(message: error.toString()));
      }
    }
  }
}

class UpdateAuditEpacketBloc
    extends Bloc<UpdateAuditEpacketEvent, UpdateNoteAuditEpacketState> {
  UpdateAuditEpacketBloc() : super(UpdateNoteAuditEpacketStateInitial()) {
    on<HandleUpdateAuditEpacket>(_onHandleUpdateAuditEpacket);
  }

  Future<void> _onHandleUpdateAuditEpacket(
    HandleUpdateAuditEpacket event,
    Emitter<UpdateNoteAuditEpacketState> emit,
  ) async {
    emit(UpdateNoteAuditEpacketStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$updateNoteAuditEpacket'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'shipment_code': event.shipmentCode,
          'shipment_note': event.shipmentNote,
        }),
      );

      final data = jsonDecode(response.body);
      log("Response data: $data");
      final mess = data['message'];
      if (data['status'] == 200) {
        log("SUCCESS: Get Success Update Audit Epacket");
        emit(UpdateNoteAuditEpacketStateSuccess(message: mess['text']));
      } else {
        log("ERROR: API returned status ${data['status']} Update Audit Epacket");
        emit(UpdateNoteAuditEpacketStateFailure(
            message: mess['text'] ?? "Lỗi không xác định"));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR: Network error: $error");
        emit(const UpdateNoteAuditEpacketStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR: Unexpected error: $error");
        emit(UpdateNoteAuditEpacketStateFailure(message: error.toString()));
      }
    }
  }
}
