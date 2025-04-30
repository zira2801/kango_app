import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

void showCustomDialogModal({
  required context,
  required String textDesc,
  required String title,
  required Color colorButtonOk,
  Color colorButtonCancle = Colors.red,
  required String btnOKText,
  String btnCancleText = "Huỷ",
  required String? typeDialog,
  bool isTwoButton = false,
  Function()? eventButtonOKPress,
  Function()? eventButtonCanclePress,
  bool isCanCloseWhenTouchOutside = true,
  bool isShowCloseIcon = true,
  Function()? onDismissCallback,
}) {
  isTwoButton
      ? AwesomeDialog(
          dismissOnTouchOutside: isCanCloseWhenTouchOutside,
          context: context,
          animType: AnimType.leftSlide,
          headerAnimationLoop: false,
          dialogType: typeDialog == "success"
              ? DialogType.success
              : typeDialog == "question"
                  ? DialogType.question
                  : typeDialog == "info"
                      ? DialogType.info
                      : typeDialog == "noHeader"
                          ? DialogType.noHeader
                          : DialogType.error,
          showCloseIcon: isShowCloseIcon,
          title: title,
          desc: textDesc,
          btnOkColor: colorButtonOk,
          btnOkOnPress: eventButtonOKPress,
          btnOkText: btnOKText,
          titleTextStyle: TextStyle(fontSize: 16.sp, color: Colors.black),
          descTextStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
          buttonsTextStyle: TextStyle(fontSize: 14.sp, color: Colors.white),
          btnCancelText: btnCancleText,
          btnCancelColor: colorButtonCancle,
          btnCancelOnPress: eventButtonCanclePress,
          onDismissCallback: (type) {
            debugPrint('Dialog Dissmiss from callback $type');
            if (onDismissCallback != null) {
              onDismissCallback(); // Gọi callback khi dialog bị đóng
            }
          },
        ).show()
      : AwesomeDialog(
          dismissOnTouchOutside: isCanCloseWhenTouchOutside,
          context: context,
          animType: AnimType.leftSlide,
          headerAnimationLoop: false,
          dialogType: typeDialog == "success"
              ? DialogType.success
              : typeDialog == "question"
                  ? DialogType.question
                  : typeDialog == "info"
                      ? DialogType.info
                      : typeDialog == "noHeader"
                          ? DialogType.noHeader
                          : DialogType.error,
          showCloseIcon: true,
          title: title,
          desc: textDesc,
          titleTextStyle: TextStyle(fontSize: 16.sp, color: Colors.black),
          descTextStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
          btnOkColor: colorButtonOk,
          buttonsTextStyle: TextStyle(fontSize: 14.sp, color: Colors.white),
          btnOkOnPress: eventButtonOKPress,
          btnOkText: btnOKText,
          onDismissCallback: (type) {
            debugPrint('Dialog Dissmiss from callback $type');
            if (onDismissCallback != null) {
              onDismissCallback(); // Gọi callback khi dialog bị đóng
            }
          },
        ).show();
}

/****DialogType ******/
// ///Dialog with information type header
// info,
// ///Dialog with information type header rotated 180 degree
// infoReverse,
// ///Dialog with warning amber type header
// warning,
// ///Dialog with error red type header
// error,
// ///Dialog with success green type header
// success,
// ///Dialog without a header
// noHeader,
// ///Dialog with question header
// question

void showExpiredOtpDialog(context) {
  AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.rightSlide,
          headerAnimationLoop: true,
          title: 'OTP hết hạn',
          desc: 'Mã OTP của bạn đã hết hạn, vui lòng bấm Gửi lại mã mới!',
          btnCancelColor: Theme.of(context).colorScheme.primary,
          btnCancelOnPress: () {},
          btnCancelText: "OK")
      .show();
}

void showExpiredPaymentSePay({
  required BuildContext context,
  required Function()? eventButtonCanclePress,
}) {
  AwesomeDialog(
          dismissOnTouchOutside: false,
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.rightSlide,
          headerAnimationLoop: true,
          title: 'Giao dịch hết hạn',
          desc:
              'Đơn thanh toán trực tuyến này đã hết hạn! Vui lòng tạo đơn mới để được thanh toán.',
          btnCancelColor: Theme.of(context).colorScheme.primary,
          btnCancelOnPress: eventButtonCanclePress,
          btnCancelText: "OK")
      .show();
}

void showSuccesPaymentSePay({
  required BuildContext context,
  required Function()? eventButtonCanclePress,
}) {
  AwesomeDialog(
          dismissOnTouchOutside: false,
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.rightSlide,
          headerAnimationLoop: true,
          title: 'Giao dịch thành công',
          desc: 'Đơn thanh toán trực tuyến đã hoàn thành !',
          btnCancelColor: Theme.of(context).colorScheme.primary,
          btnCancelOnPress: eventButtonCanclePress,
          btnCancelText: "OK")
      .show();
}

void showMyCustomModalBottomSheet({
  required BuildContext context,
  required int itemCount,
  required Widget Function(BuildContext, int) itemBuilder,
  Widget? searchWidget,
  required bool isScroll,
  double? height = 0.8,
}) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(15.r),
        topLeft: Radius.circular(15.r),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SizedBox(
        height: height!.sh, // Chiều cao cố định của Bottom Sheet
        child: Column(
          children: [
            Container(
              width: 50.w,
              height: 5.w,
              margin: EdgeInsets.only(top: 15.h, bottom: 15.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.grey,
              ),
            ),
            searchWidget ?? Container(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10.h),
                itemCount: itemCount,
                itemBuilder: itemBuilder,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class ErrorDialog extends StatelessWidget {
  final String? errorText;
  final Function() eventConfirm;
  const ErrorDialog({this.errorText, required this.eventConfirm, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.w),
      ),
      actionsPadding: EdgeInsets.zero,
      contentPadding:
          EdgeInsets.only(top: 0.w, bottom: 30.w, left: 35.w, right: 35.w),
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
              width: 300.w,
              height: 150.w,
              child: Lottie.asset('assets/lottie/error_dialog.json',
                  fit: BoxFit.fill),
            ),
          ),
          // Center(
          //     child: Icon(
          //   Icons.cancel,
          //   size: 150.w,
          //   color: Colors.red,
          // )),
          TextApp(
            text: errorText ??
                "Đã có lỗi xảy ra! \nVui lòng liên hệ quản trị viên.",
            fontsize: 18.sp,
            softWrap: true,
            isOverFlow: false,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          SizedBox(
            height: 15.h,
          ),
          Container(
            width: 150.w,
            height: 50.h,
            child: ButtonApp(
              event: eventConfirm,
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
}
