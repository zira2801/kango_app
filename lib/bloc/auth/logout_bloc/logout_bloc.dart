import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_event.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_state.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  LogoutBloc() : super(LogoutInitial()) {
    on<LogoutButtonPressed>(_onLogoutButtonPressed);
  }

  Future<void> _onLogoutButtonPressed(
    LogoutButtonPressed event,
    Emitter<LogoutState> emit,
  ) async {
    emit(LogoutLoading());
    final response = await http.get(
      Uri.parse('$baseUrl$logutApi'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        StorageUtils.instance.removeKey(key: 'token');
        StorageUtils.instance.removeKey(key: 'branch_response');
        StorageUtils.instance.removeKey(key: 'user_ID');
        StorageUtils.instance.removeKey(key: 'user_position');
        StorageUtils.instance.removeKey(key: 'isEditOrderPickup');
        StorageUtils.instance.removeKey(key: 'isUpdateMotification');
        StorageUtils.instance.removeKey(key: 'isEditShipment');
        StorageUtils.instance.removeKey(key: 'isCanScan');
        StorageUtils.instance.removeKey(key: 'isCreateTicket');
        StorageUtils.instance.removeKey(key: 'isEditDebit');
        StorageUtils.instance.removeKey(key: 'isPrintKIKI');
        emit(LogoutSuccess());
      } else {
        log("ERROR _onLogoutButtonPressed 1");
        emit(LogoutFailure(errorText: data['message']));
      }
    } catch (error) {
      log("ERROR _onLogoutButtonPressed 2 $error");
      if (error is http.ClientException) {
        emit(LogoutFailure(errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(LogoutFailure(errorText: error.toString()));
      }
    }
  }
}
