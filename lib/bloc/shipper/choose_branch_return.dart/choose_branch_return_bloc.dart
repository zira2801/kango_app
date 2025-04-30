import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
part 'choose_branch_return_state.dart';
part 'choose_branch_return_event.dart';

class ChooseBranchReturnBloc
    extends Bloc<ChooseBranchReturnEvent, ChooseBranchReturnState> {
  ChooseBranchReturnBloc() : super(ChooseBranchReturnStateInitial()) {
    on<DialogSelectionEvent>(_onDialogSelectionEvent);
  }

  Future<void> _onDialogSelectionEvent(
    DialogSelectionEvent event,
    Emitter<ChooseBranchReturnState> emit,
  ) async {
    emit(ChooseBranchReturnStateInitial());
    emit(ChooseBranchReturnStateMade(event.selectedBranch));
  }
}
