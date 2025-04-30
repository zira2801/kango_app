part of 'get_infor_bloc.dart';

abstract class GetInforProfileEvent extends Equatable {
  const GetInforProfileEvent();

  @override
  List<Object?> get props => [];
}

class HandleGetInforProfile extends GetInforProfileEvent {
  final int? userID;
  const HandleGetInforProfile({
    required this.userID,
  });
  @override
  List<Object?> get props => [userID];
}

abstract class GetAreaVNEvent extends Equatable {
  const GetAreaVNEvent();

  @override
  List<Object?> get props => [];
}

class HandleGetAreaVN extends GetAreaVNEvent {
  final int? cityID;
  final int? districtID;
  const HandleGetAreaVN({
    required this.cityID,
    required this.districtID,
  });
  @override
  List<Object?> get props => [cityID, districtID];
}

abstract class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();

  @override
  List<Object?> get props => [];
}

class HandleUpdateProfile extends UpdateProfileEvent {
  final int? userID;
  final String? userContactName;
  final String? userPhone;
  final String? userLatitude;
  final String? userLongitude;
  final String? userAddress;
  final String? userCompanyName;
  final String? userAccountKey;
  final String? userTaxCode;
  final int? userAddress1;
  final int? userAddress2;
  final int? userAddress3;
  final String? userLogo;
  final String? userSignature;
  const HandleUpdateProfile({
    required this.userID,
    required this.userContactName,
    required this.userPhone,
    required this.userLatitude,
    required this.userLongitude,
    required this.userAddress,
    required this.userCompanyName,
    this.userAccountKey,
    required this.userTaxCode,
    required this.userAddress1,
    required this.userAddress2,
    required this.userAddress3,
    required this.userLogo,
    required this.userSignature,
  });
  @override
  List<Object?> get props => [
        userID,
        userContactName,
        userPhone,
        userLatitude,
        userLongitude,
        userAddress,
        userCompanyName,
        userAccountKey,
        userTaxCode,
        userAddress1,
        userAddress2,
        userAddress3,
        userLogo,
        userSignature,
      ];
}
