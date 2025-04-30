import 'package:scan_barcode_app/data/models/home/home_chart_data_model.dart';
import 'package:scan_barcode_app/data/models/home/setup_dashboard_model.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';

abstract class HomeScreenState {}

class HomeScreenLoading extends HomeScreenState {}

class HomeScreenSuccess extends HomeScreenState {
  final InforAccountModel dataInforAccount;
  HomeScreenSuccess({required this.dataInforAccount});
}

class HomeScreenFailure extends HomeScreenState {
  final String? errorText;
  HomeScreenFailure({this.errorText});
}

class HomeScreenTokenOutOfDate extends HomeScreenState {}

abstract class HomeScreenDashBoardState {}

class HomeScreenDashBoardStateLoading extends HomeScreenDashBoardState {}

class HomeScreenDashBoardStateSuccess extends HomeScreenDashBoardState {
  final HomeChartDataModel homeChartDataModel;
  HomeScreenDashBoardStateSuccess({required this.homeChartDataModel});
}

class HomeScreenDashBoardStateFailure extends HomeScreenDashBoardState {
  final String? errorText;
  HomeScreenDashBoardStateFailure({this.errorText});
}

abstract class FilterDashBoardState {}

class FilterDashBoardStateLoading extends FilterDashBoardState {}

class FilterDashBoardStateSuccess extends FilterDashBoardState {
  final SetUpDashBoardModel setUpDashBoardModel;
  FilterDashBoardStateSuccess({required this.setUpDashBoardModel});
}

class FilterDashBoardStateFailure extends FilterDashBoardState {
  final String? errorText;
  FilterDashBoardStateFailure({this.errorText});
}
