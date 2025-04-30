import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:scan_barcode_app/bloc/auth/forgot_password_bloc/forgot_password_event.dart';
import 'package:scan_barcode_app/bloc/auth/forgot_password_bloc/forgot_password_state.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<ForgotPasswordButtonPressed>(_onForgotPasswordButtonPressed);
  }

  Future<void> _onForgotPasswordButtonPressed(
    ForgotPasswordButtonPressed event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    final response = await http.post(
      Uri.parse('$baseUrl$forgotPasswordApi'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'email': event.email,
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    try {
      if (data['status'] == 200) {
        emit(ForgotPasswordSuccess(messRes: mess));
      } else {
        log("ERROR _onForgotPasswordButtonPressed 1");
        emit(ForgotPasswordFailure(errorText: mess));
      }
    } catch (error) {
      log("ERROR _onForgotPasswordButtonPressed 2 $error");
      if (error is http.ClientException) {
        emit(ForgotPasswordFailure(errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(ForgotPasswordFailure(errorText: error.toString()));
      }
    }
  }
}
