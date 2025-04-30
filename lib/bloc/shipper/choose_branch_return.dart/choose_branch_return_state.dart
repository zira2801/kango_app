part of 'choose_branch_return_bloc.dart';

abstract class ChooseBranchReturnState extends Equatable {
  const ChooseBranchReturnState();
  @override
  List<Object?> get props => [];
}

class ChooseBranchReturnStateInitial extends ChooseBranchReturnState {}

// class ChooseBranchReturnStateShowing extends ChooseBranchReturnState {}
class ChooseBranchReturnStateMade extends ChooseBranchReturnState {
  final LatLng selectedBranch;
  ChooseBranchReturnStateMade(this.selectedBranch);
}
