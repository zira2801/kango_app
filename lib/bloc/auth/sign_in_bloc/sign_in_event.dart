part of 'sign_in_bloc.dart';

abstract class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object?> get props => [];
}

class SignInButtonPressed extends SignInEvent {
  final String email;
  final String password;

  SignInButtonPressed({
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [email, password];
}
