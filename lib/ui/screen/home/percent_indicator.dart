import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class PercentIndicator extends StatefulWidget {
  final double currentPercent;
  final int remainingLimit;
  final int userLimitAmountForSale;

  const PercentIndicator({
    required this.currentPercent,
    required this.remainingLimit,
    required this.userLimitAmountForSale,
    super.key,
  });

  @override
  State<PercentIndicator> createState() => _PercentIndicatorState();
}

class _PercentIndicatorState extends State<PercentIndicator> {
  int roundedPercentage = 0;

  @override
  Widget build(BuildContext context) {
    // Tính toán giá trị phần trăm và giới hạn trong khoảng [0.0, 1.0]
    double validPercent = widget.currentPercent.isFinite
        ? widget.currentPercent
            .clamp(0.0, 1.0) // Giới hạn giá trị từ 0.0 đến 1.0
        : 0.0;
    setState(() {
      roundedPercentage = (validPercent * 100).round();
    });

    return SizedBox(
      width: 1.sw,
      child: CircularPercentIndicator(
        radius: 120.0,
        lineWidth: 13.0,
        animation: true,
        percent: validPercent,
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextApp(text: "Nợ/Giới hạn"),
            Text(
              "$roundedPercentage %",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            // Hiển thị thông báo nếu vượt hạn mức
            if (widget.currentPercent > 1.0)
              TextApp(
                text: "(Vượt hạn mức)",
                fontsize: 12.sp,
                color: Colors.red,
              ),
          ],
        ),
        footer: Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Column(
            children: [
              TextApp(
                text: "Hạn mức nợ",
                fontsize: 14.sp,
                color: Colors.black,
              ),
              TextApp(
                text: formatNumber(widget.userLimitAmountForSale.toString()),
                fontsize: 18.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 15.h),
              TextApp(
                text: "Nợ tạm tính",
                fontsize: 14.sp,
                color: Colors.black,
              ),
              TextApp(
                text: formatNumber(widget.remainingLimit.toString()),
                fontsize: 18.sp,
                color: widget.currentPercent > 1.0 ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: widget.currentPercent > 1.0
            ? Colors.red // Đổi màu nếu vượt hạn mức
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
