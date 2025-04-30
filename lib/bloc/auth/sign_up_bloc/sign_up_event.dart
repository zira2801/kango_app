abstract class SignUpEvent {}

class SignUpButtonPressed extends SignUpEvent {
  final String email;
  final String password;
  final String confirmPassword;
  final String? companyName;
  final String? contactName;
  final String? taxCode;
  final String phone;
  final int? address1;
  final int? address2;
  final int? address3;
  final String address4;
  final String? latitude;
  final String? longitude;
  final String? accountantKey;
  final String? userLogo;
  final int? positionID;
  final int? branchID;
  final bool isCustomer;
  SignUpButtonPressed({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.companyName,
    required this.contactName,
    required this.taxCode,
    required this.phone,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.address4,
    required this.latitude,
    required this.longitude,
    required this.accountantKey,
    required this.userLogo,
    required this.positionID,
    required this.branchID,
    required this.isCustomer,
  });
}
