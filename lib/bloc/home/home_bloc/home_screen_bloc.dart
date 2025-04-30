import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/bloc/home/home_bloc/home_screen_event.dart';
import 'package:scan_barcode_app/bloc/home/home_bloc/home_screen_state.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/home/home_chart_data_model.dart';
import 'package:scan_barcode_app/data/models/home/setup_dashboard_model.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  HomeScreenBloc() : super(HomeScreenLoading()) {
    on<HomeScreenButtonPressed>(_onHomeScreenButtonPressed);
  }

  Future<void> _onHomeScreenButtonPressed(
    HomeScreenButtonPressed event,
    Emitter<HomeScreenState> emit,
  ) async {
    emit(HomeScreenLoading());
    final int? userID = StorageUtils.instance.getInt(key: 'user_ID');

    final response = await http.post(
      Uri.parse('$baseUrl$getInforAccount'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'user_id': userID,
      }),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        log(" _onHomeScreenButtonPressed OKOK");
        emit(HomeScreenSuccess(
            dataInforAccount: InforAccountModel.fromJson(data)));
      } else if (response.statusCode == 401) {
        log("ERROR _onHomeScreenButtonPressed 401");
        emit(HomeScreenTokenOutOfDate());
      } else {
        log("ERROR _onHomeScreenButtonPressed 1");
        emit(HomeScreenFailure(errorText: data['message']));
      }
    } catch (error) {
      log("ERROR _onHomeScreenButtonPressed 2 $error");
      if (error is http.ClientException) {
        emit(HomeScreenFailure(errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(HomeScreenFailure(errorText: error.toString()));
      }
    }
  }
}

class HomeScreenDashBoardBloc
    extends Bloc<GetHomeScreenDashBoard, HomeScreenDashBoardState> {
  HomeScreenDashBoardBloc() : super(HomeScreenDashBoardStateLoading()) {
    on<GetHomeScreenDashBoard>(_onGetHomeScreenDashBoard);
  }

  Future<void> _onGetHomeScreenDashBoard(
    GetHomeScreenDashBoard event,
    Emitter<HomeScreenDashBoardState> emit,
  ) async {
    emit(HomeScreenDashBoardStateLoading());
    print({
      "is_api": true,
      "chart_type_date": event.chartTypeDate,
      "chart_type_total": event.chartTypeTotal,
      "filters": {
        "position_id": event.positionID,
        "shipment_status": event.shipmentStatus,
        "shipment_branch_id": event.shipmentBranchId,
        "shipment_service_id": event.shipmentServiceId,
        "date_range": {"start_date": event.startDate, "end_date": event.endDate}
      }
    });
    final response = await http.post(
      Uri.parse('$baseUrl$getListDataDashboard'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        "is_api": true,
        "chart_type_date": event.chartTypeDate,
        "chart_type_total": event.chartTypeTotal,
        "filters": {
          "position_id": event.positionID,
          "shipment_status": event.shipmentStatus,
          "shipment_branch_id": event.shipmentBranchId,
          "shipment_service_id": event.shipmentServiceId,
          "date_range": {
            "start_date": event.startDate,
            "end_date": event.endDate
          }
        }
      }),
    );
    final data = jsonDecode(response.body);
    log(data.toString());
    try {
      if (data['status'] == 200) {
        log(" _onGetHomeScreenDashBoard OKOK");
        emit(HomeScreenDashBoardStateSuccess(
            homeChartDataModel: HomeChartDataModel.fromJson(data)));
      } else {
        log("ERROR _onGetHomeScreenDashBoard 1");
        emit(HomeScreenDashBoardStateFailure());
      }
    } catch (error) {
      log("ERROR _onGetHomeScreenDashBoard 2 $error");
      if (error is http.ClientException) {
        emit(HomeScreenDashBoardStateFailure(
            errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(HomeScreenDashBoardStateFailure(errorText: error.toString()));
      }
    }
  }
}

class FilterDashBoardBloc
    extends Bloc<FilterDashBoardEvent, FilterDashBoardState> {
  FilterDashBoardBloc() : super(FilterDashBoardStateLoading()) {
    on<GetDataFilterDashBoardEvent>(_onGetDataFilterDashBoardEvent);
  }

  Future<void> _onGetDataFilterDashBoardEvent(
    GetDataFilterDashBoardEvent event,
    Emitter<FilterDashBoardState> emit,
  ) async {
    emit(FilterDashBoardStateLoading());

    final response = await http.post(
      Uri.parse('$baseUrl$getSetupDataDashboard'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
    );
    final data = jsonDecode(response.body);

    try {
      if (data['status'] == 200) {
        log(" _onGetDataFilterDashBoardEvent OKOK");
        emit(FilterDashBoardStateSuccess(
            setUpDashBoardModel: SetUpDashBoardModel.fromJson(data)));
      } else {
        log("ERROR _onGetDataFilterDashBoardEvent 1");
        emit(FilterDashBoardStateFailure());
      }
    } catch (error) {
      log("ERROR _onGetDataFilterDashBoardEvent 2 $error");
      if (error is http.ClientException) {
        emit(FilterDashBoardStateFailure(
            errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(FilterDashBoardStateFailure(errorText: error.toString()));
      }
    }
  }
}
