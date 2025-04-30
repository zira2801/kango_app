import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/bloc/auth/confirm_otp_login_bloc/confirm_otp_login_event.dart';
import 'package:scan_barcode_app/bloc/auth/confirm_otp_login_bloc/confirm_otp_login_state.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/auth.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';

class ConfirmOTPLoginBloc
    extends Bloc<ConfirmOTPLoginEvent, ConfirmOTPLoginState> {
  ConfirmOTPLoginBloc() : super(ConfirmOTPLoginInitial()) {
    on<ConfirmOTPLoginButtonPressed>(_onConfirmOTPLoginButtonPressed);
  }

  Future<void> _onConfirmOTPLoginButtonPressed(
    ConfirmOTPLoginButtonPressed event,
    Emitter<ConfirmOTPLoginState> emit,
  ) async {
    emit(ConfirmOTPLoginLoading());
    final String? tokenConfirmOtp =
        StorageUtils.instance.getString(key: 'token_confirm_otp');
    final String? emailLogin =
        StorageUtils.instance.getString(key: 'email_login');
    final response = await http.post(
      Uri.parse('$baseUrl$accuracyApi'),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': emailLogin,
        'token': tokenConfirmOtp,
        'code': event.otp,
      }),
    );
    final data = jsonDecode(response.body);

    try {
      if (data['status'] == 200) {
        var authDataRes = AuthModel.fromJson(data);
        var token = authDataRes.token;
        await StorageUtils.instance.setString(key: 'token', val: token);

        emit(ConfirmOTPLoginSuccess(messRes: "Đăng nhập thành công"));
      } else {
        log("ERROR _onConfirmOTPLoginButtonPressed 1");
        final errorText = data['message'];
        emit(ConfirmOTPLoginFailure(errorText: errorText));
      }
    } catch (error) {
      log("ERROR _onConfirmOTPLoginButtonPressed 2 $error");
      if (error is http.ClientException) {
        emit(
            ConfirmOTPLoginFailure(errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(ConfirmOTPLoginFailure(errorText: error.toString()));
      }
    }
  }
}
