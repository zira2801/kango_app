import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';
import 'package:scan_barcode_app/data/models/shipment/all_unit_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/delivery_service.dart';
import 'package:scan_barcode_app/data/models/shipment/info_old_receiver.dart';
import 'package:scan_barcode_app/data/models/shipment/list_old_receiver.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'create_new_shipment_event.dart';
part 'create_new_shipment_state.dart';

class CreateNewShipmentBloc
    extends Bloc<CreateNewShipmentEvent, CreateNewShipmentState> {
  CreateNewShipmentBloc() : super(CreateNewShipmentStateInitial()) {
    // on<GetDeliveryService>(_onGetDeliveryService);
  }
}

class GetDeliveryServiceBloc
    extends Bloc<GetDeliveryServiceEvent, GetDeliveryServiceState> {
  GetDeliveryServiceBloc() : super(GetDeliveryServiceStateInitial()) {
    on<GetDeliveryService>(_onGetDeliveryService);
  }

  Future<void> _onGetDeliveryService(
    GetDeliveryService event,
    Emitter<GetDeliveryServiceState> emit,
  ) async {
    emit(GetDeliveryServiceStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getDeliveryServiceApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'country_id': event.currentIDCountryReciver,
        }),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        final deliveryServiceData = DeliveryServiceModel.fromJson(data);
        emit(GetDeliveryServiceStateSuccess(data: deliveryServiceData));
      } else {
        log("ERROR _onGetDeliveryService 1");
        emit(const GetDeliveryServiceStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onGetDeliveryService 2 $error");
      if (error is http.ClientException) {
        emit(const GetDeliveryServiceStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(GetDeliveryServiceStateFailure(message: error.toString()));
      }
    }
  }
}

class GetListOldReceiverBloc
    extends Bloc<GetListOldReceiverEvent, GetListOldReceiverState> {
  GetListOldReceiverBloc() : super(GetListOldReceiverStateInitial()) {
    on<GetListOldReceiver>(_onGetListOldReceiver);
  }

  Future<void> _onGetListOldReceiver(
    GetListOldReceiver event,
    Emitter<GetListOldReceiverState> emit,
  ) async {
    emit(GetListOldReceiverStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListOldReceiverApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        final listOldReceiverData = ListOldReceiverModel.fromJson(data);
        emit(GetListOldReceiverStateSuccess(data: listOldReceiverData));
      } else {
        log("ERROR _onGetListOldReceiver 1");
        emit(const GetListOldReceiverStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onGetListOldReceiver 2 $error");
      if (error is http.ClientException) {
        emit(const GetListOldReceiverStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(GetListOldReceiverStateFailure(message: error.toString()));
      }
    }
  }
}

class GetAllUnitShipmentBloc
    extends Bloc<GetAllUnitShipmentEvent, GetAllUnitShipmentState> {
  GetAllUnitShipmentBloc() : super(GetAllUnitShipmentStateInitial()) {
    on<GetAllUnitShipment>(_onGetAllUnitShipment);
  }

  Future<void> _onGetAllUnitShipment(
    GetAllUnitShipment event,
    Emitter<GetAllUnitShipmentState> emit,
  ) async {
    emit(GetAllUnitShipmentStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$typeAndUnitShpment'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        final listAllUnitShipmentData = AllUnitShipmentModel.fromJson(data);
        emit(GetAllUnitShipmentStateSuccess(data: listAllUnitShipmentData));
      } else {
        log("ERROR _onGetAllUnitShipment 1");
        emit(const GetAllUnitShipmentStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onGetAllUnitShipment 2 $error");
      if (error is http.ClientException) {
        emit(const GetAllUnitShipmentStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(GetAllUnitShipmentStateFailure(message: error.toString()));
      }
    }
  }
}

class HandleGetInforOldRecieveBloc
    extends Bloc<HandleGetInforOldRecieveEvent, HandleGetInforOldRecieveState> {
  HandleGetInforOldRecieveBloc()
      : super(HandleGetInforOldRecieveStateInitial()) {
    on<HandleGetInforOldRecieve>(_onHandleGetInforOldRecieve);
  }

  Future<void> _onHandleGetInforOldRecieve(
    HandleGetInforOldRecieve event,
    Emitter<HandleGetInforOldRecieveState> emit,
  ) async {
    emit(HandleGetInforOldRecieveStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$inforOldReceiverApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'receiver_id': event.receiverID,
        }),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        final infoOldReceiverData = InfoOldReceiverModel.fromJson(data);
        emit(HandleGetInforOldRecieveStateSuccess(data: infoOldReceiverData));
      } else {
        log("ERROR _onHandleGetInforOldRecieve 1");
        emit(const HandleGetInforOldRecieveStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onHandleGetInforOldRecieve 2 $error");
      if (error is http.ClientException) {
        emit(const HandleGetInforOldRecieveStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(HandleGetInforOldRecieveStateFailure(message: error.toString()));
      }
    }
  }
}

class HandleGetInforUserBloc
    extends Bloc<HandleGetInforUserEvent, GetInforUserState> {
  HandleGetInforUserBloc() : super(GetInforUserStateInitial()) {
    on<HandleGetInforUser>(_onHandleGetInforUser);
  }

  Future<void> _onHandleGetInforUser(
    HandleGetInforUser event,
    Emitter<GetInforUserState> emit,
  ) async {
    emit(GetInforUserStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getInforAccount'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'user_id': event.userID,
        }),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        final infoUserData = InforAccountModel.fromJson(data);
        emit(GetInforUserStateSuccess(data: infoUserData));
      } else {
        log("ERROR _onHandleGetInforUser 1");
        emit(const GetInforUserStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onHandleGetInforUser 2 $error");
      if (error is http.ClientException) {
        emit(const GetInforUserStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(GetInforUserStateFailure(message: error.toString()));
      }
    }
  }
}
