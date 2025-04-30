part of 'create_new_shipment_bloc.dart';

abstract class CreateNewShipmentEvent extends Equatable {
  const CreateNewShipmentEvent();

  @override
  List<Object?> get props => [];
}

abstract class GetDeliveryServiceEvent extends Equatable {
  const GetDeliveryServiceEvent();

  @override
  List<Object?> get props => [];
}

class GetDeliveryService extends GetDeliveryServiceEvent {
  final int? currentIDCountryReciver;
  const GetDeliveryService({
    required this.currentIDCountryReciver,
  });
  @override
  List<Object?> get props => [currentIDCountryReciver];
}

abstract class GetListOldReceiverEvent extends Equatable {
  const GetListOldReceiverEvent();

  @override
  List<Object?> get props => [];
}

class GetListOldReceiver extends GetListOldReceiverEvent {
  const GetListOldReceiver();
  @override
  List<Object?> get props => [];
}

abstract class GetAllUnitShipmentEvent extends Equatable {
  const GetAllUnitShipmentEvent();

  @override
  List<Object?> get props => [];
}

class GetAllUnitShipment extends GetAllUnitShipmentEvent {
  const GetAllUnitShipment();
  @override
  List<Object?> get props => [];
}

abstract class HandleGetInforOldRecieveEvent extends Equatable {
  const HandleGetInforOldRecieveEvent();

  @override
  List<Object?> get props => [];
}

class HandleGetInforOldRecieve extends HandleGetInforOldRecieveEvent {
  final int? receiverID;
  const HandleGetInforOldRecieve({required this.receiverID});
  @override
  List<Object?> get props => [receiverID];
}

abstract class HandleGetInforUserEvent extends Equatable {
  const HandleGetInforUserEvent();

  @override
  List<Object?> get props => [];
}

class HandleGetInforUser extends HandleGetInforUserEvent {
  final int? userID;
  const HandleGetInforUser({required this.userID});
  @override
  List<Object?> get props => [userID];
}
