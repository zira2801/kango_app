import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:scan_barcode_app/data/models/auth.dart';
import 'package:scan_barcode_app/data/models/confirm_auth.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:equatable/equatable.dart';
part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc() : super(SignInInitial()) {
    on<SignInButtonPressed>(_onSignInButtonPressed);
  }

  Future<void> _onSignInButtonPressed(
    SignInButtonPressed event,
    Emitter<SignInState> emit,
  ) async {
    // bool checkPositionAndReturnKind(List<SystemSetting> data, String number) {
    //   for (var item in data) {
    //     if (item.positionIds != null) {
    //       if (item.positionIds!.contains(number) && item.kind == 3) {
    //         log('Found! Kind: ${item.kind}');
    //         return true;
    //       }
    //     }
    //   }
    //   return false;
    // }
    bool isEditOrderPickup = false;
    bool isUpdateMotification = false;
    bool isEditShipment = false;
    bool isCanScan = false;
    bool isCreateTicket = false;
    bool isEditDebit = false;
    bool isPrintKIKI = false;

    void checkIsCanEditOrderPickUp(List<SystemSetting> data, String number) {
      for (var item in data) {
        if (item.kind == 3) {
          log("KIND 3 [isEditOrderPickup]");
          isEditOrderPickup = true;
        } else if (item.kind == 9) {
          log("KIND 9 [isUpdateMotification]");
          isUpdateMotification = true;
        } else if (item.kind == 11) {
          log("KIND 11 [isEditShipment]");
          isEditShipment = true;
        } else if (item.kind == 12) {
          log("KIND 12 [isCanScan]");
          isCanScan = true;
        } else if (item.kind == 13) {
          log("KIND 13 [isCreateTicket]");
          isCreateTicket = true;
        } else if (item.kind == 15) {
          log("KIND 15 [isEditDebit]");
          isEditDebit = true;
        } else if (item.kind == 23) {
          log("KIND 23 [isPrintKIKI]");
          isPrintKIKI = true;
        }
      }
    }

    emit(SignInLoading());
    final response = await http.post(
      Uri.parse('$baseUrl$loginApi'),
      headers: ApiUtils.getHeaders(),
      body: jsonEncode({
        'email': event.email,
        'password': event.password,
      }),
    );
    final data = jsonDecode(response.body);

    try {
      if (data['status'] == 200) {
        if (data['otp'] == null) {
          var authDataRes = AuthModel.fromJson(data);
          var token = authDataRes.token;
          var userID = authDataRes.data.userId;
          var isShipper = authDataRes.isShipper;
          var userCode = authDataRes.data.userCode;
          var isSale = authDataRes.data.positionId == 4;
          var positionId = authDataRes.data.positionId;
          var accountantKey = authDataRes.data.userAccountantKey ?? '';
          int currentKind = 0;
          String userPosition = '';
          log('System Settings: ${authDataRes.systemSettings}');
          for (var item in authDataRes.systemSettings) {
            log("ZOOO DAAA");
            if (item.positionId == authDataRes.data.positionId.toString()) {
              log('Kind: ${item.kind}');
              currentKind = item.kind;
              break;
            }
          }
          switch (currentKind) {
            case 17:
              log("tài khoản admin");
              userPosition = 'admin';
            case 18:
              log("tài khoản kế toán");
              userPosition = 'accountant';
            case 19:
              log("tài khoản chứng từ");
              userPosition = 'document';
            case 1:
              log("tài khoản sale");
              userPosition = 'sale';
            case 2:
              log("tài khoản FWD");
              userPosition = 'fwd';
            case 20:
              log("tài khoản OPS trưởng");
              userPosition = 'ops_leader';
            case 14:
              log("tài khoản OPS/Pickup");
              userPosition = 'ops_pickup';
            case 24:
              log("tài khoản tài xế");
              userPosition = 'driver';
          }

          checkIsCanEditOrderPickUp(authDataRes.systemSettings,
              authDataRes.data.positionId.toString());
          await StorageUtils.instance.setString(key: 'token', val: token);
          await StorageUtils.instance.setInt(key: 'user_ID', val: userID);
          await StorageUtils.instance
              .setBool(key: 'is_shipper', val: isShipper);
          await StorageUtils.instance.setBool(key: 'isSale', val: isSale);
          await StorageUtils.instance.setString(key: 'userCode', val: userCode);
          await StorageUtils.instance
              .setInt(key: 'positionID', val: positionId);
          await StorageUtils.instance
              .setString(key: 'saved_email', val: event.email);
          await StorageUtils.instance
              .setString(key: 'save_password', val: event.password);
          await StorageUtils.instance
              .setString(key: 'userAccountantKey', val: accountantKey);
          await StorageUtils.instance
              .setString(key: 'user_position', val: userPosition);
          await StorageUtils.instance
              .setBool(key: 'isEditOrderPickup', val: isEditOrderPickup);
          await StorageUtils.instance
              .setBool(key: 'isUpdateMotification', val: isUpdateMotification);
          await StorageUtils.instance
              .setBool(key: 'isEditShipment', val: isEditShipment);
          await StorageUtils.instance.setBool(key: 'isCanScan', val: isCanScan);
          await StorageUtils.instance
              .setBool(key: 'isCreateTicket', val: isCreateTicket);
          await StorageUtils.instance
              .setBool(key: 'isEditDebit', val: isEditDebit);
          await StorageUtils.instance
              .setBool(key: 'isPrintKIKI', val: isPrintKIKI);
          final response2 = await http.post(
            Uri.parse('$baseUrl$getBranchs'),
            headers: ApiUtils.getHeaders(isNeedToken: true),
          );

          final data2 = jsonDecode(response2.body);
          try {
            if (data2['status'] == 200) {
              BranchResponse branchResponse = BranchResponse.fromJson(data2);
              String branchResponseJson = jsonEncode(branchResponse.toJson());
              await StorageUtils.instance
                  .setString(key: 'branch_response', val: branchResponseJson);
              emit(SignInSuccess(branchResponse: branchResponse));
            } else {
              print("getBranchsKango Error 1");
              emit(SignInFailure(errorText: "Không thể kết nối đến máy chủ"));
            }
          } catch (error) {
            log("getBranchsKango Error $error 2");
            if (error is http.ClientException) {
              // Handle HTTP Client Exception
              emit(SignInFailure(
                  errorText: "Không thể kết nối đến máy chủ $error"));
            } else {
              // Handle other exceptions
              emit(SignInFailure(errorText: "Không thể kết nối đến máy chủ"));
            }
          }
        } else {
          log("ZO ELSE R");
          var authDataRes = ConfirmOtpAuthModel.fromJson(data);
          var tokenConfirmOtp = authDataRes.otp.token;
          StorageUtils.instance
              .setString(key: 'token_confirm_otp', val: tokenConfirmOtp);
          StorageUtils.instance.setString(key: 'email_login', val: event.email);

          emit(SignIn2Authen());
        }
      } else if (data['status'] == 422) {
        emit(SignInFailure(errorText: "Email không tồn tại !"));
      } else {
        emit(SignInFailure(errorText: data['message']));
      }
    } catch (error) {
      log("ERROR _onManagerLoginButtonPressed 2 $error");
      if (error is http.ClientException) {
        emit(SignInFailure(errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(SignInFailure(errorText: error.toString()));
      }
    }
  }
}
