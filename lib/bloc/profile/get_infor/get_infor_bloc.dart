import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/area_Vn.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'get_infor_event.dart';
part 'get_infor_state.dart';

class GetInforProfileBloc
    extends Bloc<GetInforProfileEvent, GetInforProfileState> {
  GetInforProfileBloc() : super(GetInforProfileStateLoading()) {
    on<HandleGetInforProfile>(_onHandleGetInforProfile);
  }

  Future<void> _onHandleGetInforProfile(
    HandleGetInforProfile event,
    Emitter<GetInforProfileState> emit,
  ) async {
    emit(GetInforProfileStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getInforAccount'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'user_id': event.userID,
        }),
      );
      final data = jsonDecode(response.body);
      var mess = data['message'];
      if (data['status'] == 200) {
        log("_onHandleGetInforProfile OKOK");
        emit(GetInforProfileStateSuccess(
            inforAccountModel: InforAccountModel.fromJson(data)));
      } else {
        log("ERROR _onHandleCreateTicket 1");
        emit(GetInforProfileStateFailure(message: mess));
      }
    } catch (error) {
      log("ERROR _onHandleCreateTicket 2 $error");
      if (error is http.ClientException) {
        emit(const GetInforProfileStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(GetInforProfileStateFailure(message: error.toString()));
      }
    }
  }
}

class GetAreaVNBloc extends Bloc<GetAreaVNEvent, GetAreaVNState> {
  GetAreaVNBloc() : super(GetAreaVNStateStateLoading()) {
    on<HandleGetAreaVN>(_onHandleGetAreaVN);
  }

  Future<void> _onHandleGetAreaVN(
    HandleGetAreaVN event,
    Emitter<GetAreaVNState> emit,
  ) async {
    emit(GetAreaVNStateStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getAreaVNApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'city': event.cityID,
          'district': event.districtID,
        }),
      );
      final data = jsonDecode(response.body);
      var mess = data['message'];
      if (data['status'] == 200) {
        log("_onHandleGetInforProfile OKOK");
        emit(GetAreaVNStateStateSuccess(
            areaVnModel: AreaVnModel.fromJson(data)));
      } else {
        log("ERROR _onHandleCreateTicket 1");
        emit(GetAreaVNStateFailure(message: mess));
      }
    } catch (error) {
      log("ERROR _onHandleCreateTicket 2 $error");
      if (error is http.ClientException) {
        emit(const GetAreaVNStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(GetAreaVNStateFailure(message: error.toString()));
      }
    }
  }
}

class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  UpdateProfileBloc() : super(UpdateProfileStateLoading()) {
    on<HandleUpdateProfile>(_onHandleUpdateProfile);
  }

  Future<void> _onHandleUpdateProfile(
    HandleUpdateProfile event,
    Emitter<UpdateProfileState> emit,
  ) async {
    emit(UpdateProfileStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$editInforAccount'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'user_id': event.userID,
          'user_contact_name': event.userContactName,
          'user_phone': event.userPhone,
          'user_address': event.userAddress,
          'user_company_name': event.userCompanyName,
          /* 'user_accountant_key': event.userAccountKey,*/
          'user_tax_code': event.userTaxCode,
          'user_address_1': event.userAddress1,
          'user_address_2': event.userAddress2,
          'user_address_3': event.userAddress3,
          'user_logo': event.userLogo,
          'user_signature': event.userSignature
        }),
      );
      final data = jsonDecode(response.body);
      var mess = data['message'];
      if (data['status'] == 200) {
        log("_onHandleUpdateProfile OKOK");
        emit(UpdateProfileStateSuccess(message: mess));
      } else {
        log("ERROR _onHandleUpdateProfile 1");
        emit(UpdateProfileStateFailure(message: mess));
      }
    } catch (error) {
      log("ERROR _onHandleUpdateProfile 2 $error");
      if (error is http.ClientException) {
        emit(const UpdateProfileStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        emit(UpdateProfileStateFailure(message: error.toString()));
      }
    }
  }
}
