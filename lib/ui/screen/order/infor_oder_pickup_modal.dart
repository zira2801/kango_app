import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/bloc/shipper/take_order_pickup/take_order_pickup_bloc.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/maps/tracking_order_pickup_map.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class OrderPickupDetailsDialog extends StatelessWidget {
  final DetailsOrderPickUpModel? detailsOrderPickUp;
  final InforAccountModel? dataUser;
  final double? shipperLongitude;
  final double? shipperLatitude;
  final bool isShipper;

  const OrderPickupDetailsDialog(
      {Key? key,
      this.detailsOrderPickUp,
      this.dataUser,
      this.shipperLongitude,
      this.shipperLatitude,
      this.isShipper = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (detailsOrderPickUp == null) {
      return ErrorDialog(
        eventConfirm: () {
          Navigator.pop(context);
        },
      );
    }
    Future<void> onGetDetailsOrderPickup() async {
      context.read<TakeOrderPickupBloc>().add(
            HanldeTakeOrderPickupShipper(
                shipperID: dataUser!.data.userId,
                orderPickUpID: detailsOrderPickUp!.data.orderPickupId,
                shipperLongitude: shipperLongitude!,
                shipperLatitude: shipperLatitude!,
                locationAddress:
                    detailsOrderPickUp!.data.orderPickupAddress ?? ''),
          );
    }

    return DraggableScrollableSheet(
      maxChildSize: 0.8,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return MultiBlocListener(
          listeners: [
            BlocListener<TakeOrderPickupBloc, TakeOrderPickupState>(
                listener: (context, state) async {
              if (state is TakeOrderPickupSuccess) {
                Navigator.pop(context);
                showCustomDialogModal(
                    isCanCloseWhenTouchOutside: true,
                    context: navigatorKey.currentContext!,
                    textDesc: state.successText ?? 'Nhận đơn thành công',
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              } else if (state is TakeOrderPickupFailure) {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.errorText ?? 'Đã có lỗi xảy ra',
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              }
            }),
          ],
          child: BlocBuilder<TakeOrderPickupBloc, TakeOrderPickupState>(
              builder: (context, state) {
            return Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50.w,
                    height: 5.h,
                    margin: EdgeInsets.only(top: 15.w, bottom: 15.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(10.w),
                      controller: scrollController,
                      children: [
                        _buildRow(context, 'ID BILL :',
                            detailsOrderPickUp!.data.orderPickupCode),
                        Divider(height: 25.h),
                        _buildRow(context, 'Địa chỉ :',
                            detailsOrderPickUp!.data.orderPickupAddress ?? ''),
                        Divider(height: 25.h),
                        _buildRow(
                            context,
                            'Loại :',
                            _getPickupType(
                                detailsOrderPickUp!.data.orderPickupType)),
                        Divider(height: 25.h),
                        _buildStatusRow(context, 'Trạng thái :',
                            detailsOrderPickUp!.data.orderPickupStatus),
                        Divider(height: 25.h),
                        _buildRow(
                            context,
                            'Thời gian:',
                            detailsOrderPickUp!.data.orderPickupDateTime
                                .toString()),
                        Divider(height: 25.h),
                        _buildRow(context, 'Người tạo :',
                            detailsOrderPickUp!.data.user!.userContactName),
                        Divider(height: 25.h),
                        _buildRow(context, 'Số điện thoại người tạo:',
                            detailsOrderPickUp!.data.user!.userPhone),
                        Divider(height: 25.h),
                        _buildRow(
                            context,
                            'FWD :',
                            detailsOrderPickUp!.data.fwd?.userCompanyName ??
                                ''),
                        Divider(height: 25.h),
                        _buildRow(context, 'Số điện thoại FWD :',
                            detailsOrderPickUp!.data.fwd?.userPhone ?? ''),
                        Divider(height: 25.h),
                        _buildRow(
                            context,
                            'Shipper nhận đơn :',
                            detailsOrderPickUp!.data.shipper?.userContactName ??
                                'Chưa có shipper nhận đơn!'),
                        Divider(height: 25.h),
                        _buildRow(
                            context,
                            'Nhân viên sale phụ trách :',
                            detailsOrderPickUp!.data.sale?.userContactName ??
                                'Không có nhân viên sale phụ trách'),
                        Divider(height: 25.h),
                        _buildRow(context, 'Chi nhánh :',
                            detailsOrderPickUp!.data.branch.branchName ?? ''),
                        Divider(height: 25.h),
                        _buildRow(
                            context,
                            'Gross Weight :',
                            detailsOrderPickUp!.data.orderPickupGrossWeight
                                .toString()),
                        Divider(height: 25.h),
                        _buildRow(
                            context,
                            'Note :',
                            detailsOrderPickUp!.data.orderPickupNote ??
                                'Không'),
                        detailsOrderPickUp!.data.orderPickupStatus == 6
                            ? Divider(height: 25.h)
                            : Container(),
                        detailsOrderPickUp!.data.orderPickupStatus == 6
                            ? _buildRow(
                                context,
                                'Lý do huỷ đơn :',
                                detailsOrderPickUp!.data.orderPickupCancelDes ??
                                    'Không')
                            : Container(),
                        /* Divider(height: 25.h),
                        _buildRow(
                            context,
                            'Method :',
                            detailsOrderPickUp!.data.orderPickupMethod
                                .toString()),*/
                        SizedBox(height: 20.h),
                        (isShipper &&
                                detailsOrderPickUp!.data.orderPickupStatus == 0)
                            // isShipper
                            ? ButtonApp(
                                event: () {
                                  onGetDetailsOrderPickup();
                                },
                                text: "Nhận đơn",
                                colorText: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontsize: 16.sp,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                outlineColor:
                                    Theme.of(context).colorScheme.primary)
                            : (!isShipper &&
                                        detailsOrderPickUp!
                                                .data.orderPickupStatus ==
                                            3) ||
                                    (!isShipper &&
                                        detailsOrderPickUp!
                                                .data.orderPickupStatus ==
                                            4)
                                ? ButtonApp(
                                    event: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TrackingOrderPickupMap(
                                                  orderPickupID:
                                                      detailsOrderPickUp!
                                                          .data.orderPickupId,
                                                )),
                                      );
                                    },
                                    text: "Theo dõi đơn hàng",
                                    colorText: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontsize: 16.sp,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    outlineColor:
                                        Theme.of(context).colorScheme.primary)
                                : Container()
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, String title, String value) {
    return Row(
      children: [
        TextApp(
          text: title,
          fontWeight: FontWeight.bold,
          fontsize: 16.sp,
          color: Colors.black,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: TextApp(
            text: value,
            fontsize: 16.sp,
            color: Colors.black,
            maxLines: 2,
          ),
        )
      ],
    );
  }

  String _getPickupType(int type) {
    switch (type) {
      case 0:
        return 'Xe tải';
      case 1:
        return 'Xe bán tải';
      default:
        return 'Xe máy';
    }
  }

  Widget _buildStatusRow(BuildContext context, String title, int status) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 0:
        statusText = "Đang chờ duyệt";
        statusColor = Colors.grey;
        statusIcon = Icons.replay_circle_filled;
        break;
      case 1:
        statusText = "Đang chờ xác nhận";
        statusColor = const Color.fromARGB(255, 243, 219, 8);
        statusIcon = Icons.on_device_training;
        break;

      case 2:
        statusText = "Đã xác nhận";
        statusColor = Colors.green.shade600;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 3:
        statusText = "Đang đi lấy";
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle_rounded;
        break;

      case 4:
        statusText = "Đã lấy";
        statusColor = Colors.blue;
        statusIcon = Icons.get_app;
        break;
      case 5:
        statusText = "Đã pickup";
        statusColor = Colors.green;
        statusIcon = Icons.fire_truck_sharp;
        break;
      case 6:
        statusText = "Đã huỷ";
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusText = "Đang chờ";
        statusColor = const Color.fromARGB(255, 243, 219, 8);
        statusIcon = Icons.replay_circle_filled;
        break;
    }

    return Row(
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Colors.black)),
        SizedBox(width: 10.w),
        Container(
          width: 150.w,
          height: 20.h,
          color: statusColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: Colors.white, size: 14.sp),
              SizedBox(width: 5.w),
              TextApp(
                text: statusText,
                maxLines: 2,
                color: Colors.white,
                fontsize: 14.sp,
              )
            ],
          ),
        ),
      ],
    );
  }
}
