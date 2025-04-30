import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/transfer/transfer_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'transfer_event.dart';
part 'transfer_state.dart';

class GetListTransferBloc extends Bloc<TransferEvent, GetListTransferState> {
  GetListTransferBloc() : super(GetListTransferStateInitial()) {
    on<FetchListTransfer>(_onFetchListTrasfer);
    on<LoadMoreListTransfer>(_onLoadMoreListTransfer);
  }

  Future<void> _onFetchListTrasfer(
    FetchListTransfer event,
    Emitter<GetListTransferState> emit,
  ) async {
    emit(GetListTransferStateloading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListTransferList'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'limit': 10,
          'page': 1,
          'filters': {
            "date_range": {
              "start_date": event.startDate,
              "end_date": event.endDate
            },
            "keywords": event.keywords
          }
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        log("SUCCESS _onFetchListTransfer ");
        final response = TransferResponse.fromJson(data);
        final transferData = response.html?.data;
        final pageCurrent = response.html?.currentPage;
        emit(GetListTransferStateSuccess(
            data: transferData!,
            page: pageCurrent!,
            hasReachedMax: transferData.length < 10));
      } else {
        log("ERROR _onFetchListTransfer 1");
        emit(GetListTransferStateFailure(message: data['message']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onFetchListTransfer 2 $error");
        emit(const GetListTransferStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onFetchListTransfer 3");
        emit(GetListTransferStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListTransfer(
    LoadMoreListTransfer event,
    Emitter<GetListTransferState> emit,
  ) async {
    if (state is GetListTransferStateSuccess &&
        !(state as GetListTransferStateSuccess).hasReachedMax) {
      final currentState = state as GetListTransferStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getListTransferList'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'limit': 10,
            'page': currentState.page + 1,
            'filters': {
              "date_range": {
                "start_date": event.startDate,
                "end_date": event.endDate
              },
              "keywords": event.keywords
            }
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          if (data['status'] == 200) {
            log("SUCCESS _onLoadMoreListTransfer ");
            final response =
                TransferResponse.fromJson(data); // Use same parser as in fetch
            final transferData = response.html?.data;
            emit(transferData!.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : GetListTransferStateSuccess(
                    data: currentState.data + transferData,
                    page: currentState.page + 1,
                    hasReachedMax: transferData.length < 10,
                  ));
          }
        } else {
          log("ERROR _onLoadMoreListTransfer 1");
          emit(GetListTransferStateFailure(message: data['message']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR __onLoadMoreListTransfer 2 $error");
          emit(const GetListTransferStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreListTransfer 3");
          emit(GetListTransferStateFailure(message: error.toString()));
        }
      }
    }
  }
}

class CreateTransferBloc extends Bloc<TransferEvent, CreateTransfertState> {
  CreateTransferBloc() : super(CreateTransfertStateInitial()) {
    on<HandleCreateTransfer>(_onCreateTransfer);
  }
  Future<void> _onCreateTransfer(
    HandleCreateTransfer event,
    Emitter<CreateTransfertState> emit,
  ) async {
    emit(CreateTransfertStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$createTransferList'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'transfer_id': event.transferID,
          'transfer_content': event.transferContent,
          'transfer_images': event.transferImages,
          'receiver_name': event.receiverName,
          'receiver_phone': event.receiverPhone,
          'receiver_address': event.receiverAddress,
          'transfer_shipment_codes': event.transferShipmentCodes
        }),
      );
      final data = jsonDecode(response.body);
      final mess = data['message'];
      if (data['status'] == 200) {
        log("SUCCESS _onCreateTransfer ");
        emit(CreateTransfertStateSuccess(message: mess['text']));
      } else {
        log("ERROR _onCreateTransfer 1");
        emit(CreateTransfertStateFailure(message: mess['text']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onCreateTransfer 2 $error");
        emit(const CreateTransfertStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onCreateTransfer 3");
        emit(CreateTransfertStateFailure(message: error.toString()));
      }
    }
  }
}

class DeleteTransferBloc extends Bloc<TransferEvent, DeleteTransferState> {
  DeleteTransferBloc() : super(DeleteTransferStateInitial()) {
    on<DeleteTransfer>(_onDeleteTransfer);
  }

  Future<void> _onDeleteTransfer(
    DeleteTransfer event,
    Emitter<DeleteTransferState> emit,
  ) async {
    emit(DeleteTransferStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$deleteTransfer'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({'is_api': true, 'transfer_id': event.transferID}),
      );
      final data = jsonDecode(response.body);
      final mess = data['message'];
      if (data['status'] == 200) {
        log("SUCCESS _onDeleteTransfer ");
        emit(DeleteTransferStateSuccess(message: mess['text']));
      } else {
        log("ERROR _onDeleteTransfer 1");
        emit(DeleteTransferStateFailure(message: mess['text']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onDeleteTransfer 2 $error");
        emit(const DeleteTransferStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onDeleteTransfer 3");
        emit(DeleteTransferStateFailure(message: error.toString()));
      }
    }
  }
}

class ApproveTransferBloc extends Bloc<TransferEvent, ApproveTransfertState> {
  ApproveTransferBloc() : super(ApproveTransfertStateInitial()) {
    on<ApproveTransfer>(_onApproveTransfer);
  }

  Future<void> _onApproveTransfer(
    ApproveTransfer event,
    Emitter<ApproveTransfertState> emit,
  ) async {
    emit(ApproveTransfertStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$approveTransfer'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({'is_api': true, 'transfer_id': event.transferID}),
      );
      final data = jsonDecode(response.body);
      final mess = data['message'];
      if (data['status'] == 200) {
        log("SUCCESS _onApproveTransfer ");
        emit(ApproveTransfertStateSuccess(message: mess['text']));
      } else {
        log("ERROR _onApproveTransfer 1");
        emit(ApproveTransfertStateFailure(message: mess['text']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onApproveTransfer 2 $error");
        emit(const ApproveTransfertStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onApproveTransfer 3");
        emit(ApproveTransfertStateFailure(message: error.toString()));
      }
    }
  }
}
