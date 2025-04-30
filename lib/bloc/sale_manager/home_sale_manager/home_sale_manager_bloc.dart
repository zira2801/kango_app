import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/sale_leader/cost_fwd.dart';
import 'package:scan_barcode_app/data/models/sale_leader/fwd_no_link.dart';
import 'package:scan_barcode_app/data/models/sale_leader/fwd_support_model.dart';
import 'package:scan_barcode_app/data/models/sale_leader/sale_leader_info.dart';
import 'package:scan_barcode_app/data/models/sale_leader/sale_support_fwd.dart';
import 'package:scan_barcode_app/data/models/sale_leader/sale_team_leader.dart';
import 'package:scan_barcode_app/data/models/sale_leader/shipment_fwd_model.dart';
import 'package:scan_barcode_app/data/models/sale_leader/shipment_sale.dart';
import 'package:scan_barcode_app/data/models/sale_leader/user_sale_leader.dart';
import 'package:scan_barcode_app/data/models/sale_manager/home_sale_manager.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'home_sale_manager_event.dart';
part 'home_sale_manager_state.dart';

class SaleManagerBloc extends Bloc<SaleManagerEvent, SaleManagerState> {
  SaleManagerBloc() : super(GetHomeSaleManagerStateInitial()) {
    on<GetHomeSaleManager>(_onGetHomeSaleManager);
  }

//Lấy thông tin trang Dashboard của Sale Manager
  Future<void> _onGetHomeSaleManager(
    GetHomeSaleManager event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(GetHomeSaleManagerStateLoading());

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$getHomeSaleManager'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        log("SUCCESS _onGetHomeSaleManager ");
        final response = HomeSaleManager.fromJson(data);
        emit(GetHomeSaleManagerStateSuccess(saleDashboard: response));
      } else {
        log("ERROR _onGetHomeSaleManager 1");
        emit(GetHomeSaleManagerStateFailure(message: data['message']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onGetHomeSaleManager 2 $error");
        emit(const GetHomeSaleManagerStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onGetHomeSaleManager 3");
        emit(GetHomeSaleManagerStateFailure(message: error.toString()));
      }
    }
  }
}

//Lấy thông tin Sale Team Leader
class GetListSaleTeamLeaderBloc
    extends Bloc<SaleManagerEvent, SaleManagerState> {
  GetListSaleTeamLeaderBloc() : super(GetSaleTeamLeaderStateInitial()) {
    on<GetSaleTeamLeader>(_onGetSaleTeamLeader);
    on<LoadMoreSaleTeamLeader>(_onLoadMoreSaleTeamLeader);
  }
  Future<void> _onGetSaleTeamLeader(
    GetSaleTeamLeader event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(GetSaleTeamLeaderStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getSaleLeaderList'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'paginate': {'limit': 10, 'page': 1},
          'filters': {
            'date_range': {
              'start_date': event.startDate,
              'end_date': event.endDate
            },
            'keywords': event.keywords,
          }
        }),
      );
      final data = jsonDecode(response.body);
      final mess = data['message'];
      if (data['status'] == 200) {
        final response = SaleLeaderListResponse.fromJson(data);
        final saleLeadersData = response.teams;
        emit(GetSaleTeamLeaderStateSuccess(
            data: saleLeadersData ?? [],
            page: 1,
            hasReachedMax: (saleLeadersData?.length ?? 0) < 10));
      } else {
        log("ERROR _onGetSaleTeamLeader 1");
        emit(GetSaleTeamLeaderStateFailure(message: mess['text']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onGetSaleTeamLeader 2 $error");
        emit(const GetSaleTeamLeaderStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onGetSaleTeamLeader 3");
        emit(GetSaleTeamLeaderStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreSaleTeamLeader(
    LoadMoreSaleTeamLeader event,
    Emitter<SaleManagerState> emit,
  ) async {
    if (state is GetSaleTeamLeaderStateSuccess &&
        !(state as GetSaleTeamLeaderStateSuccess).hasReachedMax) {
      final currentState = state as GetSaleTeamLeaderStateSuccess;
      try {
        // Gửi request POST đến API
        final response = await http.post(
          Uri.parse('$baseUrl$getSaleLeaderList'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'paginate': {'limit': 10, 'page': currentState.page + 1},
            'filters': {
              'date_range': {
                'start_date': event.startDate,
                'end_date': event.endDate,
              },
              'keywords': event.keywords,
            },
          }),
        );

        // Parse dữ liệu từ response
        final data = jsonDecode(response.body);
        final mess = data['message'];

        if (data['status'] == 200) {
          log("SUCCESS _onLoadMoreSaleTeamLeader");
          final saleResponse = SaleLeaderListResponse.fromJson(data);
          final saleLeadersData = saleResponse.teams ?? [];

          if (saleLeadersData.isEmpty) {
            // Không có dữ liệu mới, đánh dấu đã hết
            emit(currentState.copyWith(hasReachedMax: true));
          } else {
            // Lọc dữ liệu trùng dựa trên saleTeamId
            final newData = saleLeadersData
                .where((newItem) => !currentState.data
                    .any((oldItem) => oldItem.saleTeamId == newItem.saleTeamId))
                .toList();

            if (newData.isEmpty) {
              // Không có dữ liệu mới sau khi lọc, đánh dấu đã hết
              emit(currentState.copyWith(hasReachedMax: true));
            } else {
              // Có dữ liệu mới, nối vào danh sách cũ và emit state mới
              final updatedData = currentState.data + newData;
              emit(GetSaleTeamLeaderStateSuccess(
                data: updatedData,
                page: currentState.page + 1,
                hasReachedMax: saleLeadersData.length < 10,
              ));
            }
          }
        } else {
          log("ERROR _onLoadMoreSaleTeamLeader: ${mess['text']}");
          emit(GetSaleTeamLeaderStateFailure(message: mess['text']));
        }
      } catch (error) {
        log("ERROR _onLoadMoreSaleTeamLeader: $error");
        if (error is http.ClientException) {
          emit(const GetSaleTeamLeaderStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          emit(GetSaleTeamLeaderStateFailure(message: error.toString()));
        }
      }
    }
  }
}

//Lấy danh sách User có thể thêm vào team
class GetUsersSaleLeaderBloc extends Bloc<SaleManagerEvent, SaleManagerState> {
  GetUsersSaleLeaderBloc() : super(GetUsersSaleLeaderStateInitial()) {
    on<GetUsersSaleLeader>(_onGetUsersSaleLeader);
    on<LoadMoreUsersSaleLeader>(_onLoadMoreUsersSaleLeader);
  }

  Future<void> _onGetUsersSaleLeader(
    GetUsersSaleLeader event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(GetUsersSaleLeaderStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getUsersSaleList'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'paginate': {'limit': 10, 'page': 1},
          'filters': {
            'keywords': event.keywords,
          },
          'position_name': event.positionName,
          'user_not_in': event.userNotIn,
        }),
      );
      final data = jsonDecode(response.body);
      final mess = data['message'];
      if (data['status'] == 200) {
        final response = UserSaleLeaderResponse.fromJson(data);
        final usersData = response.users;
        emit(GetUsersSaleLeaderStateSuccess(
            data: usersData ?? [],
            page: 1,
            hasReachedMax: (usersData?.length ?? 0) < 10));
        log("SUCCESS _onGetUsersSaleLeader ");
      } else {
        log("ERROR _onGetUsersSaleLeader 1");
        emit(GetUsersSaleLeaderStateFailure(message: mess['text']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onGetUsersSaleLeader 2 $error");
        emit(const GetUsersSaleLeaderStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onGetUsersSaleLeader 3");
        emit(GetUsersSaleLeaderStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreUsersSaleLeader(
    LoadMoreUsersSaleLeader event,
    Emitter<SaleManagerState> emit,
  ) async {
    if (state is GetUsersSaleLeaderStateSuccess &&
        !(state as GetUsersSaleLeaderStateSuccess).hasReachedMax) {
      final currentState = state as GetUsersSaleLeaderStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getUsersSaleList'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'paginate': {'limit': 10, 'page': currentState.page + 1},
            'filters': {
              'keywords': event.keywords,
            },
            'position_name': event.positionName,
            'user_not_in': event.userNotIn,
          }),
        );
        final data = jsonDecode(response.body);
        final mess = data['message'];
        if (data['status'] == 200) {
          log("SUCCESS _onLoadMoreSaleTeamLeader");
          final response = UserSaleLeaderResponse.fromJson(data);
          final usersData = response.users;
          emit(usersData!.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : GetUsersSaleLeaderStateSuccess(
                  data: currentState.data + usersData,
                  page: currentState.page + 1,
                  hasReachedMax: usersData.length < 10,
                ));
        } else {
          log("ERROR _onLoadMoreSaleTeamLeader 1");
          emit(GetUsersSaleLeaderStateFailure(message: mess['text']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onLoadMoreSaleTeamLeader $error");
          emit(const GetUsersSaleLeaderStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreSaleTeamLeader 3");
          emit(GetUsersSaleLeaderStateFailure(message: error.toString()));
        }
      }
    }
  }
}

//Thêm member vào team
class AddMemberToTeamBloc extends Bloc<AddMemberToTeam, SaleManagerState> {
  AddMemberToTeamBloc() : super(AddMemberToTeamStateInitial()) {
    on<AddMemberToTeam>(_onHanldeUAddMemberToTeam);
  }

  Future<void> _onHanldeUAddMemberToTeam(
    AddMemberToTeam event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(AddMemberToTeamStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$addSaleMember'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          "leader_id": event.leaderId,
          "arr_user_id": event.userIds,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        emit(AddMemberToTeamStateSuccess(message: mess));
        log("_onHanldeUAddMemberToTeam OKOK");
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log('_onHanldeUAddMemberToTeam error $mess 1');
        emit(AddMemberToTeamStateFailure(message: mess));
      }
    } catch (error) {
      log('_onHanldeUAddMemberToTeam error 2: $error');
      if (error is http.ClientException) {
        emit(const AddMemberToTeamStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else if (error is TypeError) {
        emit(const AddMemberToTeamStateFailure(
            message: "Dữ liệu trả về không đúng định dạng"));
      } else {
        emit(AddMemberToTeamStateFailure(message: error.toString()));
      }
    }
  }
}

//Lấy thống kê Sale Leader
class GetSaleLeaderStatisticBloc
    extends Bloc<GetDetailSaleLeader, SaleManagerState> {
  GetSaleLeaderStatisticBloc() : super(GetDetailsSaleLeaderInitial()) {
    on<GetDetailSaleLeader>(_onGetSaleLeaderStatistic);
  }

  Future<void> _onGetSaleLeaderStatistic(
    GetDetailSaleLeader event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(GetDetailsSaleLeaderLoading());

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl$saleLeaderInfo?sale_code=${event.saleCode}&monthDate=${event.monthDate}'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final dataSaleStaticstic = SaleStatisticsResponse.fromJson(data);
        emit(GetDetailsSaleLeaderSuccess(
            saleStatisticsResponse: dataSaleStaticstic));
        log("SUCCESS _onGetSaleLeaderStatistic ");
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log("ERROR _onGetSaleLeaderStatistic 1 $mess");
        emit(GetDetailsSaleLeaderFailure(message: mess));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onGetSaleLeaderStatistic 2 $error");
        emit(const GetDetailsSaleLeaderFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onGetSaleLeaderStatistic 3");
        emit(GetDetailsSaleLeaderFailure(message: error.toString()));
      }
    }
  }
}

//Lấy danh sách shipment của sale
class GetListShipmentSaleBloc extends Bloc<SaleManagerEvent, SaleManagerState> {
  GetListShipmentSaleBloc() : super(GetShipmentsSaleLeaderStateInitial()) {
    on<GetShipmentSale>(_onGetShipmentSale);
    on<LoadMoreShipmentSale>(_onLoadMoreShipmentSale);
  }
  Future<void> _onGetShipmentSale(
    GetShipmentSale event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(GetShipmentsSaleLeaderStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getShipmentsSale'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'user_id': event.userId,
          'limit': 10,
          'page': 1,
          'filters': {
            'keywords': event.keywords,
            'date_range': {
              "start_date": event.startDate,
              "end_date": event.endDate
            }
          }
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final response = ShipmentSaleResponse.fromJson(data);
        final shipmentsSaleData = response.shipments.data;
        emit(GetShipmentsSaleLeaderStateSuccess(
            data: shipmentsSaleData ?? [],
            page: 1,
            hasReachedMax: (shipmentsSaleData.length) < 10));
        log('SUCCESS _onGetShipmentSale ');
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log("ERROR _onGetShipmentSale 1");
        emit(GetShipmentsSaleLeaderStateFailure(message: mess));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onGetShipmentSale 2 $error");
        emit(const GetShipmentsSaleLeaderStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onGetShipmentSale 3");
        emit(GetShipmentsSaleLeaderStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreShipmentSale(
    LoadMoreShipmentSale event,
    Emitter<SaleManagerState> emit,
  ) async {
    if (state is GetShipmentsSaleLeaderStateSuccess &&
        !(state as GetShipmentsSaleLeaderStateSuccess).hasReachedMax) {
      final currentState = state as GetShipmentsSaleLeaderStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getShipmentsSale'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'user_id': event.userId,
            'limit': 10,
            'page': currentState.page + 1,
            'filters': {
              'keywords': event.keywords,
              'date_range': {
                "start_date": event.startDate,
                "end_date": event.endDate
              }
            }
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          if (data['status'] == 200) {
            final response = ShipmentSaleResponse.fromJson(data);
            final shipmentsSaleData = response.shipments.data;
            emit(shipmentsSaleData.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : GetShipmentsSaleLeaderStateSuccess(
                    data: currentState.data + shipmentsSaleData,
                    page: currentState.page + 1,
                    hasReachedMax: shipmentsSaleData.length < 10,
                  ));
          }
          log("SUCCESS _onLoadMoreShipmentSale");
        } else {
          final mess = data['message'] is Map
              ? data['message']['text']
              : data['message'];
          log("ERROR _onLoadMoreShipmentSale 1");
          emit(GetShipmentsSaleLeaderStateFailure(message: mess));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onLoadMoreShipmentSale $error");
          emit(const GetShipmentsSaleLeaderStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreShipmentSale 3");
          emit(GetShipmentsSaleLeaderStateFailure(message: error.toString()));
        }
      }
    }
  }
}

//Lấy danh sách Sale hỗ trợ FWD
class GetListSaleSupportFWDBloc
    extends Bloc<SaleManagerEvent, SaleManagerState> {
  GetListSaleSupportFWDBloc() : super(GetListSaleSupportFWDStateInitial()) {
    on<GetSaleSupportFWD>(_onGetListSaleSupportFWD);
    on<LoadMoreSaleSupportFWD>(_onLoadMoreListSaleSupportFWD);
  }
  Future<void> _onGetListSaleSupportFWD(
    GetSaleSupportFWD event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(GetListSaleSupportFWDStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListSaleSupportFWD'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'paginate': {
            'limit': 10,
            'page': 1,
          },
          'filters': {
            'date_range': {
              "start_date": event.startDate,
              "end_date": event.endDate
            },
            'keywords': event.keywords
          }
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final response = SaleSupportFWDResponse.fromJson(data);
        final listSaleSupportFWD = response.users;
        emit(GetListSaleSupportFWDStateSuccess(
            data: listSaleSupportFWD ?? [],
            page: 1,
            hasReachedMax: (listSaleSupportFWD.length) < 10));
        log('SUCCESS _onGetListSaleSupportFWD ');
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log("ERROR _onGetListSaleSupportFWD 1");
        emit(GetListSaleSupportFWDStateFailure(message: mess));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onGetListSaleSupportFWD 2 $error");
        emit(const GetListSaleSupportFWDStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onGetListSaleSupportFWD 3");
        emit(GetListSaleSupportFWDStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListSaleSupportFWD(
    LoadMoreSaleSupportFWD event,
    Emitter<SaleManagerState> emit,
  ) async {
    if (state is GetListSaleSupportFWDStateSuccess &&
        !(state as GetListSaleSupportFWDStateSuccess).hasReachedMax) {
      final currentState = state as GetListSaleSupportFWDStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getListSaleSupportFWD'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'paginate': {
              'limit': 10,
              'page': currentState.page + 1,
            },
            'filters': {
              'date_range': {
                "start_date": event.startDate,
                "end_date": event.endDate
              },
              'keywords': event.keywords
            }
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          if (data['status'] == 200) {
            final response = SaleSupportFWDResponse.fromJson(data);
            final listSaleSupportFWD = response.users;
            emit(listSaleSupportFWD.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : GetListSaleSupportFWDStateSuccess(
                    data: currentState.data + listSaleSupportFWD,
                    page: currentState.page + 1,
                    hasReachedMax: listSaleSupportFWD.length < 10,
                  ));
          }
          log("SUCCESS _onLoadMoreListSaleSupportFWD");
        } else {
          final mess = data['message'] is Map
              ? data['message']['text']
              : data['message'];
          log("ERROR _onLoadMoreListSaleSupportFWD 1");
          emit(GetListSaleSupportFWDStateFailure(message: mess));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onLoadMoreListSaleSupportFWD $error");
          emit(const GetListSaleSupportFWDStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreListSaleSupportFWD 3");
          emit(GetListSaleSupportFWDStateFailure(message: error.toString()));
        }
      }
    }
  }
}

//Lấy danh sách FWD không liên kết
class GetListFwdNoLinkBloc extends Bloc<SaleManagerEvent, SaleManagerState> {
  GetListFwdNoLinkBloc() : super(GetListFWDNoLinkStateInitial()) {
    on<GetListFWDNoLink>(_onGetListFwdNoLink);
    on<LoadMoreListFWDNoLink>(_onLoadMoreListFwdNoLink);
  }
  Future<void> _onGetListFwdNoLink(
    GetListFWDNoLink event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(GetListFWDNoLinkStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListFwdNoLink'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'paginate': {
            'limit': 10,
            'page': 1,
          },
          "company_id": event.companyID
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final response = UserFwdNoLinkResponse.fromJson(data);
        final listFwdNoLink = response.fwds;
        emit(GetListFWDNoLinkStateSuccess(
            data: listFwdNoLink ?? [],
            page: 1,
            hasReachedMax: (listFwdNoLink.length) < 10));
        log('SUCCESS _onGetListFwdNoLink ');
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log("ERROR _onGetListFwdNoLink 1");
        emit(GetListFWDNoLinkStateFailure(message: mess));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onGetListFwdNoLink 2 $error");
        emit(const GetListFWDNoLinkStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onGetListFwdNoLink 3");
        emit(GetListFWDNoLinkStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListFwdNoLink(
    LoadMoreListFWDNoLink event,
    Emitter<SaleManagerState> emit,
  ) async {
    if (state is GetListFWDNoLinkStateSuccess &&
        !(state as GetListFWDNoLinkStateSuccess).hasReachedMax) {
      final currentState = state as GetListFWDNoLinkStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getListFwdNoLink'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'paginate': {
              'limit': 10,
              'page': currentState.page + 1,
            },
            "company_id": event.companyID
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          if (data['status'] == 200) {
            final response = UserFwdNoLinkResponse.fromJson(data);
            final listFwdNoLink = response.fwds;
            emit(listFwdNoLink.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : GetListFWDNoLinkStateSuccess(
                    data: currentState.data + listFwdNoLink,
                    page: currentState.page + 1,
                    hasReachedMax: listFwdNoLink.length < 10,
                  ));
          }
          log("SUCCESS _onLoadMoreListFwdNoLink");
        } else {
          final mess = data['message'] is Map
              ? data['message']['text']
              : data['message'];
          log("ERROR _onLoadMoreListFwdNoLink 1");
          emit(GetListFWDNoLinkStateFailure(message: mess));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onLoadMoreListFwdNoLink $error");
          emit(const GetListFWDNoLinkStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreListFwdNoLink 3");
          emit(GetListFWDNoLinkStateFailure(message: error.toString()));
        }
      }
    }
  }
}

//Liên kết FWD với Sale
class LinkFwdToSaleBloc extends Bloc<SaleManagerEvent, SaleManagerState> {
  LinkFwdToSaleBloc() : super(LinkFWDToSaleStateInitial()) {
    on<LinkFWDToSale>(_onHanldeLinkFwdToSale);
  }

  Future<void> _onHanldeLinkFwdToSale(
    LinkFWDToSale event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(LinkFWDToSaleStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$linkFwdToSaleApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          "is_api": true,
          "fwd_ids": event.fwdIds,
          "sale_id": event.saleId,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        emit(LinkFWDToSaleStateSuccess(message: mess));
        log("_onHanldeLinkFwdToSale OKOK");
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log('_onHanldeLinkFwdToSale error $mess 1');
        emit(LinkFWDToSaleStateFailure(message: mess));
      }
    } catch (error) {
      log('_onHanldeLinkFwdToSale error 2: $error');
      if (error is http.ClientException) {
        emit(const LinkFWDToSaleStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else if (error is TypeError) {
        emit(const LinkFWDToSaleStateFailure(
            message: "Dữ liệu trả về không đúng định dạng"));
      } else {
        emit(LinkFWDToSaleStateFailure(message: error.toString()));
      }
    }
  }
}

//Lấy thông tin của FWD hỗ trợ

class GetDetailFwdSupportBloc
    extends Bloc<GetDetailFwdSupport, SaleManagerState> {
  GetDetailFwdSupportBloc() : super(GetDetailsFwdSupportInitial()) {
    on<GetDetailFwdSupport>(_onGetDetailFwdSupport);
  }

  Future<void> _onGetDetailFwdSupport(
    GetDetailFwdSupport event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(GetDetailsFwdSupportLoading());

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl$getDetailFwdSupportAPI?company_code=${event.companyCode}'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final dataFwdSupport = ResponseFwdSupportModel.fromJson(data);
        emit(GetDetailsFwdSupportSuccess(
            responseFwdSupportModel: dataFwdSupport));
        log("SUCCESS _onGetDetailFwdSupport ");
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log("ERROR _onGetDetailFwdSupport 1 $mess");
        emit(GetDetailsFwdSupportFailure(message: mess));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onGetDetailFwdSupport 2 $error");
        emit(const GetDetailsFwdSupportFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onGetDetailFwdSupport 3");
        emit(GetDetailsFwdSupportFailure(message: error.toString()));
      }
    }
  }
}

//Lấy danh sách Cost của FWD
class GetListCostFWDBloc extends Bloc<SaleManagerEvent, SaleManagerState> {
  GetListCostFWDBloc() : super(GetListCostStateInitial()) {
    on<GetListCodeFWD>(_onGetListCostFWD);
    on<LoadMoreListCostFWD>(_onLoadMoreListCostFWD);
  }
  Future<void> _onGetListCostFWD(
    GetListCodeFWD event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(GetListCostStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListCostFwd'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'paginate': {
            'limit': 10,
            'page': 1,
          },
          "company_id": event.companyID
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final response = UserCostResponse.fromJson(data);
        final listCostFwd = response.users;
        emit(GetListCostStateSuccess(
            data: listCostFwd ?? [],
            page: 1,
            hasReachedMax: (listCostFwd!.length) < 10));
        log('SUCCESS _onGetListCostFWD ');
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log("ERROR _onGetListCostFWD 1");
        emit(GetListCostStateFailure(message: mess));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onGetListCostFWD 2 $error");
        emit(const GetListCostStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onGetListCostFWD 3");
        emit(GetListCostStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListCostFWD(
    LoadMoreListCostFWD event,
    Emitter<SaleManagerState> emit,
  ) async {
    if (state is GetListCostStateSuccess &&
        !(state as GetListCostStateSuccess).hasReachedMax) {
      final currentState = state as GetListCostStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getListCostFwd'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'paginate': {
              'limit': 10,
              'page': currentState.page + 1,
            },
            "company_id": event.companyID
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          if (data['status'] == 200) {
            final response = UserCostResponse.fromJson(data);
            final listCostFwd = response.users;
            emit(listCostFwd!.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : GetListCostStateSuccess(
                    data: currentState.data + listCostFwd,
                    page: currentState.page + 1,
                    hasReachedMax: listCostFwd.length < 10,
                  ));
          }
          log("SUCCESS _onLoadMoreListCostFWD");
        } else {
          final mess = data['message'] is Map
              ? data['message']['text']
              : data['message'];
          log("ERROR _onLoadMoreListCostFWD 1");
          emit(GetListCostStateFailure(message: mess));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR __onLoadMoreListCostFWD 2 $error");
          emit(const GetListCostStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR __onLoadMoreListCostFWD 3");
          emit(GetListCostStateFailure(message: error.toString()));
        }
      }
    }
  }
}

//Lấy danh sách shipment của sale
class GetListShipmentFwdBloc extends Bloc<SaleManagerEvent, SaleManagerState> {
  GetListShipmentFwdBloc() : super(GetListShipmentFWDStateInitial()) {
    on<GetShipmentFWD>(_onGetShipmentFWD);
    on<LoadMoreShipmentFWD>(_onLoadMoreShipmentFWD);
  }
  Future<void> _onGetShipmentFWD(
    GetShipmentFWD event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(GetListShipmentFWDStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListShipmentFWD'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'user_id': event.userID,
          'limit': 10,
          'page': 1,
          'filters': {
            'date_range': {
              "start_date": event.startDate,
              "end_date": event.endDate
            },
            'keywords': event.keywords
          }
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final response = ShipmentFwdResponse.fromJson(data);
        final shipmentFwdData = response.shipments;
        emit(GetListShipmentFWDStateSuccess(
            data: shipmentFwdData ?? [],
            page: 1,
            hasReachedMax: (shipmentFwdData?.length)! < 10));
        log('SUCCESS _onGetShipmentFWD ');
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log("ERROR _onGetShipmentFWD 1");
        emit(GetListShipmentFWDStateFailure(message: mess));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onGetShipmentFWD 2 $error");
        emit(const GetListShipmentFWDStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onGetShipmentFWD 3");
        emit(GetListShipmentFWDStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreShipmentFWD(
    LoadMoreShipmentFWD event,
    Emitter<SaleManagerState> emit,
  ) async {
    if (state is GetListShipmentFWDStateSuccess &&
        !(state as GetListShipmentFWDStateSuccess).hasReachedMax) {
      final currentState = state as GetListShipmentFWDStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getShipmentsSale'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'user_id': event.userID,
            'limit': 10,
            'page': currentState.page + 1,
            'filters': {
              'date_range': {
                "start_date": event.startDate,
                "end_date": event.endDate
              },
              'keywords': event.keywords
            }
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          if (data['status'] == 200) {
            final response = ShipmentFwdResponse.fromJson(data);
            final shipmentFwdData = response.shipments;
            emit(shipmentFwdData!.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : GetListShipmentFWDStateSuccess(
                    data: currentState.data + shipmentFwdData,
                    page: currentState.page + 1,
                    hasReachedMax: shipmentFwdData.length < 10,
                  ));
          }
          log("SUCCESS _onLoadMoreShipmentFWD");
        } else {
          final mess = data['message'] is Map
              ? data['message']['text']
              : data['message'];
          log("ERROR _onLoadMoreShipmentFWD 1");
          emit(GetListShipmentFWDStateFailure(message: mess));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onLoadMoreShipmentFWD $error");
          emit(const GetListShipmentFWDStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreShipmentFWD 3");
          emit(GetListShipmentFWDStateFailure(message: error.toString()));
        }
      }
    }
  }
}

//XÓa sale khỏi danh sách
class DeleteSaleSupportFWDBloc
    extends Bloc<DeleteSaleSupportFWD, SaleManagerState> {
  DeleteSaleSupportFWDBloc() : super(DeleteSaleToSupportFWDStateInitial()) {
    on<DeleteSaleSupportFWD>(_onHanldeDeleteSaleSupportFWD);
  }

  Future<void> _onHanldeDeleteSaleSupportFWD(
    DeleteSaleSupportFWD event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(DeleteSaleToSupportFWDStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$deleteSaleSupportFWD'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({"is_api": true, "key_id": event.keyID}),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        emit(DeleteSaleToSupportFWDStateSuccess(message: mess));
        log("_onHanldeDeleteSaleSupportFWD OKOK");
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log('_onHanldeDeleteSaleSupportFWD error $mess 1');
        emit(DeleteSaleToSupportFWDStateFailure(message: mess));
      }
    } catch (error) {
      log('_onHanldeDeleteSaleSupportFWD error 2: $error');
      if (error is http.ClientException) {
        emit(const DeleteSaleToSupportFWDStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else if (error is TypeError) {
        emit(const DeleteSaleToSupportFWDStateFailure(
            message: "Dữ liệu trả về không đúng định dạng"));
      } else {
        emit(DeleteSaleToSupportFWDStateFailure(message: error.toString()));
      }
    }
  }
}
//Chức năng Sale Manager của Admin

//Thêm Leader
class AddLeaderBloc extends Bloc<AddLeader, SaleManagerState> {
  AddLeaderBloc() : super(AddLeaderStateInitial()) {
    on<AddLeader>(_onHanldeAddLeader);
  }

  Future<void> _onHanldeAddLeader(
    AddLeader event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(AddLeaderStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$addSaleLeader'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          "arr_user_id": event.userIds,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        emit(AddLeaderStateSuccess(message: mess));
        log("_onHanldeAddLeader OKOK");
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log('_onHanldeAddLeader error $mess 1');
        emit(AddLeaderStateFailure(message: mess));
      }
    } catch (error) {
      log('_onHanldeAddLeader error 2: $error');
      if (error is http.ClientException) {
        emit(const AddLeaderStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else if (error is TypeError) {
        emit(const AddLeaderStateFailure(
            message: "Dữ liệu trả về không đúng định dạng"));
      } else {
        emit(AddLeaderStateFailure(message: error.toString()));
      }
    }
  }
}

//Thêm Member vào Team Sale
class AddMemberToTeamSaleBloc
    extends Bloc<AddMemberToTeamSale, SaleManagerState> {
  AddMemberToTeamSaleBloc() : super(AddMemberToTeamSaleStateInitial()) {
    on<AddMemberToTeamSale>(_onHanldeAddMemberToTeamSale);
  }

  Future<void> _onHanldeAddMemberToTeamSale(
    AddMemberToTeamSale event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(AddMemberToTeamSaleStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$addSaleMember'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          "sale_team_id": event.saleTeamId,
          "arr_user_id": event.userIds,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        emit(AddMemberToTeamSaleStateSuccess(message: mess));
        log("_onHanldeAddMemberToTeamSale OKOK");
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log('_onHanldeAddMemberToTeamSale error $mess 1');
        emit(AddMemberToTeamSaleStateFailure(message: mess));
      }
    } catch (error) {
      log('_onHanldeAddMemberToTeamSale error 2: $error');
      if (error is http.ClientException) {
        emit(const AddMemberToTeamSaleStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else if (error is TypeError) {
        emit(const AddMemberToTeamSaleStateFailure(
            message: "Dữ liệu trả về không đúng định dạng"));
      } else {
        emit(AddMemberToTeamSaleStateFailure(message: error.toString()));
      }
    }
  }
}

//Cập nhật trạng thái của Member
class UpdateStatusMemeberBloc
    extends Bloc<UpdateStatusMember, SaleManagerState> {
  UpdateStatusMemeberBloc() : super(UpdateStatusMemeberStateInitial()) {
    on<UpdateStatusMember>(_onHanldeUpdateStatusMember);
  }

  Future<void> _onHanldeUpdateStatusMember(
    UpdateStatusMember event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(UpdateStatusMemeberStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$updateMemberTeam'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          "team_id": event.teamId,
          "member_id": event.memberID,
          "kind": event.kind
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        emit(UpdateStatusMemeberStateSuccess(message: mess));
        log("_onHanldeUpdateStatusMember OKOK");
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log('_onHanldeUpdateStatusMember error $mess 1');
        emit(UpdateStatusMemeberStateFailure(message: mess));
      }
    } catch (error) {
      log('_onHanldeUpdateStatusMember error 2: $error');
      if (error is http.ClientException) {
        emit(const UpdateStatusMemeberStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else if (error is TypeError) {
        emit(const UpdateStatusMemeberStateFailure(
            message: "Dữ liệu trả về không đúng định dạng"));
      } else {
        emit(UpdateStatusMemeberStateFailure(message: error.toString()));
      }
    }
  }
}

//Chuyển Member sang team khác
class TransferMemberToTeamBloc
    extends Bloc<TransferMemberToTeam, SaleManagerState> {
  TransferMemberToTeamBloc() : super(TransferMemberToTeamStateInitial()) {
    on<TransferMemberToTeam>(_onHanldeTransferMemberToTeam);
  }

  Future<void> _onHanldeTransferMemberToTeam(
    TransferMemberToTeam event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(TransferMemberToTeamStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$transferMemberToTeam'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          "team_id": event.teamId,
          "member_id": event.memberID,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        emit(TransferMemberToTeamStateSuccess(message: mess));
        log("_onHanldeTransferMemberToTeam OKOK");
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log('_onHanldeTransferMemberToTeam error $mess 1');
        emit(TransferMemberToTeamStateFailure(message: mess));
      }
    } catch (error) {
      log('_onHanldeTransferMemberToTeam error 2: $error');
      if (error is http.ClientException) {
        emit(const TransferMemberToTeamStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else if (error is TypeError) {
        emit(const TransferMemberToTeamStateFailure(
            message: "Dữ liệu trả về không đúng định dạng"));
      } else {
        emit(TransferMemberToTeamStateFailure(message: error.toString()));
      }
    }
  }
}

//Xóa Team Sale
class DeleteTeamBloc extends Bloc<DeleteTeamSale, SaleManagerState> {
  DeleteTeamBloc() : super(DeleteTeamSaleStateInitial()) {
    on<DeleteTeamSale>(_onHanldeDeleteTeamSale);
  }

  Future<void> _onHanldeDeleteTeamSale(
    DeleteTeamSale event,
    Emitter<SaleManagerState> emit,
  ) async {
    emit(DeleteTeamSaleStateLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$deleteTeam'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          "team_id": event.teamId,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        emit(DeleteTeamSaleStateSuccess(message: mess));
        log("_onHanldeDeleteTeamSale OKOK");
      } else {
        final mess =
            data['message'] is Map ? data['message']['text'] : data['message'];
        log('_onHanldeDeleteTeamSale error $mess 1');
        emit(DeleteTeamSaleStateFailure(message: mess));
      }
    } catch (error) {
      log('_onHanldeDeleteTeamSale error 2: $error');
      if (error is http.ClientException) {
        emit(const DeleteTeamSaleStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else if (error is TypeError) {
        emit(const DeleteTeamSaleStateFailure(
            message: "Dữ liệu trả về không đúng định dạng"));
      } else {
        emit(DeleteTeamSaleStateFailure(message: error.toString()));
      }
    }
  }
}
