import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/audit_epacket/audit_epacket.dart';
import 'package:scan_barcode_app/data/models/debit/debit.dart';
import 'package:scan_barcode_app/data/models/debit/debit_detail.dart';
import 'package:scan_barcode_app/data/models/debit/shipmet_debit.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';

part 'debit_event.dart';
part 'debit_state.dart';

class GetListDebitBloc extends Bloc<DebitEvent, HandleGetDebitState> {
  GetListDebitBloc() : super(HandleGetDebitStateInitial()) {
    on<FetchListDebit>(_onFetchListDebit);
    on<LoadMoreListDebit>(_onLoadMoreListDebit);
  }

  Future<void> _onFetchListDebit(
    FetchListDebit event,
    Emitter<HandleGetDebitState> emit,
  ) async {
    emit(HandleGetDebitStateloading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListDebitChuyenTuyen'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'paginate': {'limit': 10, 'page': 1},
          'filters': {
            'date_range': {
              'start_date': event.startDate,
              'end_date': event.endDate
            },
            'debit_status': event.debitStatus,
            'keywords': event.keywords,
          }
        }),
      );
      final data = jsonDecode(response.body);
      final mess = data['message'];
      if (data['status'] == 200) {
        final response = DebitResponse.fromJson(data);
        final debitsData = response.debits;
        emit(HandleGetDebitStateSuccess(
            data: debitsData, page: 1, hasReachedMax: debitsData.length < 10));
      } else {
        log("ERROR _onFetchListDebit 1");
        emit(HandleGetDebitStateFailure(message: mess['text']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onFetchListDebit 2 $error");
        emit(const HandleGetDebitStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onFetchListDebit 3");
        emit(HandleGetDebitStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListDebit(
    LoadMoreListDebit event,
    Emitter<HandleGetDebitState> emit,
  ) async {
    if (state is HandleGetDebitStateSuccess &&
        !(state as HandleGetDebitStateSuccess).hasReachedMax) {
      final currentState = state as HandleGetDebitStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getListDebitChuyenTuyen'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'paginate': {'limit': 10, 'page': currentState.page + 1},
            'filters': {
              'date_range': {
                'start_date': event.startDate,
                'end_date': event.endDate
              },
              'debit_status': event.debitStatus,
              'keywords': event.keywords,
            }
          }),
        );
        final data = jsonDecode(response.body);
        final mess = data['message'];
        if (data['status'] == 200) {
          log("SUCCESS _onLoadMoreListDebits");
          if (data['status'] == 200) {
            final response =
                DebitResponse.fromJson(data); // Use same parser as in fetch
            final debitsData = response.debits;
            emit(debitsData.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : HandleGetDebitStateSuccess(
                    data: currentState.data + debitsData,
                    page: currentState.page + 1,
                    hasReachedMax: debitsData.length < 10,
                  ));
          }
        } else {
          log("ERROR _onLoadMoreListDebits 1");
          emit(HandleGetDebitStateFailure(message: mess['text']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onLoadMoreListDebits $error");
          emit(const HandleGetDebitStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreListDebits 3");
          emit(HandleGetDebitStateFailure(message: error.toString()));
        }
      }
    }
  }
}

class CheckAccountainCodeDebitBloc
    extends Bloc<DebitEvent, CheckAccountainCodeDebitState> {
  CheckAccountainCodeDebitBloc() : super(CheckAccountainCodeDebitInitial()) {
    on<CheckAccountainCodeDebit>(_onHandleCheckAccountainCodeDebit);
  }

  Future<void> _onHandleCheckAccountainCodeDebit(
    CheckAccountainCodeDebit event,
    Emitter<CheckAccountainCodeDebitState> emit,
  ) async {
    emit(CheckAccountainCodeDebitloading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$verifyAccountainCode'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({'is_api': true, 'key': event.key}),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        emit(CheckAccountainCodeDebitSuccess(
            message: data['message'].toString()));
      } else {
        log("ERROR _onHandleCheckAccountainCodeDebit 1");
        emit(CheckAccountainCodeDebitFailure(
            message: data['message'].toString() ?? "Lỗi không xác định"));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onHandleCheckAccountainCodeDebit 2 $error");
        emit(const CheckAccountainCodeDebitFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onHandleCheckAccountainCodeDebit 3");
        emit(CheckAccountainCodeDebitFailure(message: error.toString()));
      }
    }
  }
}

class GetDetailDebitBloc extends Bloc<DebitEvent, GetDetailDebitState> {
  GetDetailDebitBloc() : super(GetDetailDebitInitial()) {
    on<GetDetailDebit>(_onHandleGetDetailDebit);
  }

  Future<void> _onHandleGetDetailDebit(
    GetDetailDebit event,
    Emitter<GetDetailDebitState> emit,
  ) async {
    emit(GetDetailDebitloading());

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$debitDetail${event.debitCode}'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        log("SUCCESS _onHandleGetDetailDebit ");
        final response = DebitDetailResponse.fromJson(data);
        emit(GetDetailDebitSuccess(debitDetailResponse: response));
      } else {
        log("ERROR _onHandleGetDetailDebit 1");

        final mess = data['message']['text'];
        emit(GetDetailDebitFailure(message: mess));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onHandleGetDetailDebit 2 $error");
        emit(const GetDetailDebitFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onHandleGetDetailDebit 3");
        emit(GetDetailDebitFailure(message: error.toString()));
      }
    }
  }
}

class GetListDebitShipmentBloc extends Bloc<DebitEvent, GetDetailDebitState> {
  GetListDebitShipmentBloc() : super(GetListShipmentDebitStateInitial()) {
    on<FetchListShipmentDebit>(_onFetchListShipmentDebit);
    on<LoadMoreListShipmentDebit>(_onLoadMoreListShipmentDebit);
  }

  Future<void> _onFetchListShipmentDebit(
    FetchListShipmentDebit event,
    Emitter<GetDetailDebitState> emit,
  ) async {
    emit(GetListShipmentDebitStateloading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getShipmentDebit'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'paginate': {'limit': 10, 'page': 1},
          'filters': {
            'keywords': event.keywords,
          },
          'debit_id': event.debitID
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final response = ShipmentDebitResponse.fromJson(data);
        final shipmentDebitData = response.debits;
        emit(GetListShipmentDebitStateSuccess(
            data: shipmentDebitData ?? [],
            page: 1,
            hasReachedMax: shipmentDebitData!.length < 10));
        log("SUCCESS _onFetchListShipmentDebit ");
      } else {
        log("ERROR _onFetchListShipmentDebit 1");

        final mess = data['message'];
        emit(GetListShipmentDebitStateFailure(message: mess['text']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onFetchListShipmentDebit 2 $error");
        emit(const GetListShipmentDebitStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onFetchListShipmentDebit 3");
        emit(GetListShipmentDebitStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListShipmentDebit(
    LoadMoreListShipmentDebit event,
    Emitter<GetDetailDebitState> emit,
  ) async {
    if (state is GetListShipmentDebitStateSuccess &&
        !(state as GetListShipmentDebitStateSuccess).hasReachedMax) {
      final currentState = state as GetListShipmentDebitStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getShipmentDebit'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'paginate': {'limit': 10, 'page': currentState.page + 1},
            'filters': {
              'keywords': event.keywords,
            },
            'debit_id': event.debitID
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          log("SUCCESS _onLoadMoreListShipmentDebit");
          if (data['status'] == 200) {
            final response = ShipmentDebitResponse.fromJson(data);
            final shipmentDebitData = response.debits;
            emit(shipmentDebitData!.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : GetListShipmentDebitStateSuccess(
                    data: currentState.data + shipmentDebitData,
                    page: currentState.page + 1,
                    hasReachedMax: shipmentDebitData.length < 10,
                  ));
          }
        } else {
          final mess = data['message'];
          log("ERROR _onLoadMoreListShipmentDebit 1");
          emit(GetListShipmentDebitStateFailure(message: mess['text']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onLoadMoreListShipmentDebit $error");
          emit(const GetListShipmentDebitStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreListShipmentDebit 3");
          emit(GetListShipmentDebitStateFailure(message: error.toString()));
        }
      }
    }
  }
}

class PaymentDebitBloc extends Bloc<DebitEvent, PaymentDebitState> {
  PaymentDebitBloc() : super(PaymentDebitStateInitial()) {
    on<OnHandlePaymentDebit>(_onHandlePaymentDebit);
  }

  Future<void> _onHandlePaymentDebit(
      OnHandlePaymentDebit event, Emitter<PaymentDebitState> emit) async {
    emit(PaymentDebitStateloading());
    try {
      final body = jsonEncode({
        'is_api': true,
        'debit_no': event.debitNo,
        'debit_note': event.debitNote,
        'debit_payment_method': event.debitPaymentMethod,
        'debit_payment_amount': event.debitPaymentAmount,
        'bank_amount': event.bankAmount,
        'cash_amount': event.cashAmount,
        'debits_images': event.debitsImages,
      });
      log('Request body: $body'); // Log dữ liệu gửi đi
      final response = await http.post(
        Uri.parse('$baseUrl$paymentDebit'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: body,
      );

      final data = jsonDecode(response.body);
      log('Response: ${response.body}'); // Log phản hồi từ server
      // Xử lý các trường hợp lỗi khác nhau
      switch (data['status']) {
        case 200:
          log('SUCCESS _onHandlePaymentDebit');
          emit(PaymentDebitStateSuccess(message: data['message']['text']));
          break;
        case 400:
          // Lỗi bad request
          log('ERROR _onHandlePaymentDebit 400');
          emit(PaymentDebitStateFailure(
              message: data['message']['text'] ?? 'Yêu cầu không hợp lệ'));
          break;
        case 401:
          // Lỗi unauthorized
          log('ERROR _onHandlePaymentDebit 401');
          emit(PaymentDebitStateFailure(
              message: data['message'] ?? 'Không có quyền truy cập'));
          break;
        case 404:
          log('ERROR _onHandlePaymentDebit 404');
          // Lỗi not found
          emit(PaymentDebitStateFailure(
              message: data['message']['text'] ?? 'Không tìm thấy dữ liệu'));
          break;
        case 500:
          log('ERROR _onHandlePaymentDebit 500');
          // Lỗi server internal
          emit(PaymentDebitStateFailure(
              message: data['message'] ?? 'Lỗi máy chủ nội bộ'));
          break;
        default:
          // Các mã lỗi khác
          emit(PaymentDebitStateFailure(
              message: data['message'] ?? 'Đã có lỗi xảy ra'));
      }
    } catch (error) {
      // Xử lý các lỗi ngoại lệ
      if (error is SocketException) {
        emit(const PaymentDebitStateFailure(message: 'Lỗi kết nối mạng'));
      } else if (error is TimeoutException) {
        emit(const PaymentDebitStateFailure(message: 'Hết thời gian kết nối'));
      } else {
        emit(PaymentDebitStateFailure(message: 'Lỗi không xác định: $error'));
      }
      log('ERROR _onHandlePaymentDebit: $error');
    }
  }
}
