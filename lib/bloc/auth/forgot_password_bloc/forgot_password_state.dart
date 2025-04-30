abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String? messRes;
  ForgotPasswordSuccess({this.messRes});
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String? errorText;
  ForgotPasswordFailure({this.errorText});
}
