import 'package:equatable/equatable.dart';

abstract class MAWBListState extends Equatable {
  const MAWBListState();

  @override
  List<Object?> get props => [];
}

class MAWBListInitial extends MAWBListState {}

class MAWBListLoading extends MAWBListState {}

class MAWBListSuccess extends MAWBListState {
  final List<dynamic> data;
  final int page;
  final bool hasReachedMax;

  const MAWBListSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [data, page, hasReachedMax];
}

class MAWBListFailure extends MAWBListState {
  final String message;

  const MAWBListFailure({required this.message});

  @override
  List<Object> get props => [message];
}
