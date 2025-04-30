import 'dart:io';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/bloc/menu/menu_bloc.dart';
import 'package:scan_barcode_app/ui/screen/home/notifications.dart';
import 'package:scan_barcode_app/ui/screen/home/home_screen.dart';
import 'package:scan_barcode_app/ui/screen/home/truy_van_screen.dart';
import 'package:scan_barcode_app/ui/screen/profile/index.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_bag_code_export_screen.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_code_import_screen.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_code_return_screen.dart';
import 'package:scan_barcode_app/ui/screen/shipment/create_new_shipment.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class IndexHome extends StatefulWidget {
  const IndexHome({super.key});

  @override
  State<IndexHome> createState() => _IndexHomeState();
}

class _IndexHomeState extends State<IndexHome> {
  int _selectedIndex = 0;

  List<IconData> iconList = [
    Icons.home,
    Icons.receipt,
    Icons.notifications,
    Icons.person
  ];
  List<String> titleBottomNav = [
    "Trang chủ",
    "Truy vấn",
    "Thông báo",
    "Cá nhân"
  ];

  String currentTitle = 'Dashboard';
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    // NotificationsScreen(),
    TruyVanScreen(),
    NotificationsScreen(),
    ProfileUserScreen()
  ];
  bool isHaveNoti = false;

  void _onItemTapped(int index) {
    vibrate();
    mounted
        ? setState(() {
            _selectedIndex = index;
            index == 0
                ? currentTitle = 'Trang chủ'
                : index == 1
                    ? currentTitle = 'Truy vấn'
                    : index == 3
                        ? currentTitle = 'Thông báo'
                        : index == 4
                            ? currentTitle = 'Cá nhân'
                            : '';
          })
        : null;
  }

  void vibrate() {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    final String? userPosition =
        StorageUtils.instance.getString(key: 'user_position');
    final bool? isCanScan = StorageUtils.instance.getBool(key: 'isCanScan');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: userPosition == 'sale' || userPosition == 'fwd'
          ? FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => userPosition == 'sale'
                            ? const CreateShipmentScreen(
                                shipmentCode: null,
                                isSale: true,
                              )
                            : const CreateShipmentScreen(
                                shipmentCode: null,
                                isSale: false,
                              )));
              },
              child: Container(
                padding: EdgeInsets.all(5.r),
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.w),
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                child: Container(
                    width: 60.w,
                    height: 60.w,
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.w),
                        color: Theme.of(context).colorScheme.primary),
                    child: Icon(Icons.create_new_folder)),
              ),
            )
          : FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {
                isCanScan!
                    ? showModalBottomSheet(
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
                            maxChildSize: 0.8,
                            initialChildSize: 0.4,
                            expand: false,
                            builder: (BuildContext context,
                                ScrollController scrollController) {
                              return Container(
                                color: Colors.white,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 50.w,
                                      height: 5.h,
                                      margin: EdgeInsets.only(
                                          top: 15.w, bottom: 15.w),
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
                                                            titleScrenn:
                                                                "Scan nhập hàng")),
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                                "Scan xuất hàng")),
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                            titleScrenn:
                                                                "Scan trả hàng")),
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                      )
                    : showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            eventConfirm: () {
                              Navigator.pop(context);
                            },
                            errorText:
                                "Bạn không có quyền thực hiện chức năng này!",
                          );
                        });
              },
              child: Container(
                padding: EdgeInsets.all(5.r),
                width: screenWidth > 600 ? 120.w : 60.w,
                height: screenWidth > 600 ? 120.w : 60.w,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(screenWidth > 600 ? 50.w : 30.w),
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                child: Container(
                    width: screenWidth > 600 ? 100.w : 60.w,
                    height: screenWidth > 600 ? 100.w : 60.w,
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            screenWidth > 600 ? 50.w : 30.w),
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
        height: 65.h,
        borderWidth: 1.5.w,
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
                size: 24.sp,
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
