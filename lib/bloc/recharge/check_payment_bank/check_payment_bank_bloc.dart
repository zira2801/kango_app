import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
part 'check_payment_bank_state.dart';
part 'check_payment_bank_event.dart';

class CheckPaymentBankBloc
    extends Bloc<CheckPaymentBankEvent, CheckPaymentBankState> {
  CheckPaymentBankBloc() : super(CheckPaymentBankStateLoading()) {
    on<HandleCheckPaymentBank>(_onHandleCheckPaymentBank);
  }

  void _onHandleCheckPaymentBank(
    HandleCheckPaymentBank event,
    Emitter<CheckPaymentBankState> emit,
  ) async {
    emit(CheckPaymentBankStateLoading());

    final respons = await http.post(
      Uri.parse('$baseUrl$checkSePay'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({'is_api': true, 'order_id': event.orderId}),
    );
    final data = jsonDecode(respons.body);

    try {
      if (data['status'] == 200 && data['paid'] == true) {
        emit(CheckPaymentBankStateSuccess());
      } else {
        emit(CheckPaymentBankStateFailure());
      }
    } catch (error) {
      log("ERROR checkPayment 2 $error");
      emit(CheckPaymentBankStateFailure());
    }
  }
}
