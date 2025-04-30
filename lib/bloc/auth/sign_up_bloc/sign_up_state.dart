abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final String? responseText;
  SignUpSuccess({this.responseText});
}

class SignUpFailure extends SignUpState {
  final String? errorText;
  SignUpFailure({this.errorText});
}
