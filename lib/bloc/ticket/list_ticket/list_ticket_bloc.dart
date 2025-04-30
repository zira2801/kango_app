import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/ticket/list_historey_ticket.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'list_ticket_event.dart';
part 'list_ticket_state.dart';

class ListTicketBloc extends Bloc<ListTicketEvent, ListTicketState> {
  ListTicketBloc() : super(ListTicketStateInitial()) {
    on<FetchListTicketStatusPending>(_onFetchListTicketStatusPending);
    on<LoadMoreListTicketStatusPending>(_onLoadMoreListTicketStatusPending);
    on<FetchListTicketStatusProcessing>(_onFetchListTicketStatusProcessing);
    on<LoadMoreListTicketStatusProcessing>(
        _onLoadMoreListTicketStatusProcessing);
    on<FetchListTicketStatusDone>(_onFetchListTicketStatusDone);
    on<LoadMoreListTicketStatusDone>(_onLoadMoreListTicketStatusDone);
  }

  Future<void> _onFetchListTicketStatusPending(
    FetchListTicketStatusPending event,
    Emitter<ListTicketState> emit,
  ) async {
    emit(ListTicketStatusPendingStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getlistTicketApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'limit': 20,
          'page': 1,
        }),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        log("_onFetchListTicketStatusPending OKOK");
        final listTicketData =
            ListHistoryTicketModel.fromJson(data).data.pending.data;
        emit(ListTicketStatusPendingStateSuccess(
            data: listTicketData,
            page: 1,
            hasReachedMax: listTicketData.length < 20));
      } else {
        log("ERROR _onFetchListTicketStatusPending 1");
        emit(const ListTicketStatusPendingStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onFetchListTicketStatusPending 2 $error");
      if (error is http.ClientException) {
        emit(const ListTicketStatusPendingStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(ListTicketStatusPendingStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListTicketStatusPending(
    LoadMoreListTicketStatusPending event,
    Emitter<ListTicketState> emit,
  ) async {
    if (state is ListTicketStatusPendingStateSuccess &&
        !(state as ListTicketStatusPendingStateSuccess).hasReachedMax) {
      final currentState = state as ListTicketStatusPendingStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getlistTicketApi'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'limit': 20,
            'page': currentState.page + 1,
          }),
        );
        final data = jsonDecode(response.body);

        if (data['status'] == 200) {
          log("_onLoadMoreListTicketStatusPending OKOK");
          final listTicketData =
              ListHistoryTicketModel.fromJson(data).data.pending.data;
          emit(data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : ListTicketStatusPendingStateSuccess(
                  data: currentState.data + listTicketData,
                  page: currentState.page + 1,
                  hasReachedMax: listTicketData.length < 20,
                ));
        } else {
          log("ERROR _onLoadMoreListTicketStatusPending 1");
          emit(const ListTicketStatusPendingStateFailure(
              message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
        }
      } catch (error) {
        log("ERROR _onLoadMoreListTicketStatusPending 2 $error");
        if (error is http.ClientException) {
          emit(const ListTicketStatusPendingStateFailure(
              message: "Không thể kết nối với máy chủ"));
        } else {
          emit(ListTicketStatusPendingStateFailure(message: error.toString()));
        }
      }
    }
  }

  Future<void> _onFetchListTicketStatusProcessing(
    FetchListTicketStatusProcessing event,
    Emitter<ListTicketState> emit,
  ) async {
    emit(ListTicketStatusProcessingStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getlistTicketApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'limit': 20,
          'page': 1,
        }),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        log("_onFetchListTicketStatusProcessing OKOK");
        final listTicketData =
            ListHistoryTicketModel.fromJson(data).data.processing.data;
        emit(ListTicketStatusProcessingStateSuccess(
            data: listTicketData,
            page: 1,
            hasReachedMax: listTicketData.length < 20));
      } else {
        log("ERROR _onFetchListTicketStatusProcessing 1");
        emit(const ListTicketStatusProcessingStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onFetchListTicketStatusProcessing 2 $error");
      if (error is http.ClientException) {
        emit(const ListTicketStatusProcessingStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(ListTicketStatusProcessingStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListTicketStatusProcessing(
    LoadMoreListTicketStatusProcessing event,
    Emitter<ListTicketState> emit,
  ) async {
    if (state is ListTicketStatusProcessingStateSuccess &&
        !(state as ListTicketStatusProcessingStateSuccess).hasReachedMax) {
      final currentState = state as ListTicketStatusProcessingStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getlistTicketApi'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'limit': 20,
            'page': currentState.page + 1,
          }),
        );
        final data = jsonDecode(response.body);

        if (data['status'] == 200) {
          log("_onLoadMoreListTicketStatusProcessing OKOK");
          final listTicketData =
              ListHistoryTicketModel.fromJson(data).data.processing.data;
          emit(data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : ListTicketStatusProcessingStateSuccess(
                  data: currentState.data + listTicketData,
                  page: currentState.page + 1,
                  hasReachedMax: listTicketData.length < 20,
                ));
        } else {
          log("ERROR _onLoadMoreListTicketStatusProcessing 1");
          emit(const ListTicketStatusProcessingStateFailure(
              message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
        }
      } catch (error) {
        log("ERROR _onLoadMoreListTicketStatusProcessing 2 $error");
        if (error is http.ClientException) {
          emit(const ListTicketStatusProcessingStateFailure(
              message: "Không thể kết nối với máy chủ"));
        } else {
          emit(ListTicketStatusProcessingStateFailure(
              message: error.toString()));
        }
      }
    }
  }

  Future<void> _onFetchListTicketStatusDone(
    FetchListTicketStatusDone event,
    Emitter<ListTicketState> emit,
  ) async {
    emit(ListTicketStatusDoneStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getlistTicketApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'limit': 20,
          'page': 1,
        }),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        log("_onFetchListTicketStatusDone OKOK");
        final listTicketData =
            ListHistoryTicketModel.fromJson(data).data.done.data;
        emit(ListTicketStatusDoneStateSuccess(
            data: listTicketData,
            page: 1,
            hasReachedMax: listTicketData.length < 20));
      } else {
        log("ERROR _onFetchListTicketStatusDone 1");
        emit(const ListTicketStatusDoneStateFailure(
            message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
      }
    } catch (error) {
      log("ERROR _onFetchListTicketStatusDone 2 $error");
      if (error is http.ClientException) {
        emit(const ListTicketStatusDoneStateFailure(
            message: "Không thể kết nối với máy chủ"));
      } else {
        emit(ListTicketStatusDoneStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListTicketStatusDone(
    LoadMoreListTicketStatusDone event,
    Emitter<ListTicketState> emit,
  ) async {
    if (state is ListTicketStatusDoneStateSuccess &&
        !(state as ListTicketStatusDoneStateSuccess).hasReachedMax) {
      final currentState = state as ListTicketStatusDoneStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getlistTicketApi'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'limit': 20,
            'page': currentState.page + 1,
          }),
        );
        final data = jsonDecode(response.body);

        if (data['status'] == 200) {
          log("_onLoadMoreListTicketStatusDone OKOK");
          final listTicketData =
              ListHistoryTicketModel.fromJson(data).data.done.data;
          emit(data.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : ListTicketStatusDoneStateSuccess(
                  data: currentState.data + listTicketData,
                  page: currentState.page + 1,
                  hasReachedMax: listTicketData.length < 20,
                ));
        } else {
          log("ERROR _onLoadMoreListTicketStatusDone 1");
          emit(const ListTicketStatusDoneStateFailure(
              message: "Đã xảy ra lỗi trong quá trình dữ lý dữ liệu."));
        }
      } catch (error) {
        log("ERROR _onLoadMoreListTicketStatusDone 2 $error");
        if (error is http.ClientException) {
          emit(const ListTicketStatusDoneStateFailure(
              message: "Không thể kết nối với máy chủ"));
        } else {
          emit(ListTicketStatusDoneStateFailure(message: error.toString()));
        }
      }
    }
  }
}
