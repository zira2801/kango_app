import 'dart:io';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/screen/home/notifications.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/list_scan/list_scan_import_code.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/list_scan/list_scan_over_48h.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_bag_code_export_screen.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_code_import_screen.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_code_return_screen.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_manager_screen.dart';
import 'package:scan_barcode_app/ui/screen/shipper/edit_profile_shipper.dart';
import 'package:scan_barcode_app/ui/screen/shipper/shipper_list_order.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class IndexHomeDriver extends StatefulWidget {
  const IndexHomeDriver({super.key});

  @override
  State<IndexHomeDriver> createState() => _IndexHomeDriverState();
}

class _IndexHomeDriverState extends State<IndexHomeDriver> {
  int _selectedIndex = 0;
  late String normalizedPosition;
  late List<Widget> _widgetOptions;
  List<IconData> iconList = [
    Icons.receipt,
    Icons.notifications,
    Icons.create_new_folder,
    Icons.person,
  ];
  List<String> titleBottomNav = [
    "Đơn hàng",
    "Thông báo",
    "Shipment",
    "Cá nhân"
  ];

  String currentTitle = 'Đơn hàng';
  // List<Widget> widgetOptions = [
  //   const ShipperOrderScreen(),
  //   const NotificationsScreen(),
  //   PackageManagerScreen(
  //     userPosition: normalizedPosition,
  //     canUploadLabel: normalizedPosition != 'sale' &&
  //         normalizedPosition != 'fwd' &&
  //         normalizedPosition != 'ops-leader' &&
  //         normalizedPosition != 'ops_pickup',
  //     canUploadPayment: normalizedPosition != 'fwd',
  //   ),
  //   const EditProfileShipper()
  // ];

  void vibrate() {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  void initState() {
    final String? position =
        StorageUtils.instance.getString(key: 'user_position');
    normalizedPosition = position?.trim().toLowerCase() ?? '';

    _widgetOptions = [
      const ShipperOrderScreen(),
      const NotificationsScreen(),
      PackageManagerScreen(
        userPosition: normalizedPosition,
        canUploadLabel: normalizedPosition != 'sale' &&
            normalizedPosition != 'fwd' &&
            normalizedPosition != 'ops-leader' &&
            normalizedPosition != 'ops_pickup',
        canUploadPayment: normalizedPosition != 'fwd' &&
            normalizedPosition != 'document' &&
            normalizedPosition != 'accountant',
      ),
      const EditProfileShipper()
    ];
    super.initState();
  }

  void _onItemTapped(int index) {
    vibrate();
    mounted
        ? setState(() {
            _selectedIndex = index;
            index == 0
                ? currentTitle = 'Đơn hàng'
                : index == 1
                    ? currentTitle = 'Scan'
                    : index == 2
                        ? currentTitle = 'Shipment'
                        : currentTitle = 'Cá nhân';
          })
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
      // body: SafeArea(child: ShipperOrderScreen()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {
          showModalBottomSheet(
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
              return DraggableScrollableSheet(
                maxChildSize: 0.5,
                initialChildSize: 0.5,
                expand: false,
                builder:
                    (BuildContext context, ScrollController scrollController) {
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
                        Padding(
                          padding: EdgeInsets.all(20..w),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ScanCodeImportScreenWithController(
                                                titleScrenn: "Scan nhập hàng")),
                                  );
                                },
                                child: Container(
                                    width: 1.sw,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.qr_code,
                                          size: 32.sp,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        TextApp(
                                          text: "Scan nhập hàng",
                                          fontsize: 16.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Divider(),
                              SizedBox(
                                height: 10.h,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ScanBagCodeExportScreenWithController(
                                                titleScrenn: "Scan xuất hàng")),
                                  );
                                },
                                child: Container(
                                    width: 1.sw,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.qr_code,
                                          size: 32.sp,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        TextApp(
                                          text: "Scan xuất hàng",
                                          fontsize: 16.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Divider(),
                              SizedBox(
                                height: 10.h,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ScanCodeReturnScreenWithController(
                                                titleScrenn: "Scan trả hàng")),
                                  );
                                },
                                child: Container(
                                    width: 1.sw,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.qr_code,
                                          size: 32.sp,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        TextApp(
                                          text: "Scan trả hàng",
                                          fontsize: 16.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Divider(),
                              SizedBox(
                                height: 10.h,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ScanBagCodeExportScreenWithController(
                                                titleScrenn:
                                                    "Scan in transit")),
                                  );
                                },
                                child: Container(
                                    width: 1.sw,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.qr_code,
                                          size: 32.sp,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        TextApp(
                                          text: "Scan in transit",
                                          fontsize: 16.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              // Divider(),
                              // SizedBox(
                              //   height: 10.h,
                              // ),
                              // InkWell(
                              //   onTap: () {
                              //     Navigator.pop(context);
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (context) =>
                              //               const ScanBagCodeExportScreenWithController(
                              //                   titleScrenn: "Scan chốt bill")),
                              //     );
                              //   },
                              //   child: Container(
                              //       width: 1.sw,
                              //       child: Row(
                              //         children: [
                              //           Icon(
                              //             Icons.qr_code,
                              //             size: 32.sp,
                              //             color: Colors.black,
                              //           ),
                              //           SizedBox(
                              //             width: 10.w,
                              //           ),
                              //           TextApp(
                              //             text: "Scan chốt bill",
                              //             fontsize: 16.sp,
                              //             color: Colors.black,
                              //             fontWeight: FontWeight.bold,
                              //           ),
                              //         ],
                              //       )),
                              // ),
                              // SizedBox(
                              //   height: 10.h,
                              // ),

                              Divider(),
                              SizedBox(
                                height: 10.h,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ListScanImportCodeScreen()),
                                  );
                                },
                                child: Container(
                                    width: 1.sw,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list,
                                          size: 32.sp,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        TextApp(
                                          text: "List scan nhập",
                                          fontsize: 16.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),

                              Divider(),
                              SizedBox(
                                height: 10.h,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ListScanOver48HCodeScreen()),
                                  );
                                },
                                child: Container(
                                    width: 1.sw,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list,
                                          size: 32.sp,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        TextApp(
                                          text: "List scan quá 48h",
                                          fontsize: 16.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        child: Container(
          padding: EdgeInsets.all(5.r),
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.w),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          child: Container(
              width: 60.w,
              height: 60.w,
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.w),
                  color: Theme.of(context).colorScheme.primary),
              child: Image.asset(
                "assets/images/nav_scan.png",
                fit: BoxFit.cover,
              )),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        backgroundColor: Colors.white,
        borderWidth: 1.5,
        borderColor: Theme.of(context).colorScheme.surface,
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          return Column(
            children: [
              SizedBox(
                height: 10.h,
              ),
              Icon(
                iconList[index],
                size: 28.sp,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
              ),
              TextApp(
                text: titleBottomNav[index],
                fontWeight: FontWeight.bold,
                fontsize: 12.sp,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              )
            ],
          );
        },
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        onTap: _onItemTapped,
      ),
    );
  }
}
