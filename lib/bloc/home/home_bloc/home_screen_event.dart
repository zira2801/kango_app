abstract class HomeScreenEvent {}

class HomeScreenButtonPressed extends HomeScreenEvent {
  HomeScreenButtonPressed();
}

abstract class HomeScreenDashBoardEvent {}

class GetHomeScreenDashBoard extends HomeScreenDashBoardEvent {
  final String chartTypeDate;
  final String chartTypeTotal;
  final int? positionID;
  final int? shipmentStatus;
  final int? shipmentBranchId;
  final int? shipmentServiceId;
  final String? startDate;
  final String? endDate;
  GetHomeScreenDashBoard({
    required this.chartTypeDate,
    required this.chartTypeTotal,
    required this.positionID,
    required this.shipmentStatus,
    required this.shipmentBranchId,
    required this.shipmentServiceId,
    required this.startDate,
    required this.endDate,
  });
}

abstract class FilterDashBoardEvent {}

class GetDataFilterDashBoardEvent extends FilterDashBoardEvent {
  GetDataFilterDashBoardEvent();
}
