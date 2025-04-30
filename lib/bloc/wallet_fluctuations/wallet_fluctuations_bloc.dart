import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/audit_epacket/audit_epacket.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/data/models/wallet_fluctution/wallet_fluctution.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';

part 'wallet_fluctuations_event.dart';
part 'wallet_fluctuations_state.dart';

class GetListWalletFluctuationsBloc
    extends Bloc<WalletFluctuationsEvent, HandleGetWalletFluctuationState> {
  GetListWalletFluctuationsBloc()
      : super(HandleGetWalletFluctuationStateInitial()) {
    on<FetchListWalletFluctuations>(_onFetchListWalletFluctuations);
    on<LoadMoreListWalletFluctuations>(_onLoadMoreListWalletFluctuations);
  }

  Future<void> _onFetchListWalletFluctuations(
    FetchListWalletFluctuations event,
    Emitter<HandleGetWalletFluctuationState> emit,
  ) async {
    emit(HandleGetWalletFluctuationStateloading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListBienDongSoDu'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'paginate': {'page': 1, 'limit': 10},
          'filters': {
            'date_range': {
              'start_date': event.startDate,
              'end_date': event.endDate
            },
            'kind': event.kind,
            'keywords': event.keywords,
          }
        }),
      );
      final data = jsonDecode(response.body);
      final mess = data['message'];
      if (data['status'] == 200) {
        log("SUCCESS _onFetchListWalletFluctuation ");
        final response = WalletFluctuationResponse.fromJson(data);
        final walletFluctuationData = response.data;
        emit(HandleGetWalletFluctuationStateSuccess(
            data: walletFluctuationData,
            page: 1,
            hasReachedMax: walletFluctuationData.length < 10));
      } else {
        log("ERROR _onFetchListWalletFluctuation 1");
        emit(HandleGetWalletFluctuationStateFailure(message: mess));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onFetchListWalletFluctuation 2 $error");
        emit(const HandleGetWalletFluctuationStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onFetchListWalletFluctuation 3");
        emit(HandleGetWalletFluctuationStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListWalletFluctuations(
    LoadMoreListWalletFluctuations event,
    Emitter<HandleGetWalletFluctuationState> emit,
  ) async {
    if (state is HandleGetWalletFluctuationStateSuccess &&
        !(state as HandleGetWalletFluctuationStateSuccess).hasReachedMax) {
      final currentState = state as HandleGetWalletFluctuationStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getListBienDongSoDu'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'paginate': {'page': currentState.page + 1, 'limit': 10},
            'filters': {
              'date_range': {
                'start_date': event.startDate,
                'end_date': event.endDate
              },
              'kind': event.kind,
              'keywords': event.keywords,
            }
          }),
        );
        final data = jsonDecode(response.body);
        final mess = data['message'];
        if (data['status'] == 200) {
          if (data['status'] == 200) {
            final response = WalletFluctuationResponse.fromJson(data);
            final walletFluctuationData = response.data;
            emit(walletFluctuationData.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : HandleGetWalletFluctuationStateSuccess(
                    data: currentState.data + walletFluctuationData,
                    page: currentState.page + 1,
                    hasReachedMax: walletFluctuationData.length < 10,
                  ));
          }
        } else {
          log("ERROR _onLoadMoreListWalletFluctuation 1");
          emit(HandleGetWalletFluctuationStateFailure(message: mess['text']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onLoadMoreListWalletFluctuation $error");
          emit(const HandleGetWalletFluctuationStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreListWalletFluctuation 3");
          emit(HandleGetWalletFluctuationStateFailure(
              message: error.toString()));
        }
      }
    }
  }
}
