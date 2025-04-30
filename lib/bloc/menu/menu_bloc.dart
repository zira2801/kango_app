import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/menu/menu.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/data/models/wallet/wallet_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(MenuStateInitial()) {
    on<GetMenu>(_onGetMenu);
  }

  Future<void> _onGetMenu(
    GetMenu event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuStateLoading());
    final response = await http.get(
      Uri.parse('$baseUrl$getMenu'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
    );
    final data = jsonDecode(response.body);
    var messRes = data['message'];
    try {
      if (data['status'] == 200) {
        emit(MenuStateSuccess(menuResponse: MenuResponse.fromJson(data)));
        log("_onGetMenu OKOK ");
      } else {
        log('__onGetMenu error ${messRes['text']} 1');
        emit(MenuStateFailure(errorText: messRes['text']));
      }
    } catch (error) {
      log('__onGetMenu error 2 $error');
      emit(const MenuStateFailure());
      if (error is http.ClientException) {
        emit(
            const MenuStateFailure(errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(const MenuStateFailure(errorText: "Đã có lỗi xảy ra"));
      }
    }
  }
}
