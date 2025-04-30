import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/data/models/home/setup_dashboard_model.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;

// ignore: must_be_immutable
class FillterDashBoardHomeWidget extends StatelessWidget {
  final TextEditingController dateStartController;
  final TextEditingController dateEndController;
  final TextEditingController statusTextController;
  final TextEditingController branchTextController;
  final TextEditingController accountTypeTextController;
  final TextEditingController serviceTypeTextController;
  final TextEditingController dateTypeTextController;
  final TextEditingController dashTypeTextController;
  final Function(int) onBrandIDChanged;
  final Function(int) onPositionChanged;
  final Function(int) onShipmentStatusChanged;
  final Function(int) onServicesChanged;
  final Function(String) onCurrentDateTypeChanged;
  final Function(String) onCurrentDashTypeChanged;
  final List<String> listStatus;
  final List<Service> listServices;
  final List<Position> listTypeAccount;
  final List<Branch> listBranch;
  final List<String> listdateType;
  final List<String> listdashType;
  final List<String> listdateFormats;
  final List<String> listdashFormats;

  final Function() selectDayStart;
  final Function() selectDayEnd;
  final Function() clearFliterFunction;
  final Function() applyFliterFunction;
  final String? Function() getEndDateError;

  FillterDashBoardHomeWidget(
      {required this.dateStartController,
      required this.dateEndController,
      required this.statusTextController,
      required this.branchTextController,
      required this.accountTypeTextController,
      required this.serviceTypeTextController,
      required this.dateTypeTextController,
      required this.dashTypeTextController,
      required this.listStatus,
      required this.listServices,
      required this.listTypeAccount,
      required this.listBranch,
      required this.listdateType,
      required this.listdashType,
      required this.listdateFormats,
      required this.listdashFormats,
      required this.selectDayStart,
      required this.selectDayEnd,
      required this.getEndDateError,
      required this.clearFliterFunction,
      required this.applyFliterFunction,
      required this.onBrandIDChanged,
      required this.onPositionChanged,
      required this.onShipmentStatusChanged,
      required this.onServicesChanged,
      required this.onCurrentDateTypeChanged,
      required this.onCurrentDashTypeChanged,
      super.key});
  void showFliter(BuildContext context) {
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
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.8,
              expand: false,
              builder: (BuildContext context,
                  ScrollController scrollControllerFilter) {
                return Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50.w,
                        height: 5.w,
                        margin: EdgeInsets.only(top: 15.h, bottom: 15.h),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: Colors.grey),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollControllerFilter,
                          children: [
                            TextApp(
                              text: 'Lọc dữ liệu',
                              fontWeight: FontWeight.bold,
                              fontsize: 16.sp,
                              textAlign: TextAlign.center,
                              color: Colors.black,
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Từ ngày",
                                          fontsize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        TextField(
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          readOnly: true,
                                          controller: dateStartController,
                                          onTap: () {
                                            selectDayStart();
                                          },
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black),
                                          cursorColor: Colors.black,
                                          decoration: InputDecoration(
                                              suffixIcon: const Icon(
                                                  Icons.calendar_month),
                                              fillColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              hintText: 'dd/mm/yy',
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.all(20.w)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Đến ngày",
                                          fontsize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        TextField(
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          readOnly: true,
                                          controller: dateEndController,
                                          onTap: () {
                                            selectDayEnd();
                                          },
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black),
                                          cursorColor: Colors.black,
                                          decoration: InputDecoration(
                                            suffixIcon: const Icon(
                                                Icons.calendar_month),
                                            fillColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  width: 2.0),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            hintText: 'dd/mm/yy',
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.all(20.w),
                                            errorText: getEndDateError(),
                                            errorStyle: TextStyle(
                                              color: Colors.red,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Biểu đồ theo",
                                          fontsize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            child: CustomTextFormField(
                                              readonly: true,
                                              controller:
                                                  dateTypeTextController,
                                              suffixIcon: Transform.rotate(
                                                angle: 90 * math.pi / 180,
                                                child: Icon(
                                                  Icons.chevron_right,
                                                  size: 32.sp,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                              hintText: 'Ngày',
                                              onTap: () {
                                                showMyCustomModalBottomSheet(
                                                    height: 0.52,
                                                    context: context,
                                                    isScroll: true,
                                                    itemCount:
                                                        listdateType.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20.w),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {
                                                                  dateTypeTextController
                                                                          .text =
                                                                      listdateType[
                                                                          index];
                                                                  onCurrentDateTypeChanged(
                                                                      listdateFormats[
                                                                          index]);
                                                                });
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  TextApp(
                                                                    text: listdateType[
                                                                        index],
                                                                    color: Colors
                                                                        .black,
                                                                    fontsize:
                                                                        20.sp,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 25.h,
                                                          )
                                                        ],
                                                      );
                                                    });
                                              },
                                            )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: "",
                                          fontsize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            child: CustomTextFormField(
                                              readonly: true,
                                              controller:
                                                  dashTypeTextController,
                                              suffixIcon: Transform.rotate(
                                                angle: 90 * math.pi / 180,
                                                child: Icon(
                                                  Icons.chevron_right,
                                                  size: 32.sp,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                              hintText: 'Tổng đơn',
                                              onTap: () {
                                                showMyCustomModalBottomSheet(
                                                    height: 0.52,
                                                    context: context,
                                                    isScroll: true,
                                                    itemCount:
                                                        listdashType.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20.w),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {
                                                                  dashTypeTextController
                                                                          .text =
                                                                      listdashType[
                                                                          index];
                                                                  onCurrentDashTypeChanged(
                                                                      listdashFormats[
                                                                          index]);
                                                                });
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  TextApp(
                                                                    text: listdashType[
                                                                        index],
                                                                    color: Colors
                                                                        .black,
                                                                    fontsize:
                                                                        20.sp,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 25.h,
                                                          )
                                                        ],
                                                      );
                                                    });
                                              },
                                            )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Danh sách loại tài khoản",
                                          fontsize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            child: CustomTextFormField(
                                              readonly: true,
                                              controller:
                                                  accountTypeTextController,
                                              suffixIcon: Transform.rotate(
                                                angle: 90 * math.pi / 180,
                                                child: Icon(
                                                  Icons.chevron_right,
                                                  size: 32.sp,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                              hintText: 'Tất cả',
                                              onTap: () {
                                                showMyCustomModalBottomSheet(
                                                    height: 0.52,
                                                    context: context,
                                                    isScroll: true,
                                                    itemCount:
                                                        listTypeAccount.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20.w),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {
                                                                  accountTypeTextController
                                                                      .text = listTypeAccount[
                                                                          index]
                                                                      .positionName;
                                                                  onPositionChanged(
                                                                      listTypeAccount[
                                                                              index]
                                                                          .positionId);
                                                                });
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  TextApp(
                                                                    text: listTypeAccount[
                                                                            index]
                                                                        .positionName,
                                                                    color: Colors
                                                                        .black,
                                                                    fontsize:
                                                                        20.sp,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 25.h,
                                                          )
                                                        ],
                                                      );
                                                    });
                                              },
                                            )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Trạng thái",
                                          fontsize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            child: CustomTextFormField(
                                              readonly: true,
                                              controller: statusTextController,
                                              suffixIcon: Transform.rotate(
                                                angle: 90 * math.pi / 180,
                                                child: Icon(
                                                  Icons.chevron_right,
                                                  size: 32.sp,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                              hintText: 'Tất cả',
                                              onTap: () {
                                                showMyCustomModalBottomSheet(
                                                    height: 0.52,
                                                    context: context,
                                                    isScroll: true,
                                                    itemCount:
                                                        listStatus.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20.w),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {
                                                                  statusTextController
                                                                          .text =
                                                                      listStatus[
                                                                          index];
                                                                  onShipmentStatusChanged(
                                                                      index);
                                                                });
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  TextApp(
                                                                    text: listStatus[
                                                                        index],
                                                                    color: Colors
                                                                        .black,
                                                                    fontsize:
                                                                        20.sp,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 25.h,
                                                          )
                                                        ],
                                                      );
                                                    });
                                              },
                                            )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Chi nhánh",
                                          fontsize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            // height: 40.w,
                                            child: CustomTextFormField(
                                              readonly: true,
                                              controller: branchTextController,
                                              hintText: 'Tất cả',
                                              suffixIcon: Transform.rotate(
                                                angle: 90 * math.pi / 180,
                                                child: Icon(
                                                  Icons.chevron_right,
                                                  size: 32.sp,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Nội dung không được để trống';
                                                }
                                                return null;
                                              },
                                              onTap: () {
                                                showMyCustomModalBottomSheet(
                                                    context: context,
                                                    isScroll: true,
                                                    height: 0.52,
                                                    itemCount:
                                                        listBranch.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20.w),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    context);

                                                                setState(() {
                                                                  branchTextController
                                                                      .text = listBranch[
                                                                          index]
                                                                      .branchName;
                                                                  onBrandIDChanged(
                                                                      listBranch[
                                                                              index]
                                                                          .branchId);
                                                                });
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  TextApp(
                                                                    text: listBranch[
                                                                            index]
                                                                        .branchName,
                                                                    color: Colors
                                                                        .black,
                                                                    fontsize:
                                                                        20.sp,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 25.h,
                                                          )
                                                        ],
                                                      );
                                                    });
                                              },
                                            )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Dịch vụ",
                                          fontsize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            child: CustomTextFormField(
                                              readonly: true,
                                              controller:
                                                  serviceTypeTextController,
                                              suffixIcon: Transform.rotate(
                                                angle: 90 * math.pi / 180,
                                                child: Icon(
                                                  Icons.chevron_right,
                                                  size: 32.sp,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                              hintText: 'Tất cả',
                                              onTap: () {
                                                final TextEditingController
                                                    searchController =
                                                    TextEditingController();
                                                List<Service> filteredList =
                                                    List.from(
                                                        listServices); // Danh sách ban đầu

                                                showModalBottomSheet(
                                                  backgroundColor: Colors.white,
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    15.r)),
                                                  ),
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder: (BuildContext
                                                              context,
                                                          StateSetter
                                                              setModalState) {
                                                        return SizedBox(
                                                          height: 0.72.sh,
                                                          child: Column(
                                                            children: [
                                                              // Drag handle
                                                              Container(
                                                                width: 50.w,
                                                                height: 5.h,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 15
                                                                            .h,
                                                                        bottom:
                                                                            15.h),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.r),
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              // Search bar
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20.w),
                                                                child:
                                                                    TextField(
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'OpenSans',
                                                                      fontSize:
                                                                          15.sp,
                                                                      color: Colors
                                                                          .black),
                                                                  controller:
                                                                      searchController,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    hintStyle:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'OpenSans',
                                                                      fontSize:
                                                                          15.sp,
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.5),
                                                                    ),
                                                                    hintText:
                                                                        'Tìm kiếm...',
                                                                    prefixIcon:
                                                                        const Icon(
                                                                      Icons
                                                                          .search,
                                                                      size: 18,
                                                                    ),
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.r),
                                                                    ),
                                                                  ),
                                                                  onChanged:
                                                                      (value) {
                                                                    setModalState(
                                                                        () {
                                                                      filteredList =
                                                                          listServices
                                                                              .where((item) {
                                                                        return item
                                                                            .serviceName
                                                                            .toLowerCase()
                                                                            .contains(value.toLowerCase());
                                                                      }).toList();
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              // List of items
                                                              Expanded(
                                                                child: filteredList
                                                                        .isEmpty
                                                                    ? Center(
                                                                        child:
                                                                            TextApp(
                                                                        text:
                                                                            "Không tìm thấy kết quả",
                                                                        fontsize:
                                                                            18.sp,
                                                                        fontFamily:
                                                                            'OpenSans',
                                                                      ))
                                                                    : ListView
                                                                        .builder(
                                                                        padding:
                                                                            EdgeInsets.only(top: 10.h),
                                                                        itemCount:
                                                                            filteredList.length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          return Column(
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsets.only(left: 20.w),
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    Navigator.pop(context);
                                                                                    setState(() {
                                                                                      serviceTypeTextController.text = filteredList[index].serviceName;
                                                                                      onServicesChanged(filteredList[index].serviceId);
                                                                                    });
                                                                                  },
                                                                                  child: Row(
                                                                                    children: [
                                                                                      TextApp(
                                                                                        text: filteredList[index].serviceName,
                                                                                        fontsize: 20.sp,
                                                                                        color: Colors.black,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Divider(height: 25.h),
                                                                            ],
                                                                          );
                                                                        },
                                                                      ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(15.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    // width: 140.w,
                                    height: 40.h,
                                    child: ButtonApp(
                                      text: 'Xoá bộ lọc',
                                      fontsize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red,
                                      outlineColor: Colors.red,
                                      event: () {
                                        clearFliterFunction();
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  SizedBox(
                                    // width: 140.w,
                                    height: 40.h,
                                    child: ButtonApp(
                                      text: 'Áp dụng',
                                      fontsize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Colors.white,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      outlineColor:
                                          Theme.of(context).colorScheme.primary,
                                      event: () {
                                        applyFliterFunction();
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showFliter(context),
      child: Container(
          width: 35.w,
          height: 35.w,
          child: Image.asset(
            "assets/images/filter.png",
            fit: BoxFit.fill,
          )),
    );
  }
}
