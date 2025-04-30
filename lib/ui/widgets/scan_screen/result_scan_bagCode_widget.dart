import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ResultScanBagCodeWidget extends StatefulWidget {
  final BuildContext context;
  final TextEditingController codeTextController;
  final Function scanAgain;
  final Function(int)? onSelectedID;
  final Function confirmBarCode;

  const ResultScanBagCodeWidget({
    required this.context,
    required this.codeTextController,
    required this.scanAgain,
    required this.confirmBarCode,
    this.onSelectedID,
  });

  @override
  _ResultScanBagCodeWidgetState createState() =>
      _ResultScanBagCodeWidgetState();
}

class _ResultScanBagCodeWidgetState extends State<ResultScanBagCodeWidget> {
  int selectedSmTracktryID = 1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 1.sw,
              height: 250.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15.r),
                  topLeft: Radius.circular(15.r),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    width: 60.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.grey.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  TextApp(
                    text: "Mã đã quét",
                    fontsize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w),
                    child: Center(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        enabled: false,
                        textAlign: TextAlign.center,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        controller: widget.codeTextController,
                        decoration: InputDecoration(
                          fillColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.8),
                          filled: true,
                          hintText: '',
                          labelStyle:
                              TextStyle(color: Colors.white, fontSize: 14.sp),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.0),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.0),
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(10.r, 10.r),
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.0),
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(10.r, 10.r),
                            ),
                          ),
                          contentPadding: EdgeInsets.all(20.w),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ButtonApp(
                            event: () {
                              widget.scanAgain();
                            },
                            text: "Quét lại",
                            colorText: Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.white,
                            outlineColor: Theme.of(context).colorScheme.primary,
                            line: 2,
                          ),
                        ),
                        SizedBox(
                          width: 25.w,
                        ),
                        Expanded(
                          child: ButtonApp(
                            event: () {
                              widget.confirmBarCode(
                                context: context,
                                orderPickupID: widget.codeTextController.text,
                                smTracktryID: selectedSmTracktryID,
                              );
                            },
                            text: "Xác nhận",
                            colorText: Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.white,
                            outlineColor: Theme.of(context).colorScheme.primary,
                            line: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
