import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/notification/notification_bloc.dart';
import 'package:scan_barcode_app/data/models/notification/notificaion.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/notification/notification_create.dart';
import 'package:scan_barcode_app/ui/screen/notification/notification_detail.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationItem> notifications;
  final scrollListNotificationController = ScrollController();
  String query = '';
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();

    BlocProvider.of<NotificationBloc>(context)
        .add(const FetchListNotification());

    scrollListNotificationController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollListNotificationController.position.maxScrollExtent ==
        scrollListNotificationController.offset) {
      BlocProvider.of<NotificationBloc>(context)
          .add(const LoadMoreListNotification());
    }
  }

// Sử dụng trong widget
  String getTimeAgo(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return timeago.format(dateTime, locale: 'vi');
  }

  @override
  void dispose() {
    scrollListNotificationController.dispose();
    super.dispose();
  }

  Future<bool?> showDeleteConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = "Xác nhận",
    String cancelText = "Hủy",
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 66,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                margin: const EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextApp(
                      text: title,
                      fontsize: 20.w,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 16),
                    TextApp(
                      text: message,
                      fontsize: 16.w,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Nút Hủy
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade200,
                            ),
                            child: TextApp(
                              text: cancelText,
                              color: Colors.black87,
                              fontsize: 16.w,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Nút Xác nhận
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.red,
                            ),
                            child: TextApp(
                              text: confirmText,
                              color: Colors.white,
                              fontsize: 16.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 30,
                    child: Icon(
                      Icons.delete_outline,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? position =
        StorageUtils.instance.getString(key: 'user_position');
    final int? positionID = StorageUtils.instance.getInt(key: 'positionID');
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.background,
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          surfaceTintColor: Theme.of(context).colorScheme.background,
          shadowColor: Theme.of(context).colorScheme.background,
          title: TextApp(
            text: "Thông báo",
            fontsize: 20.sp,
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
          actions: [
            position == 'admin'
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 180.w,
                      height: 40.w,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.primary)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationCreate(
                                          notificationId: null,
                                        )));
                          },
                          child: TextApp(
                            text: 'Thêm Thông Báo',
                            color: Colors.white,
                            fontsize: 15.w,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  )
                : Container()
          ],
        ),
        backgroundColor: Colors.white,
        body: MultiBlocListener(
          listeners: [
            BlocListener<DeleteNotificationBloc, DeleteNotificationtState>(
              listener: (context, state) async {
                if (state is DeleteNotificationtStateSuccess) {
                  // Refresh data
                  BlocProvider.of<NotificationBloc>(context)
                      .add(const FetchListNotification());

                  // Show success message
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                } else if (state is DeleteNotificationtStateFailure) {
                  // Show error message
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message ?? "Đã có lỗi xảy ra",
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationStateloading) {
                return Center(
                  child: SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: Lottie.asset('assets/lottie/loading_kango.json'),
                  ),
                );
              } else if (state is NotificationStateSuccess) {
                return SlidableAutoCloseBehavior(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Slidable.of(context)?.close();
                    },
                    child: RefreshIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      onRefresh: () async {
                        BlocProvider.of<NotificationBloc>(context)
                            .add(const FetchListNotification());
                      },
                      child: SingleChildScrollView(
                        controller: scrollListNotificationController,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                state.data.isEmpty
                                    ? const NoDataFoundWidget()
                                    : SizedBox(
                                        width: 1.sw,
                                        child: Column(
                                          children: [
                                            // Phần ListView hiển thị danh sách thông báo
                                            ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: state.hasReachedMax
                                                  ? state.data.length
                                                  : state.data.length + 1,
                                              itemBuilder: (context, index) {
                                                if (index >=
                                                    state.data.length) {
                                                  return Center(
                                                    child: SizedBox(
                                                      width: 50.w,
                                                      height: 50.w,
                                                      child: Lottie.asset(
                                                          'assets/lottie/loading_kango.json'),
                                                    ),
                                                  );
                                                } else {
                                                  final notification =
                                                      state.data[index];
                                                  return position == 'admin'
                                                      ? Column(
                                                          children: [
                                                            Slidable(
                                                              key: ValueKey(
                                                                  notification),
                                                              endActionPane:
                                                                  ActionPane(
                                                                extentRatio:
                                                                    0.4,
                                                                motion:
                                                                    const BehindMotion(),
                                                                children: [
                                                                  CustomSlidableAction(
                                                                    onPressed:
                                                                        (context) {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              NotificationCreate(
                                                                            notificationId:
                                                                                notification.notificationId,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    backgroundColor:
                                                                        Colors
                                                                            .blue
                                                                            .shade600,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              8.r),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              8.r),
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                          FontAwesomeIcons
                                                                              .penToSquare,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              18.sp,
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                4.h),
                                                                        TextApp(
                                                                          text:
                                                                              'Sửa',
                                                                          fontsize:
                                                                              12.sp,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  CustomSlidableAction(
                                                                    onPressed:
                                                                        (context) {
                                                                      final deleteBloc = BlocProvider.of<
                                                                              DeleteNotificationBloc>(
                                                                          context,
                                                                          listen:
                                                                              false);
                                                                      showDeleteConfirmationDialog(
                                                                        context:
                                                                            context,
                                                                        title:
                                                                            "Xóa thông báo",
                                                                        message:
                                                                            "Bạn có chắc muốn xóa thông báo này?",
                                                                      ).then(
                                                                          (confirmed) {
                                                                        if (confirmed ==
                                                                            true) {
                                                                          deleteBloc
                                                                              .add(HandleDeleteNotification(
                                                                            notificationId:
                                                                                notification.notificationId!,
                                                                          ));
                                                                        }
                                                                      });
                                                                    },
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red
                                                                            .shade600,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              8.r),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              8.r),
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                          FontAwesomeIcons
                                                                              .trash,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              18.sp,
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                4.h),
                                                                        TextApp(
                                                                          text:
                                                                              'Xóa',
                                                                          fontsize:
                                                                              12.sp,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              // : ActionPane(
                                                              //     extentRatio:
                                                              //         0.2,
                                                              //     motion:
                                                              //         const DrawerMotion(),
                                                              //     children: [
                                                              //       CustomSlidableAction(
                                                              //         onPressed:
                                                              //             (context) {
                                                              //           Navigator
                                                              //               .push(
                                                              //             context,
                                                              //             MaterialPageRoute(
                                                              //               builder: (context) => NotificationDetail(
                                                              //                 notificationItem: notification,
                                                              //               ),
                                                              //             ),
                                                              //           );
                                                              //         },
                                                              //         backgroundColor: Theme.of(context)
                                                              //             .colorScheme
                                                              //             .primary,
                                                              //         foregroundColor:
                                                              //             Colors.white,
                                                              //         borderRadius:
                                                              //             BorderRadius.circular(8.r),
                                                              //         child:
                                                              //             Column(
                                                              //           mainAxisAlignment:
                                                              //               MainAxisAlignment.center,
                                                              //           children: [
                                                              //             Icon(
                                                              //               FontAwesomeIcons.eye,
                                                              //               color: Colors.white,
                                                              //               size: 18.sp,
                                                              //             ),
                                                              //             SizedBox(height: 4.h),
                                                              //             TextApp(
                                                              //               text: 'Xem',
                                                              //               fontsize: 12.sp,
                                                              //               color: Colors.white,
                                                              //               fontWeight: FontWeight.w500,
                                                              //             ),
                                                              //           ],
                                                              //         ),
                                                              //       ),
                                                              //     ],
                                                              //   ),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              NotificationDetail(
                                                                        notificationItem:
                                                                            notification,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          16.w,
                                                                      vertical:
                                                                          8.h),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.r),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.1),
                                                                        blurRadius:
                                                                            10,
                                                                        offset: const Offset(
                                                                            0,
                                                                            3),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .all(16
                                                                            .w),
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        // Icon và độ ưu tiên
                                                                        Container(
                                                                          width:
                                                                              48.w,
                                                                          height:
                                                                              48.w,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            color: notification.notificationImportant == 1
                                                                                ? Colors.amber.withOpacity(0.15)
                                                                                : Colors.grey.shade100,
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Icon(
                                                                              notification.notificationImportant == 1 ? Icons.star_rounded : Icons.star_rounded,
                                                                              color: notification.notificationImportant == 1 ? Colors.amber : Theme.of(context).colorScheme.primary,
                                                                              size: 24.sp,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                16.w),

                                                                        // Nội dung thông báo
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              TextApp(
                                                                                text: notification.notificationTitle,
                                                                                fontsize: 16.sp,
                                                                                color: Colors.black87,
                                                                                fontWeight: FontWeight.w600,
                                                                                maxLines: 2,
                                                                                isOverFlow: true,
                                                                              ),
                                                                              SizedBox(height: 6.h),
                                                                              Row(
                                                                                children: [
                                                                                  Container(
                                                                                    padding: EdgeInsets.symmetric(
                                                                                      horizontal: 8.w,
                                                                                      vertical: 4.h,
                                                                                    ),
                                                                                    decoration: BoxDecoration(
                                                                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                                                      borderRadius: BorderRadius.circular(12.r),
                                                                                    ),
                                                                                    child: TextApp(
                                                                                      text: notification.user.userContactName,
                                                                                      fontsize: 12.sp,
                                                                                      color: Theme.of(context).colorScheme.primary,
                                                                                      fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(width: 8.w),
                                                                                  Expanded(
                                                                                    child: TextApp(
                                                                                      text: getTimeAgo(notification.createdAt),
                                                                                      fontsize: 12.sp,
                                                                                      color: Colors.grey.shade600,
                                                                                      fontWeight: FontWeight.w400,
                                                                                      maxLines: 1,
                                                                                      isOverFlow: true,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),

                                                                        // Indicator cho swipe action
                                                                        Icon(
                                                                          Icons
                                                                              .chevron_left,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade400,
                                                                          size:
                                                                              20.sp,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 4.h),
                                                          ],
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        NotificationDetail(
                                                                  notificationItem:
                                                                      notification,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16.w,
                                                                    vertical:
                                                                        8.h),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.r),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.1),
                                                                  blurRadius:
                                                                      10,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 3),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          16.w),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  // Icon và độ ưu tiên
                                                                  Container(
                                                                    width: 48.w,
                                                                    height:
                                                                        48.w,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: notification.notificationImportant ==
                                                                              1
                                                                          ? Colors.amber.withOpacity(
                                                                              0.15)
                                                                          : Colors
                                                                              .grey
                                                                              .shade100,
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Icon(
                                                                        notification.notificationImportant ==
                                                                                1
                                                                            ? Icons.star_rounded
                                                                            : Icons.star_rounded,
                                                                        color: notification.notificationImportant ==
                                                                                1
                                                                            ? Colors.amber
                                                                            : Theme.of(context).colorScheme.primary,
                                                                        size: 24
                                                                            .sp,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          16.w),

                                                                  // Nội dung thông báo
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        TextApp(
                                                                          text:
                                                                              notification.notificationTitle,
                                                                          fontsize:
                                                                              16.sp,
                                                                          color:
                                                                              Colors.black87,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          maxLines:
                                                                              2,
                                                                          isOverFlow:
                                                                              true,
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                6.h),
                                                                        Row(
                                                                          children: [
                                                                            Container(
                                                                              padding: EdgeInsets.symmetric(
                                                                                horizontal: 8.w,
                                                                                vertical: 4.h,
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                                                borderRadius: BorderRadius.circular(12.r),
                                                                              ),
                                                                              child: TextApp(
                                                                                text: notification.user.userContactName,
                                                                                fontsize: 12.sp,
                                                                                color: Theme.of(context).colorScheme.primary,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                            ),
                                                                            SizedBox(width: 8.w),
                                                                            Expanded(
                                                                              child: TextApp(
                                                                                text: getTimeAgo(notification.createdAt),
                                                                                fontsize: 12.sp,
                                                                                color: Colors.grey.shade600,
                                                                                fontWeight: FontWeight.w400,
                                                                                maxLines: 1,
                                                                                isOverFlow: true,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                }
                                              },
                                            ),
                                            SizedBox(
                                              height: 30.w,
                                            )
                                          ],
                                        ),
                                      )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else if (state is NotificationStateFailure) {
                return AlertDialog(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.w),
                  ),
                  actionsPadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.only(
                      top: 35.w, bottom: 30.w, left: 35.w, right: 35.w),
                  titlePadding: EdgeInsets.all(15.w),
                  surfaceTintColor: Colors.white,
                  backgroundColor: Colors.white,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextApp(
                        text: "CÓ LỖI XẢY RA !",
                        fontsize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 250.w,
                          height: 250.w,
                          child: Lottie.asset('assets/lottie/error_dialog.json',
                              fit: BoxFit.contain),
                        ),
                      ),
                      TextApp(
                        text: "Đã có lỗi xảy ra!.",
                        fontsize: 18.sp,
                        softWrap: true,
                        isOverFlow: false,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Container(
                        width: 150.w,
                        height: 50.h,
                        child: ButtonApp(
                          event: () {},
                          text: "Xác nhận",
                          fontsize: 14.sp,
                          colorText: Colors.white,
                          backgroundColor: Colors.black,
                          outlineColor: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const Center(
                child: NoDataFoundWidget(),
              );
            },
          ),
        ));
  }
}
