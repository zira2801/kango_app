import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/bloc/recharge/content_payment/content_payment_bloc.dart';
import 'package:scan_barcode_app/bloc/recharge/content_payment/content_payment_event.dart';
import 'package:scan_barcode_app/bloc/recharge/content_payment/content_payment_state.dart';
import 'package:scan_barcode_app/ui/screen/recharge/recharge_SePay_screen.dart';
import 'package:scan_barcode_app/ui/screen/recharge/recharge_USDT_screen.dart';
import 'package:scan_barcode_app/ui/screen/recharge/recharge_cash_screen.dart';
import 'package:scan_barcode_app/ui/screen/recharge/recharge_personal_screen.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

// ignore: must_be_immutable
class SelectedMethodRechargeScreen extends StatelessWidget {
  SelectedMethodRechargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: TextApp(
            text: "Chọn phương thức nạp tiền",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: ListView.separated(
              shrinkWrap: true, // Để ListView không chiếm toàn bộ chiều cao
              physics:
                  const NeverScrollableScrollPhysics(), // Tắt cuộn nếu không cần
              itemCount: 4, // Số lượng phương thức thanh toán
              separatorBuilder: (context, index) => SizedBox(height: 15.h),
              itemBuilder: (context, index) {
                // Danh sách thông tin cho từng nút
                final List<Map<String, dynamic>> paymentMethods = [
                  {
                    'text': 'Chuyển Khoản Ngân Hàng (QRcode)',
                    'icon': Icons.qr_code,
                    'screen': const RechargeSePayScreen(),
                    'type': 'vnpay',
                  },
                  {
                    'text': 'Thanh toán bằng USDT',
                    'icon': Icons.currency_bitcoin,
                    'screen': const RechargeUSDTScreen(),
                    'type': 'usdt',
                  },
                  {
                    'text': 'Nộp tiền trực tiếp',
                    'icon': Icons.money,
                    'screen': const RechargeCashScreen(),
                    'type': 'direct',
                  },
                  {
                    'text': 'Tài khoản cá nhân',
                    'icon': Icons.person,
                    'screen': const RechargePersonalScreen(),
                    'type': 'personal',
                  },
                ];

                final method = paymentMethods[index];

                return GestureDetector(
                  onTap: () {
                    context
                        .read<PaymentContentBloc>()
                        .add(LoadPaymentContent(method['type']));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => method['screen']),
                    );
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // Bóng đổ nhẹ
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon đại diện cho phương thức
                        Icon(
                          method['icon'],
                          color: Colors.white,
                          size: 30.sp,
                        ),
                        SizedBox(width: 15.w),
                        // Text mô tả
                        Expanded(
                          child: Text(
                            method['text'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Icon mũi tên để chỉ hành động
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }
}
