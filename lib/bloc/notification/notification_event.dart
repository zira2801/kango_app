part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchListNotification extends NotificationEvent {
  // final int? status;
  // final String? startDate;
  // final String? endDate;
  // final String? keyType;
  // final String? keywords;

  const FetchListNotification(
      // required this.status,
      // required this.startDate,
      // required this.endDate,
      // required this.keyType,
      // required this.keywords,
      );
  @override
  List<Object?> get props => [];
}

class LoadMoreListNotification extends NotificationEvent {
  // final int? status;
  // final String? startDate;
  // final String? endDate;
  // final String? keyType;
  // final String? keywords;

  const LoadMoreListNotification();
  @override
  List<Object?> get props => [];
}

class HandleDetailNotification extends NotificationEvent {
  final int? notificaionID;
  const HandleDetailNotification({required this.notificaionID});
  @override
  List<Object?> get props => [];
}

class HandleCreateNotification extends NotificationEvent {
  final String notificationTitle;
  final bool notificationImportant;
  final String notificationContent;

  const HandleCreateNotification({
    required this.notificationTitle,
    required this.notificationImportant,
    required this.notificationContent,
  });

  @override
  List<Object?> get props => [
        notificationTitle,
        notificationImportant,
        notificationContent,
      ];
}

class HandleUpdateNotification extends NotificationEvent {
  final int notificationID;
  final String notificationTitle;
  final bool notificationImportant;
  final String notificationContent;

  const HandleUpdateNotification({
    required this.notificationID,
    required this.notificationTitle,
    required this.notificationImportant,
    required this.notificationContent,
  });

  @override
  List<Object?> get props => [
        notificationID,
        notificationTitle,
        notificationImportant,
        notificationContent,
      ];
}

class HandleDeleteNotification extends NotificationEvent {
  final int notificationId;
  const HandleDeleteNotification({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}
