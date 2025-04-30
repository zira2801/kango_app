part of 'get_infor_sepay_bloc.dart';

abstract class GetInforSePayEvent extends Equatable {
  const GetInforSePayEvent();

  @override
  List<Object?> get props => [];
}

class HanldeGetInforSePayEvent extends GetInforSePayEvent {
  final int rechargeID;

  const HanldeGetInforSePayEvent({required this.rechargeID});

  @override
  List<Object> get props => [rechargeID];
}
