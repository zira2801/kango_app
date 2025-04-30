part of 'get_fwd_list_bloc.dart';

abstract class FWDScreenEvent extends Equatable {
  const FWDScreenEvent();

  @override
  List<Object?> get props => [];
}

class FetchListFWD extends FWDScreenEvent {
  final String? keywords;

  const FetchListFWD({
    required this.keywords,
  });
  @override
  List<Object?> get props => [keywords];
}

class LoadMoreListFWD extends FWDScreenEvent {
  final String? keywords;

  const LoadMoreListFWD({
    required this.keywords,
  });
  @override
  List<Object?> get props => [keywords];
}
