part of 'update_account_key_bloc.dart';

abstract class UpdateAccountKeyEvent extends Equatable {
  const UpdateAccountKeyEvent();

  @override
  List<Object?> get props => [];
}

class HandleUpdateAccountKey extends UpdateAccountKeyEvent {
  final int? userID;
  final String currentPassword;
  final String user_account_key;
  const HandleUpdateAccountKey({
    this.userID,
    required this.currentPassword,
    required this.user_account_key,
  });
  @override
  List<Object?> get props => [currentPassword, user_account_key];
}
