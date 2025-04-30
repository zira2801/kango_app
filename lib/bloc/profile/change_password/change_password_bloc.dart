import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc() : super(HandleChangePasswordStateInitial()) {
    on<HandleChangePassword>(_onHandleChangePassword);
  }

  Future<void> _onHandleChangePassword(
    HandleChangePassword event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(HandleChangePasswordStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$changePassword'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'user_id': event.userID,
          'old_password': event.oldPassword,
          'password': event.newPassword,
          'confirm_password': event.confirmNewPassword
        }),
      );
      final data = jsonDecode(response.body);
      var mess = data['message'];
      if (data['status'] == 200) {
        log("_onGetListTypeTicket OKOK");
        emit(HandleChangePasswordStateSuccess(message: mess));
      } else {
        log("ERROR _onHandleCreateTicket 1");
        emit(HandleChangePasswordStateFailure(message: mess));
      }
    } catch (error) {
      log("ERROR _onHandleCreateTicket 2 $error");
      if (error is http.ClientException) {
        emit(const HandleChangePasswordStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(HandleChangePasswordStateFailure(message: error.toString()));
      }
    }
  }
}
