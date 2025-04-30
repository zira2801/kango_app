part of 'wallet_bloc.dart';

abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletStateInitial extends WalletState {}

class WalletStateLoading extends WalletState {}

class WalletStateSuccess extends WalletState {
  final WalletResponse? walletModel;
  WalletStateSuccess({required this.walletModel});
}

class WalletStateFailure extends WalletState {
  final String? errorText;
  WalletStateFailure({this.errorText});
}
