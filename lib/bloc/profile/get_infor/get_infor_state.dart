part of 'get_infor_bloc.dart';

abstract class GetInforProfileState extends Equatable {
  const GetInforProfileState();
  @override
  List<Object?> get props => [];
}

class GetInforProfileStateLoading extends GetInforProfileState {}

class GetInforProfileStateSuccess extends GetInforProfileState {
  final InforAccountModel inforAccountModel;

  const GetInforProfileStateSuccess({required this.inforAccountModel});

  GetInforProfileStateSuccess copyWith({InforAccountModel? inforAccountModel}) {
    return GetInforProfileStateSuccess(
        inforAccountModel: inforAccountModel ?? this.inforAccountModel);
  }

  @override
  List<Object?> get props => [inforAccountModel];
}

class GetInforProfileStateFailure extends GetInforProfileState {
  final String message;

  const GetInforProfileStateFailure({required this.message});

  GetInforProfileStateFailure copyWith({String? message}) {
    return GetInforProfileStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class GetAreaVNState extends Equatable {
  const GetAreaVNState();
  @override
  List<Object?> get props => [];
}

class GetAreaVNStateStateLoading extends GetAreaVNState {}

class GetAreaVNStateStateSuccess extends GetAreaVNState {
  final AreaVnModel areaVnModel;

  const GetAreaVNStateStateSuccess({required this.areaVnModel});

  GetAreaVNStateStateSuccess copyWith({AreaVnModel? areaVnModel}) {
    return GetAreaVNStateStateSuccess(
        areaVnModel: areaVnModel ?? this.areaVnModel);
  }

  @override
  List<Object?> get props => [areaVnModel];
}

class GetAreaVNStateFailure extends GetAreaVNState {
  final String message;

  const GetAreaVNStateFailure({required this.message});

  GetAreaVNStateFailure copyWith({String? message}) {
    return GetAreaVNStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

abstract class UpdateProfileState extends Equatable {
  const UpdateProfileState();
  @override
  List<Object?> get props => [];
}

class UpdateProfileStateLoading extends UpdateProfileState {}

class UpdateProfileStateSuccess extends UpdateProfileState {
  final String message;

  const UpdateProfileStateSuccess({required this.message});

  UpdateProfileStateSuccess copyWith({String? message}) {
    return UpdateProfileStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class UpdateProfileStateFailure extends UpdateProfileState {
  final String message;

  const UpdateProfileStateFailure({required this.message});

  UpdateProfileStateFailure copyWith({String? message}) {
    return UpdateProfileStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
