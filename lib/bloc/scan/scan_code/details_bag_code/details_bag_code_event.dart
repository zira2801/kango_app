part of 'details_bag_code_bloc.dart';

abstract class DetailsBagCodeEvent extends Equatable {
  const DetailsBagCodeEvent();

  @override
  List<Object?> get props => [];
}

class HanldeDetailsBagCode extends DetailsBagCodeEvent {
  final String? bagCode;
  final String code;
  final int? smTracktryID;
  final int status;
  const HanldeDetailsBagCode({
    this.bagCode,
    required this.code,
    this.smTracktryID,
    required this.status,
  });
  @override
  List<Object?> get props => [bagCode, code, smTracktryID];
}
