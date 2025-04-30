part of 'sign_in_bloc.dart';

abstract class SignInState extends Equatable {
  const SignInState();
  @override
  List<Object?> get props => [];
}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {
  final BranchResponse branchResponse;
  const SignInSuccess({required this.branchResponse});

  SignInSuccess copyWith({BranchResponse? branchResponse}) {
    return SignInSuccess(branchResponse: branchResponse ?? this.branchResponse);
  }

  @override
  List<Object?> get props => [branchResponse];
}

class SignInFailure extends SignInState {
  final String? errorText;
  SignInFailure({this.errorText});
}

class SignIn2Authen extends SignInState {}
