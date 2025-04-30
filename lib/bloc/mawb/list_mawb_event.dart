import 'package:equatable/equatable.dart';

abstract class MAWBListEvent extends Equatable {
  const MAWBListEvent();

  @override
  List<Object?> get props => [];
}

class FetchMAWBList extends MAWBListEvent {
  final String? keywords;
  final String? trackingStatus;

  const FetchMAWBList({
    this.keywords,
    this.trackingStatus,
  });

  @override
  List<Object?> get props => [keywords, trackingStatus];
}

class LoadMoreMAWBList extends MAWBListEvent {
  final int page;
  final String? keywords;
  final String? trackingStatus;

  const LoadMoreMAWBList({
    required this.page,
    this.keywords,
    this.trackingStatus,
  });

  @override
  List<Object?> get props => [page, keywords, trackingStatus];
}
