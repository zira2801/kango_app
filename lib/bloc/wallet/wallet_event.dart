part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class GetWallet extends WalletEvent {
  const GetWallet();
  @override
  List<Object?> get props => [];
}
