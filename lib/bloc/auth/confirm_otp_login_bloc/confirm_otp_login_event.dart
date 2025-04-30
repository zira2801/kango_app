abstract class ConfirmOTPLoginEvent {}

class ConfirmOTPLoginButtonPressed extends ConfirmOTPLoginEvent {
  final String otp;

  ConfirmOTPLoginButtonPressed({
    required this.otp,
  });
}
