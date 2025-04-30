import 'dart:developer';
import 'dart:io';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/screen/home/notifications.dart';
import 'package:scan_barcode_app/ui/screen/order/order_pickup_screen.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/list_scan/list_scan_import_code.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/list_scan/list_scan_over_48h.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_bag_code_export_screen.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_code_import_screen.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_code_in_transit_screen.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_code_return_screen.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_manager_screen.dart';
import 'package:scan_barcode_app/ui/screen/shipper/edit_profile_shipper.dart';
import 'package:scan_barcode_app/ui/screen/shipper/shipper_list_order.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class IndexHomeShipper extends StatefulWidget {
  const IndexHomeShipper({super.key});

  @override
  State<IndexHomeShipper> createState() => _IndexHomeShipperState();
}

class _IndexHomeShipperState extends State<IndexHomeShipper> {
  int _selectedIndex = 0;
  List<IconData> iconList = [
    Icons.receipt,
    Icons.notifications,
    Icons.create_new_folder,
    Icons.person,
  ];
  List<String> titleBottomNav_OPS = ["Thông báo", "Cá nhân"];
  List<String> titleBottomNav_OPS_Leader = [
    "Đơn hàng",
    "Thông báo",
    "Shipment",
    "Cá nhân"
  ];
  String currentTitle = 'Đơn hàng';
  static const List<Widget> _widgetOptions = <Widget>[
    ListScanImportCodeScreen(),
    NotificationsScreen(),
    EditProfileShipper()
  ];
  static const List<Widget> _widgetOptionsOpsLeader = <Widget>[
    OrderPickUpScreen(),
    NotificationsScreen(),
    PackageManagerScreen(),
    EditProfileShipper()
  ];
  void vibrate() {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  void _onItemTapped(int index, bool isOpsLeader) {
    vibrate();
    mounted
        ? setState(() {
            if (!isOpsLeader) {
              // For ops: 0 = Notifications (widget index 1), 1 = Profile (widget index 2)
              _selectedIndex = index == 0 ? 1 : 2;
            } else {
              _selectedIndex = index;
            }
            // Update title accordingly
            if (isOpsLeader) {
              index == 0
                  ? currentTitle = 'Đơn hàng'
                  : index == 1
                      ? currentTitle = 'Thông báo'
                      : index == 2
                          ? currentTitle = 'Shipment'
                          : currentTitle = 'Cá nhân';
            } else {
              index == 0
                  ? currentTitle = 'Thông báo'
                  : currentTitle = 'Cá nhân';
            }
          })
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final String? position =
        StorageUtils.instance.getString(key: 'user_position');
    final int? positionId = StorageUtils.instance.getInt(key: 'positionID');
    log((position == 'ops_leader').toString());
    final bool isOpsLeader = positionId == 8;
    // Determine which items to show in bottom nav based on user type
    final List<IconData> currentIconList = isOpsLeader
        ? iconList
        : [iconList[1], iconList[3]]; // Only notifications and profile for ops

    final List<String> currentTitles =
        isOpsLeader ? titleBottomNav_OPS_Leader : titleBottomNav_OPS;

    // Calculate the active index for the bottom navigation
    int activeNavIndex = -1;

    if (!isOpsLeader) {
      if (_selectedIndex == 1) {
        activeNavIndex = 0; // Notifications tab
      } else if (_selectedIndex == 2) {
        activeNavIndex = 1; // Profile tab
      }
      // Leave activeNavIndex as -1 when _selectedIndex is 0 (ListScanImportCodeScreen)
    } else {
      activeNavIndex = _selectedIndex; // For ops_leader, direct mapping
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: positionId == 8
              ? _widgetOptionsOpsLeader.elementAt(_selectedIndex)
              : _widgetOptions.elementAt(_selectedIndex)),
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
                initialChildSize: 0.6, // Chiều cao ban đầu (70% màn hình)
                minChildSize: 0.5, // Chiều cao tối thiểu (50% màn hình)
                maxChildSize: 0.6, // Chiều cao tối đa (90% màn hình)
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
                                            const ScanCodeInTransitScreenWithController(
                                                titleScreen:
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
                                  if (isOpsLeader == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ListScanImportCodeScreen()),
                                    );
                                  } else {
                                    setState(() {
                                      _selectedIndex = 0;
                                    });
                                  }
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
        itemCount: currentIconList.length,
        tabBuilder: (int index, bool isActive) {
          return Column(
            children: [
              SizedBox(
                height: 10.h,
              ),
              Icon(
                currentIconList[index],
                size: 28.sp,
                color: index == activeNavIndex
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
              ),
              TextApp(
                text: currentTitles[index],
                fontWeight: FontWeight.bold,
                fontsize: 12.sp,
                color: index == activeNavIndex
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              )
            ],
          );
        },
        activeIndex: positionId == 8 ? _selectedIndex : activeNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        onTap: (index) {
          _onItemTapped(index, isOpsLeader);
        },
      ),
    );
  }
}
