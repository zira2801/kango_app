part of 'get_sale_list_bloc.dart';

abstract class SaleScreenEvent extends Equatable {
  const SaleScreenEvent();

  @override
  List<Object?> get props => [];
}

class FetchListSale extends SaleScreenEvent {
  final String? keywords;

  const FetchListSale({
    required this.keywords,
  });
  @override
  List<Object?> get props => [keywords];
}

class LoadMoreListSale extends SaleScreenEvent {
  final String? keywords;

  const LoadMoreListSale({
    required this.keywords,
  });
  @override
  List<Object?> get props => [keywords];
}
