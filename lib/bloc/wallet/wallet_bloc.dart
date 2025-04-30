import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/data/models/wallet/wallet_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletStateInitial()) {
    on<GetWallet>(_onGetWallet);
  }

  Future<void> _onGetWallet(
    GetWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletStateLoading());
    final response = await http.post(
      Uri.parse('$baseUrl$walletApi'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
      }),
    );
    final data = jsonDecode(response.body);
    var messRes = data['message'];
    try {
      if (data['status'] == 200) {
        emit(WalletStateSuccess(walletModel: WalletResponse.fromJson(data)));
        log("_onGetWallet OKOK ");
      } else {
        log('__onGetWallet error ${messRes['text']} 1');
        emit(WalletStateFailure(errorText: messRes['text']));
      }
    } catch (error) {
      log('__onGetWallet error 2 $error');
      emit(WalletStateFailure());
      if (error is http.ClientException) {
        emit(WalletStateFailure(errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(WalletStateFailure(errorText: "Đã có lỗi xảy ra"));
      }
    }
  }
}
