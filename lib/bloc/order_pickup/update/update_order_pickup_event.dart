abstract class UpdateOrderPickupEvent {}

class HanldeUpdateOrderPickup extends UpdateOrderPickupEvent {
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
  final double? latitude;
  final double? longitude;
  final String? orderPickupCancelDes;
  HanldeUpdateOrderPickup({
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
    this.latitude,
    this.longitude,
    required this.orderPickupCancelDes,
  });
}
