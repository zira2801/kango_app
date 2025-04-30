import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:scan_barcode_app/bloc/recharge/content_payment/content_payment_event.dart';
import 'package:scan_barcode_app/bloc/recharge/content_payment/content_payment_state.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/content_payment/content_payment_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';

class PaymentContentBloc
    extends Bloc<PaymentContentEvent, PaymentContentState> {
  PaymentContentBloc() : super(PaymentContentInitial()) {
    on<LoadPaymentContent>(_onLoadPaymentContent);
    on<CalculateUSDTAmount>(_onCalculateUSDTAmount);
  }

  Future<void> _onLoadPaymentContent(
    LoadPaymentContent event,
    Emitter<PaymentContentState> emit,
  ) async {
    try {
      emit(PaymentContentLoading());

      final response = await http.post(
        Uri.parse('${baseUrl}content-payment'),
        body: json.encode({'kind': event.kind}),
        headers: ApiUtils.getHeaders(isNeedToken: true),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        log("_ononLoadPaymentContent OKOK ");
        final content = PaymentContentModel.fromJson(data['data']);
        emit(PaymentContentLoaded(content));
      } else {
        var messenger = data['message'];
        log("_ononLoadPaymentContent Error 1 $messenger");
        emit(PaymentContentError(messenger));
      }
    } catch (e) {
      log("_ononLoadPaymentContent Error 2 $e");
      emit(PaymentContentError(e.toString()));
    }
  }

  Future<void> _onCalculateUSDTAmount(
    CalculateUSDTAmount event,
    Emitter<PaymentContentState> emit,
  ) async {
    final currentState = state;
    if (currentState is PaymentContentLoaded) {
      if (currentState.content.data?['price'] != null) {
        final usdtPrice = double.parse(currentState.content.data!['price']);
        final calculatedAmount = event.amount * usdtPrice;
        emit(PaymentContentLoaded(currentState.content,
            calculatedAmount: calculatedAmount));
      }
    }
  }
}
