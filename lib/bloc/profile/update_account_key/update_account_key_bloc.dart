import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
part 'update_account_key_event.dart';
part 'update_account_key_state.dart';

class UpdateAccountKeyBloc
    extends Bloc<UpdateAccountKeyEvent, UpdateAccountKeyState> {
  UpdateAccountKeyBloc() : super(HandleUpdateAccountKeyStateInitial()) {
    on<HandleUpdateAccountKey>(_onHandleUpdateAccountKey);
  }

  Future<void> _onHandleUpdateAccountKey(
      HandleUpdateAccountKey event, Emitter<UpdateAccountKeyState> emit) async {
    emit(HandleUpdateAccountKeyStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$updateAccountKey'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'user_id': event.userID,
          'current_password': event.currentPassword,
          'user_accountant_key': event.user_account_key
        }),
      );

      // Parse the response body
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Safely extract the message
      String message = '';
      if (data['message']['text'] is String) {
        message = data['message']['text'];
      } else if (data['message']['text'] is Map) {
        // If message is a Map, convert it to a string representation
        message = data['message']['text'].toString();
      } else {
        message = 'Unknown response format';
      }

      // Check status and emit appropriate state
      if (data['status'] == 200) {
        log("Update Account Key Successful");
        emit(HandleUpdateAccountKeyStateSuccess(message: message));
      } else {
        log("Error updating account key: $message");
        emit(HandleUpdateAccountKeyStateFailure(message: message));
      }
    } catch (error) {
      log("Error in update account key: $error");
      if (error is http.ClientException) {
        emit(const HandleUpdateAccountKeyStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else if (error is FormatException) {
        emit(const HandleUpdateAccountKeyStateFailure(
            message: "Định dạng dữ liệu không hợp lệ"));
      } else {
        emit(HandleUpdateAccountKeyStateFailure(
            message: "Đã xảy ra lỗi: ${error.toString()}"));
      }
    }
  }
}
