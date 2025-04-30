abstract class ConfirmOTPLoginState {}

class ConfirmOTPLoginInitial extends ConfirmOTPLoginState {}

class ConfirmOTPLoginLoading extends ConfirmOTPLoginState {}

class ConfirmOTPLoginSuccess extends ConfirmOTPLoginState {
  final String? messRes;
  ConfirmOTPLoginSuccess({this.messRes});
}

class ConfirmOTPLoginFailure extends ConfirmOTPLoginState {
  final String? errorText;
  ConfirmOTPLoginFailure({this.errorText});
}
