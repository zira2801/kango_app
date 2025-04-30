part of 'create_sepay_bloc.dart';

abstract class CreateSePayEvent extends Equatable {
  const CreateSePayEvent();

  @override
  List<Object?> get props => [];
}

class HanldeCreateSePayEvent extends CreateSePayEvent {
  final double amount;
  final String type;
  final String note;

  const HanldeCreateSePayEvent(
      {required this.amount, required this.type, required this.note});

  @override
  List<Object> get props => [amount, type, note];
}
