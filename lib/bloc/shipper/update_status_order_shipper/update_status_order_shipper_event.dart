part of 'update_status_order_shipper_bloc.dart';

abstract class UpdateStatusOrderPickupShipperEvent extends Equatable {
  const UpdateStatusOrderPickupShipperEvent();

  @override
  List<Object?> get props => [];
}

class HanldeUpdateStatusOrderPickupShipper
    extends UpdateStatusOrderPickupShipperEvent {
  final int? orderPickUpID;
  final int orderPickUpType;
  final int branchIDEdit;
  final int? fwd;
  final String orderPickUpTime;
  final String orderPickUpAWB;
  final String orderPickUpGrossWeight;
  final String orderPickUpNumberPackage;
  final String orderPickUpPhone;
  final String orderPickUpAdrees;
  final String? orderPickUpNote;
  final int? orderPickUpStatus;
  final String? orderPickUpImage;
  final String? orderPickupName;
  final double latitude;
  final double longitude;
  final String? orderPickupCancelDes;
  HanldeUpdateStatusOrderPickupShipper({
    required this.orderPickUpID,
    required this.orderPickUpType,
    required this.branchIDEdit,
    required this.fwd,
    required this.orderPickUpTime,
    required this.orderPickUpAWB,
    required this.orderPickUpGrossWeight,
    required this.orderPickUpNumberPackage,
    required this.orderPickUpPhone,
    required this.orderPickUpAdrees,
    required this.orderPickUpNote,
    required this.orderPickUpStatus,
    required this.orderPickUpImage,
    required this.orderPickupName,
    required this.latitude,
    required this.longitude,
    required this.orderPickupCancelDes,
  });
  @override
  List<Object?> get props => [
        orderPickUpID,
        orderPickUpType,
        branchIDEdit,
        fwd,
        orderPickUpTime,
        orderPickUpAWB,
        orderPickUpGrossWeight,
        orderPickUpNumberPackage,
        orderPickUpPhone,
        orderPickUpAdrees,
        orderPickUpNote,
        orderPickUpStatus,
        orderPickUpImage,
        orderPickupName,
        latitude,
        longitude,
        orderPickupCancelDes,
      ];
}
