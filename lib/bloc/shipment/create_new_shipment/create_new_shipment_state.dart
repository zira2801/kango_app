part of 'create_new_shipment_bloc.dart';

abstract class CreateNewShipmentState extends Equatable {
  const CreateNewShipmentState();
  @override
  List<Object?> get props => [];
}

class CreateNewShipmentStateInitial extends CreateNewShipmentState {}

class CreateNewShipmentStateLoading extends CreateNewShipmentState {}

class CreateNewShipmentStateSuccess extends CreateNewShipmentState {}

class CreateNewShipmentStateFailure extends CreateNewShipmentState {}

abstract class GetDeliveryServiceState extends Equatable {
  const GetDeliveryServiceState();
  @override
  List<Object?> get props => [];
}

class GetDeliveryServiceStateInitial extends GetDeliveryServiceState {}

class GetDeliveryServiceStateLoading extends GetDeliveryServiceState {}

class GetDeliveryServiceStateSuccess extends GetDeliveryServiceState {
  final DeliveryServiceModel data;
  const GetDeliveryServiceStateSuccess({
    required this.data,
  });
  GetDeliveryServiceStateSuccess copyWith({
    DeliveryServiceModel? data,
  }) {
    return GetDeliveryServiceStateSuccess(
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [data];
}

class GetDeliveryServiceStateFailure extends GetDeliveryServiceState {
  final String message;

  const GetDeliveryServiceStateFailure({required this.message});

  GetDeliveryServiceStateFailure copyWith({String? message}) {
    return GetDeliveryServiceStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class GetListOldReceiverState extends Equatable {
  const GetListOldReceiverState();
  @override
  List<Object?> get props => [];
}

class GetListOldReceiverStateInitial extends GetListOldReceiverState {}

class GetListOldReceiverStateLoading extends GetListOldReceiverState {}

class GetListOldReceiverStateSuccess extends GetListOldReceiverState {
  final ListOldReceiverModel data;
  const GetListOldReceiverStateSuccess({
    required this.data,
  });
  GetListOldReceiverStateSuccess copyWith({
    ListOldReceiverModel? data,
  }) {
    return GetListOldReceiverStateSuccess(
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [data];
}

class GetListOldReceiverStateFailure extends GetListOldReceiverState {
  final String message;

  const GetListOldReceiverStateFailure({required this.message});

  GetListOldReceiverStateFailure copyWith({String? message}) {
    return GetListOldReceiverStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class GetAllUnitShipmentState extends Equatable {
  const GetAllUnitShipmentState();
  @override
  List<Object?> get props => [];
}

class GetAllUnitShipmentStateInitial extends GetAllUnitShipmentState {}

class GetAllUnitShipmentStateLoading extends GetAllUnitShipmentState {}

class GetAllUnitShipmentStateSuccess extends GetAllUnitShipmentState {
  final AllUnitShipmentModel data;
  const GetAllUnitShipmentStateSuccess({
    required this.data,
  });
  GetAllUnitShipmentStateSuccess copyWith({
    AllUnitShipmentModel? data,
  }) {
    return GetAllUnitShipmentStateSuccess(
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [data];
}

class GetAllUnitShipmentStateFailure extends GetAllUnitShipmentState {
  final String message;

  const GetAllUnitShipmentStateFailure({required this.message});

  GetAllUnitShipmentStateFailure copyWith({String? message}) {
    return GetAllUnitShipmentStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class HandleGetInforOldRecieveState extends Equatable {
  const HandleGetInforOldRecieveState();
  @override
  List<Object?> get props => [];
}

class HandleGetInforOldRecieveStateInitial
    extends HandleGetInforOldRecieveState {}

class HandleGetInforOldRecieveStateLoading
    extends HandleGetInforOldRecieveState {}

class HandleGetInforOldRecieveStateSuccess
    extends HandleGetInforOldRecieveState {
  final InfoOldReceiverModel data;
  const HandleGetInforOldRecieveStateSuccess({
    required this.data,
  });
  HandleGetInforOldRecieveStateSuccess copyWith({
    InfoOldReceiverModel? data,
  }) {
    return HandleGetInforOldRecieveStateSuccess(
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [data];
}

class HandleGetInforOldRecieveStateFailure
    extends HandleGetInforOldRecieveState {
  final String message;

  const HandleGetInforOldRecieveStateFailure({required this.message});

  HandleGetInforOldRecieveStateFailure copyWith({String? message}) {
    return HandleGetInforOldRecieveStateFailure(
        message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class GetInforUserState extends Equatable {
  const GetInforUserState();
  @override
  List<Object?> get props => [];
}

class GetInforUserStateInitial extends GetInforUserState {}

class GetInforUserStateLoading extends GetInforUserState {}

class GetInforUserStateSuccess extends GetInforUserState {
  final InforAccountModel data;
  const GetInforUserStateSuccess({
    required this.data,
  });
  GetInforUserStateSuccess copyWith({
    InforAccountModel? data,
  }) {
    return GetInforUserStateSuccess(
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [data];
}

class GetInforUserStateFailure extends GetInforUserState {
  final String message;

  const GetInforUserStateFailure({required this.message});

  GetInforUserStateFailure copyWith({String? message}) {
    return GetInforUserStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
