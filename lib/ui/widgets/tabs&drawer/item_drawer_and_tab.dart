import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

// ignore: must_be_immutable
class ItemDrawer extends StatelessWidget {
  Color textColor;
  Color backgroundIconColor;
  Color iconColor;
  double fontSize;
  FontWeight fontWeight;
  IconData icon;

  final String text;
  ItemDrawer({
    super.key,
    required this.text,
    required this.icon,
    required this.iconColor,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 0,
    this.textColor = Colors.black,
    this.backgroundIconColor = const Color.fromRGBO(233, 236, 239, 1),
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Row(
                children: [
                  Icon(
                    icon,
                    size: 24.sp,
                    color: iconColor,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  TextApp(
                    text: text,
                    textAlign: TextAlign.start,
                    color: textColor,
                    fontWeight: fontWeight,
                    fontsize: 14.sp,
                  )
                ],
              )),
              Icon(
                Icons.chevron_right_outlined,
                size: 30.w,
                color: Colors.grey,
              ),
            ],
          ),
        ));
  }
}

// ignore: must_be_immutable
class SubItemDrawer extends StatelessWidget {
  void Function() event;
  Color textColor;
  Color iconColor;
  double fontSize;
  double iconSize;
  FontWeight fontWeight;
  final String text;
  SubItemDrawer({
    super.key,
    required this.text,
    required this.event,
    this.fontWeight = FontWeight.normal,
    this.iconSize = 0,
    this.iconColor = Colors.black,
    this.fontSize = 0,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        event();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            height: 25.h,
          ),
          Icon(
            Icons.circle,
            size: iconSize == 0 ? 10.w : iconSize,
            color: iconColor,
          ),
          SizedBox(
            width: 10.w,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize == 0 ? 14.w : fontSize,
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomTab extends StatelessWidget {
  final String text;
  IconData icon;
  double sizeIcon;
  double fontSize;
  Color colorText;
  bool isHaveIcon;
  CustomTab({
    super.key,
    required this.text,
    required this.icon,
    this.colorText = Colors.black,
    this.sizeIcon = 0,
    this.fontSize = 0,
    this.isHaveIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            EdgeInsets.only(left: 10.w, right: 10.w, top: 10.w, bottom: 10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isHaveIcon
                ? Icon(
                    icon,
                    size: sizeIcon == 0 ? 20.w : sizeIcon,
                  )
                : Container(),
            SizedBox(
              width: 3.w,
            ),
            Tab(
              text: text,
            )
          ],
        ));
  }
}
