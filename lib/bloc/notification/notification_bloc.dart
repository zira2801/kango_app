import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/models/notification/detail_notification.dart';
import 'package:scan_barcode_app/data/models/notification/notificaion.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationStateInitial()) {
    on<FetchListNotification>(_onFetchListNotification);
    on<LoadMoreListNotification>(_onLoadMoreListNotification);
  }

  Future<void> _onFetchListNotification(
    FetchListNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationStateloading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$getListNotification'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body:
            jsonEncode({'is_api': true, 'limit': 10, 'page': 1, 'fillter': {}}),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final response = NotificationResponse.fromJson(data);
        final notificationData = response.notifications.data;
        log(notificationData.toString());
        final pageCurrent = response.notifications.currentPage;
        emit(NotificationStateSuccess(
            data: notificationData,
            page: pageCurrent,
            hasReachedMax: notificationData.length < 10));
      } else {
        log("ERROR _onFetchListNotification 1");
        emit(NotificationStateFailure(message: data['message']));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR _onFetchListNotification 2 $error");
        emit(const NotificationStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR _onFetchListNotification 3");
        emit(NotificationStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreListNotification(
    LoadMoreListNotification event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationStateSuccess &&
        !(state as NotificationStateSuccess).hasReachedMax) {
      final currentState = state as NotificationStateSuccess;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getListNotification'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'limit': 10,
            'page': currentState.page + 1,
            'fillter': {}
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          if (data['status'] == 200) {
            final response = NotificationResponse.fromJson(
                data); // Use same parser as in fetch
            final notificationData = response.notifications.data;
            emit(notificationData.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : NotificationStateSuccess(
                    data: currentState.data + notificationData,
                    page: currentState.page + 1,
                    hasReachedMax: notificationData.length < 10,
                  ));
          }
        } else {
          log("ERROR _onLoadMoreListNotification 1");
          emit(NotificationStateFailure(message: data['message']));
        }
      } catch (error) {
        if (error is http.ClientException) {
          log("ERROR _onLoadMoreListNotification 2 $error");
          emit(const NotificationStateFailure(
              message: "Không thể kết nối đến máy chủ"));
        } else {
          log("ERROR _onLoadMoreListNotification 3");
          emit(NotificationStateFailure(message: error.toString()));
        }
      }
    }
  }
}

class DetailsNotificationBloc
    extends Bloc<NotificationEvent, GetDetailsNotificationState> {
  DetailsNotificationBloc()
      : super(HandleGetDetailsNotificationStateInitial()) {
    on<HandleDetailNotification>(_onHandleGetDetailsNotification);
  }

  Future<void> _onHandleGetDetailsNotification(
    HandleDetailNotification event,
    Emitter<GetDetailsNotificationState> emit,
  ) async {
    emit(HandleGetDetailsNotificationLoading());

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$detailNotification${event.notificaionID}'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
      );

      final data = jsonDecode(response.body);
      log("Response data: $data");

      if (data['status'] == 200) {
        try {
          log("SUCCESS: Get Success Data Notification");
          final detailsDataNotificationData =
              DetailNotification.fromJson(data).data;
          emit(HandleGetDetailsNotificationSuccess(
              data: detailsDataNotificationData));
        } catch (parseError) {
          log("ERROR: Data parsing failed: $parseError");
          emit(HandleGetDetailsNotificationFailure(
              message: "Lỗi xử lý dữ liệu: $parseError"));
        }
      } else {
        log("ERROR: API returned status ${data['status']}");
        emit(HandleGetDetailsNotificationFailure(
            message: data['message'] ?? "Lỗi không xác định"));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR: Network error: $error");
        emit(const HandleGetDetailsNotificationFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR: Unexpected error: $error");
        emit(HandleGetDetailsNotificationFailure(message: error.toString()));
      }
    }
  }
}

class CreateNotificationBloc
    extends Bloc<NotificationEvent, CreateNotificationtState> {
  CreateNotificationBloc() : super(CreateNotificationStateInitial()) {
    on<HandleCreateNotification>(_onHandleCreateNotification);
  }

  Future<void> _onHandleCreateNotification(
    HandleCreateNotification event,
    Emitter<CreateNotificationtState> emit,
  ) async {
    emit(CreateNotificationStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$createNotification'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'notification_title': event.notificationTitle,
          'notification_important': event.notificationImportant,
          'notification_content': event.notificationContent
        }),
      );

      final data = jsonDecode(response.body);
      log("Response data: $data");
      final mess = data['message'];
      if (data['status'] == 200) {
        log("SUCCESS: Get Success Create Notification");
        emit(CreateNotificationStateSuccess(message: mess['text']));
      } else {
        log("ERROR: API returned status ${data['status']} Create Notification");
        emit(CreateNotificationStateFailure(
            message: mess['text'] ?? "Lỗi không xác định"));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR: Network error: $error");
        emit(const CreateNotificationStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR: Unexpected error: $error");
        emit(CreateNotificationStateFailure(message: error.toString()));
      }
    }
  }
}

class UpdateNotificationBloc
    extends Bloc<NotificationEvent, UpdateNotificationtState> {
  UpdateNotificationBloc() : super(UpdateNotificationtStateInitial()) {
    on<HandleUpdateNotification>(_onHandleUpdateNotification);
  }

  Future<void> _onHandleUpdateNotification(
    HandleUpdateNotification event,
    Emitter<UpdateNotificationtState> emit,
  ) async {
    emit(UpdateNotificationtStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$updateNotification'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'notification_id': event.notificationID,
          'notification_title': event.notificationTitle,
          'notification_important': event.notificationImportant,
          'notification_content': event.notificationContent
        }),
      );

      final data = jsonDecode(response.body);
      log("Response data: $data");
      final mess = data['message'];
      if (data['status'] == 200) {
        log("SUCCESS: Get Success Update Notification");
        emit(UpdateNotificationtStateSuccess(message: mess['text']));
      } else {
        log("ERROR: API returned status ${data['status']} Update Notification");
        emit(UpdateNotificationStateFailure(
            message: mess['text'] ?? "Lỗi không xác định"));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR: Network error: $error");
        emit(const UpdateNotificationStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR: Unexpected error: $error");
        emit(UpdateNotificationStateFailure(message: error.toString()));
      }
    }
  }
}

class DeleteNotificationBloc
    extends Bloc<NotificationEvent, DeleteNotificationtState> {
  DeleteNotificationBloc() : super(DeleteNotificationtStateInitial()) {
    on<HandleDeleteNotification>(_onHandleDeleteNotification);
  }

  Future<void> _onHandleDeleteNotification(
    HandleDeleteNotification event,
    Emitter<DeleteNotificationtState> emit,
  ) async {
    emit(DeleteNotificationtStateLoading());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$deleteNotification'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
          'notification_id': event.notificationId,
        }),
      );

      final data = jsonDecode(response.body);
      log("Response data: $data");
      final mess = data['message'];
      if (data['status'] == 200) {
        log("SUCCESS: Get Success Delete Notification");
        emit(DeleteNotificationtStateSuccess(message: mess['text']));
      } else {
        log("ERROR: API returned status ${data['status']} Delete Notification");
        emit(DeleteNotificationtStateFailure(
            message: mess['text'] ?? "Lỗi không xác định"));
      }
    } catch (error) {
      if (error is http.ClientException) {
        log("ERROR: Network error: $error");
        emit(const DeleteNotificationtStateFailure(
            message: "Không thể kết nối đến máy chủ"));
      } else {
        log("ERROR: Unexpected error: $error");
        emit(DeleteNotificationtStateFailure(message: error.toString()));
      }
    }
  }
}
