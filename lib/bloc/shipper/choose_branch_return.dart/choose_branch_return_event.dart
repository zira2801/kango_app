part of 'choose_branch_return_bloc.dart';

abstract class ChooseBranchReturnEvent extends Equatable {
  const ChooseBranchReturnEvent();

  @override
  List<Object?> get props => [];
}

// class ShowDialogEvent extends ChooseBranchReturnEvent {}
class DialogSelectionEvent extends ChooseBranchReturnEvent {
  final LatLng selectedBranch;
  DialogSelectionEvent(this.selectedBranch);
  @override
  List<Object?> get props => [
        selectedBranch,
      ];
}
