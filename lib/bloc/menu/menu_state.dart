part of 'menu_bloc.dart';

abstract class MenuState extends Equatable {
  const MenuState();
  @override
  List<Object?> get props => [];
}

class MenuStateInitial extends MenuState {}

class MenuStateLoading extends MenuState {}

class MenuStateSuccess extends MenuState {
  final MenuResponse? menuResponse;
  const MenuStateSuccess({this.menuResponse});
}

class MenuStateFailure extends MenuState {
  final String? errorText;
  const MenuStateFailure({this.errorText});
}
