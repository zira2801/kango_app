import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/debit/debit_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/list_shipment_bloc.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/area.dart';
import 'package:scan_barcode_app/data/models/audit_epacket/audit_epacket_service.dart';
import 'package:scan_barcode_app/data/models/debit/debit_detail.dart';
import 'package:scan_barcode_app/data/models/method_pay_character.dart/method_pay_character.dart';
import 'package:scan_barcode_app/data/models/sale_leader/shipment_fwd_model.dart';
import 'package:scan_barcode_app/data/models/shipment/all_unit_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/delivery_service.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_info_tab1_widget.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_info_tab2_widget.dart';
import 'package:scan_barcode_app/ui/screen/transfer_list/filter_transfer.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/html/html_screen.dart';
import 'package:scan_barcode_app/ui/widgets/image/full_image_view.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;

class DetailDebitScreen extends StatefulWidget {
  final String debitCode;
  const DetailDebitScreen({super.key, required this.debitCode});

  @override
  State<DetailDebitScreen> createState() => _DetailDebitScreenState();
}

class _DetailDebitScreenState extends State<DetailDebitScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    init();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cập nhật lại giao diện khi tab thay đổi
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void init() {
    BlocProvider.of<GetDetailDebitBloc>(context)
        .add(GetDetailDebit(debitCode: widget.debitCode));
  }

  @override
  Widget build(BuildContext context) {
    final String? position =
        StorageUtils.instance.getString(key: 'user_position');
    final String normalizedPosition = position!.trim().toLowerCase();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Xóa bóng của AppBar để giao diện phẳng hơn
        title: TextApp(
          text: 'DEBIT NO: ${widget.debitCode}',
          fontsize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.label,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              tabs: [
                Tab(
                  child: Center(
                    child: TextApp(
                      text: 'Thanh toán',
                      fontsize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: _tabController.index == 0
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black54,
                    ),
                  ),
                ),
                Tab(
                  child: TextApp(
                    text: 'Danh sách shipment',
                    fontsize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _tabController.index == 1
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black54,
                  ),
                ),
              ],
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                insets: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<GetDetailDebitBloc, GetDetailDebitState>(
        builder: (context, state) {
          if (state is GetDetailDebitloading) {
            return Center(
              child: SizedBox(
                width: 100.w,
                height: 100.w,
                child: Lottie.asset('assets/lottie/loading_kango.json'),
              ),
            );
          } else if (state is GetDetailDebitSuccess) {
            final debitDetail = state.debitDetailResponse;
            return TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                InfoPage(debitDetailResponse: debitDetail),
                ListShipmentDebitScreen(
                  debitID: debitDetail.debit?.debitId ??
                      0, // Pass user position as parameter
                  userPosition: normalizedPosition,
                  // Pass permissions as boolean flags
                  canUploadLabel: normalizedPosition != 'sale' &&
                      normalizedPosition != 'fwd' &&
                      normalizedPosition != 'ops-leader' &&
                      normalizedPosition != 'ops_pickup',
                  canUploadPayment: normalizedPosition != 'fwd',
                )
              ],
            );
          } else if (state is GetDetailDebitFailure) {
            return AlertDialog(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.w),
              ),
              actionsPadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.only(
                  top: 35.w, bottom: 30.w, left: 35.w, right: 35.w),
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
                      width: 250.w,
                      height: 250.w,
                      child: Lottie.asset('assets/lottie/error_dialog.json',
                          fit: BoxFit.contain),
                    ),
                  ),
                  TextApp(
                    text: state.message,
                    fontsize: 18.sp,
                    softWrap: true,
                    isOverFlow: false,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  // Container(
                  //   width: 150.w,
                  //   height: 50.h,
                  //   child: ButtonApp(
                  //     event: () {},
                  //     text: "Xác nhận",
                  //     fontsize: 14.sp,
                  //     colorText: Colors.white,
                  //     backgroundColor: Colors.black,
                  //     outlineColor: Colors.black,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            );
          }
          return NoDataFoundWidget();
        },
      ),
    );
  }
}

// Trang 1: Thông tin
class InfoPage extends StatefulWidget {
  final DebitDetailResponse debitDetailResponse;
  const InfoPage({super.key, required this.debitDetailResponse});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final formatter = NumberFormat("#,###", "vi_VN");
  final TextEditingController _noteController = TextEditingController();
  String? _paymentMethod = 'bank';
  List<File> _selectedImages = []; // Thay File? thành List<File>
  final ImagePicker _picker = ImagePicker();

// Chọn nhiều ảnh từ gallery
  Future<void> _pickImage() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

// Xóa ảnh khỏi danh sách
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Chuyển danh sách ảnh thành danh sách base64
  Future<List<String>> _convertImagesToBase64(List<File> images) async {
    List<String> base64Images = [];
    for (var image in images) {
      try {
        final bytes = await image.readAsBytes();
        base64Images.add(base64Encode(bytes));
      } catch (e) {
        print("Error converting image to base64: $e");
      }
    }
    return base64Images;
  }

  Future<void> _handlePayment() async {
    if (_paymentMethod == null) {
      showCustomDialogModal(
        context: context,
        textDesc: "Vui lòng chọn phương thức thanh toán.",
        title: "Thông báo",
        colorButtonOk: Colors.red,
        btnOKText: "Xác nhận",
        typeDialog: "error",
        eventButtonOKPress: () {},
        isTwoButton: false,
      );
      return;
    }

    final List<String> base64Images =
        await _convertImagesToBase64(_selectedImages);

    int debitPaymentMethod;
    double bankAmount = 0;
    double cashAmount = 0;
    final double totalPrice =
        widget.debitDetailResponse.debit?.totalPrice?.toDouble() ?? 0;

    switch (_paymentMethod) {
      case 'bank':
        debitPaymentMethod = 1;
        bankAmount = totalPrice;
        cashAmount = 0;
        break;
      case 'cash':
        debitPaymentMethod = 2;
        bankAmount = 0;
        cashAmount = totalPrice;
        break;
      case 'cash_and_bank':
        debitPaymentMethod = 3;
        bankAmount = totalPrice / 2;
        cashAmount = totalPrice / 2;
        break;
      default:
        debitPaymentMethod = 0;
    }

    BlocProvider.of<PaymentDebitBloc>(context).add(
      OnHandlePaymentDebit(
        debitNo: widget.debitDetailResponse.debit?.debitNo ?? '',
        debitNote:
            _noteController.text.isNotEmpty ? _noteController.text : null,
        debitPaymentMethod: debitPaymentMethod,
        debitPaymentAmount: totalPrice,
        bankAmount: bankAmount,
        cashAmount: cashAmount,
        debitsImages: base64Images, // Gửi danh sách base64
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentDebitBloc, PaymentDebitState>(
          listener: (context, state) {
            if (state is PaymentDebitStateSuccess) {
              // setState(() {
              //   _isLoading = false;
              // });

              showCustomDialogModal(
                  context: context,
                  textDesc: state.message,
                  title: "Thông báo",
                  colorButtonOk: Colors.green,
                  btnOKText: "Xác nhận",
                  typeDialog: "success",
                  eventButtonOKPress: () {
                    setState(() {
                      _selectedImages.clear();
                      _noteController.clear();
                    });
                    BlocProvider.of<GetDetailDebitBloc>(context).add(
                        GetDetailDebit(
                            debitCode: widget.debitDetailResponse.debit!.debitNo
                                .toString()));

                    BlocProvider.of<GetListDebitBloc>(context).add(
                        const FetchListDebit(
                            keywords: null,
                            startDate: null,
                            endDate: null,
                            debitStatus: null));
                  },
                  isTwoButton: false);
            } else if (state is PaymentDebitStateFailure) {
              // setState(() {
              //   _isLoading = false;
              // });
              showCustomDialogModal(
                  context: context,
                  textDesc: state.message,
                  title: "Thông báo",
                  colorButtonOk: Colors.red,
                  btnOKText: "Xác nhận",
                  typeDialog: "error",
                  eventButtonOKPress: () {},
                  isTwoButton: false);
            }
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                margin: const EdgeInsets.all(10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: TextApp(
                        text: 'Thông tin thanh toán',
                        fontsize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: HtmlViewer(
                        htmlData: widget.debitDetailResponse.content.toString(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.white,
                margin: const EdgeInsets.all(10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: TextApp(
                        text: 'Thanh toán',
                        fontsize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "THÔNG TIN DEBIT",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: "Icomoon",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Divider(
                                  height: 1,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                TextApp(
                                  text: "Mã khách hàng: ",
                                  fontsize: 16.sp,
                                ),
                                TextApp(
                                  text: widget
                                      .debitDetailResponse.userDebit!.userCode
                                      .toString(),
                                  fontsize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                TextApp(
                                  text: "Tổng đơn: ",
                                  fontsize: 16.sp,
                                ),
                                TextApp(
                                  text: widget
                                      .debitDetailResponse.debit!.totalSm
                                      .toString(),
                                  fontsize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                TextApp(
                                  text: "Tổng tiền: ",
                                  fontsize: 16.sp,
                                ),
                                TextApp(
                                  text: formatter.format(widget
                                          .debitDetailResponse
                                          .debit
                                          ?.totalPrice ??
                                      0),
                                  fontsize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                TextApp(
                                  text: "VAT: ",
                                  fontsize: 16,
                                ),
                                TextApp(
                                  text: formatter.format(widget
                                          .debitDetailResponse
                                          .debit
                                          ?.totalVat ??
                                      0),
                                  fontsize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                "TRẠNG THÁI",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: "Icomoon",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(width: 10.h),
                              Expanded(
                                child: Divider(
                                  height: 1,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          // Thay toàn bộ phần "Bằng chứng" trong build bằng code sau:
                          SizedBox(height: 20.h),
                          widget.debitDetailResponse.debit?.debitStatus == 1
                              ? Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.w),
                                          color: const Color.fromRGBO(
                                              235, 252, 245, 1)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  Icons.check_circle_outline,
                                                  color: Color.fromRGBO(
                                                      10, 216, 132, 1),
                                                  size: 20,
                                                ),
                                                TextApp(
                                                  color: const Color.fromRGBO(
                                                      8, 201, 120, 1),
                                                  text: " Đã thanh toán",
                                                  fontsize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8.h,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                TextApp(
                                                  color: const Color.fromRGBO(
                                                      8, 201, 120, 1),
                                                  text: "Số tiền thanh toán: ",
                                                  fontsize: 15.sp,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                                TextApp(
                                                  color: const Color.fromRGBO(
                                                      8, 201, 120, 1),
                                                  text: formatter.format(widget
                                                          .debitDetailResponse
                                                          .debit
                                                          ?.totalPrice ??
                                                      0),
                                                  fontsize: 15.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8.h,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                TextApp(
                                                  color: const Color.fromRGBO(
                                                      8, 201, 120, 1),
                                                  text: "Phương thức: ",
                                                  fontsize: 15.sp,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                                TextApp(
                                                  color: const Color.fromRGBO(
                                                      8, 201, 120, 1),
                                                  text: widget
                                                          .debitDetailResponse
                                                          .debit
                                                          ?.methodLabel
                                                          .toString() ??
                                                      '',
                                                  fontsize: 15.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8.h,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                TextApp(
                                                  color: const Color.fromRGBO(
                                                      8, 201, 120, 1),
                                                  text: "Time payment: ",
                                                  fontsize: 15.sp,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                                TextApp(
                                                  color: const Color.fromRGBO(
                                                      8, 201, 120, 1),
                                                  text: formatDateTime(widget
                                                          .debitDetailResponse
                                                          .debit
                                                          ?.createdAt
                                                          .toString() ??
                                                      ''),
                                                  fontsize: 15.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8.h,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                TextApp(
                                                  color: const Color.fromRGBO(
                                                      8, 201, 120, 1),
                                                  text: "Ghi chú: ",
                                                  fontsize: 15.sp,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                                TextApp(
                                                  color: const Color.fromRGBO(
                                                      8, 201, 120, 1),
                                                  text: widget
                                                          .debitDetailResponse
                                                          .debit
                                                          ?.debitNote ??
                                                      '',
                                                  fontsize: 15.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    ButtonApp(
                                      icon: Icons.remove_red_eye_sharp,
                                      iconSize: 18.sp,
                                      text: 'Hiển thị',
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      outlineColor:
                                          Theme.of(context).colorScheme.primary,
                                      event: () async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.w),
                                              ),
                                              actionsPadding: EdgeInsets.zero,
                                              contentPadding:
                                                  EdgeInsets.all(10.w),
                                              titlePadding:
                                                  EdgeInsets.all(15.w),
                                              surfaceTintColor: Colors.white,
                                              backgroundColor: Colors.white,
                                              title: TextApp(
                                                text:
                                                    'Bằng chứng thanh toán (Hình ảnh)',
                                                fontsize: 20.sp,
                                              ),
                                              content: SizedBox(
                                                width: double.maxFinite,
                                                height: 400,
                                                child: widget
                                                                .debitDetailResponse
                                                                .debit!
                                                                .debitImages ==
                                                            null ||
                                                        widget
                                                            .debitDetailResponse
                                                            .debit!
                                                            .debitImages!
                                                            .isEmpty
                                                    ? Center(
                                                        child: TextApp(
                                                          text:
                                                              'Không có ảnh để hiển thị',
                                                          fontsize: 18.sp,
                                                        ),
                                                      )
                                                    : GridView.builder(
                                                        gridDelegate:
                                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount:
                                                              2, // 2 ảnh mỗi hàng
                                                          crossAxisSpacing: 8.0,
                                                          mainAxisSpacing: 8.0,
                                                          childAspectRatio:
                                                              1, // Tỷ lệ 1:1 cho ảnh
                                                        ),
                                                        itemCount: widget
                                                            .debitDetailResponse
                                                            .debit
                                                            ?.debitImages!
                                                            .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final imageUrl = httpImage +
                                                              widget
                                                                  .debitDetailResponse
                                                                  .debit!
                                                                  .debitImages![index];
                                                          return GestureDetector(
                                                            onTap: () {
                                                              // Mở trang toàn màn hình để phóng to ảnh
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          FullScreenImageView(
                                                                    imageUrl:
                                                                        imageUrl,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  imageUrl,
                                                              fit: BoxFit.cover,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  const Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Center(
                                                                child: Icon(
                                                                    Icons.error,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: TextApp(
                                                    text: 'Đóng',
                                                    fontWeight: FontWeight.bold,
                                                    fontsize: 16.sp,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : widget.debitDetailResponse.debit?.debitStatus !=
                                      3
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: 'Bằng chứng',
                                          fontsize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        SizedBox(height: 8.h),
                                        Container(
                                          width: double.infinity,
                                          height:
                                              250, // Tăng chiều cao để chứa danh sách ảnh cuộn dọc
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Stack(
                                            children: [
                                              // Phần trống để chọn ảnh
                                              if (_selectedImages.isEmpty)
                                                GestureDetector(
                                                  onTap: _pickImage,
                                                  child: Center(
                                                    child: TextApp(
                                                      text:
                                                          'Tải ảnh lên (Chọn nhiều ảnh)',
                                                      fontsize: 14.sp,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                )
                                              else
                                                Positioned.fill(
                                                  child: GestureDetector(
                                                    onTap:
                                                        _pickImage, // Chỉ bật chọn ảnh khi chạm vào phần trống
                                                    child: Container(
                                                      color: Colors
                                                          .transparent, // Phần trống trong suốt
                                                    ),
                                                  ),
                                                ),
                                              // Danh sách ảnh cuộn dọc
                                              if (_selectedImages.isNotEmpty)
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,

                                                  // Cuộn dọc
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: _selectedImages
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      int index = entry.key;
                                                      File image = entry.value;
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Stack(
                                                          children: [
                                                            Container(
                                                              width: 130.w,
                                                              height: 130.h,
                                                              child: Image.file(
                                                                image,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              right: 0,
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () =>
                                                                    _removeImage(
                                                                        index),
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          2),
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 16,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextApp(
                                          text: 'Chú thích',
                                          fontsize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        SizedBox(height: 8.h),
                                        TextField(
                                          controller: _noteController,
                                          style: TextStyle(
                                              fontFamily: 'OpenSans',
                                              fontSize: 15.sp),
                                          decoration: InputDecoration(
                                            hintText: 'Nhập chú thích',
                                            hintStyle: TextStyle(
                                                fontFamily: 'OpenSans',
                                                fontSize: 15.sp),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          maxLines: 3,
                                        ),
                                        SizedBox(height: 16.h),
                                        TextApp(
                                          text: 'Phương thức thanh toán',
                                          fontsize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        SizedBox(height: 8.h),
                                        Column(
                                          children: [
                                            RadioListTile<String>(
                                              title: TextApp(
                                                text: 'Ngân hàng',
                                                fontsize: 15.sp,
                                              ),
                                              value: 'bank',
                                              groupValue: _paymentMethod,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  _paymentMethod = value;
                                                });
                                              },
                                            ),
                                            RadioListTile<String>(
                                              title: TextApp(
                                                text: 'Tiền mặt',
                                                fontsize: 15.sp,
                                              ),
                                              value: 'cash',
                                              groupValue: _paymentMethod,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  _paymentMethod = value;
                                                });
                                              },
                                            ),
                                            RadioListTile<String>(
                                              title: TextApp(
                                                text: 'Tiền mặt & Ngân hàng',
                                                fontsize: 15.sp,
                                              ),
                                              value: 'cash_and_bank',
                                              groupValue: _paymentMethod,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  _paymentMethod = value;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16.h),
                                        ElevatedButton(
                                          onPressed: () {
                                            showCustomDialogModal(
                                                context: context,
                                                textDesc:
                                                    "Bạn có chắc muốn thanh toán Debit này ?",
                                                title: "Thông báo",
                                                colorButtonOk: Colors.blue,
                                                btnOKText: "Xác nhận",
                                                typeDialog: "question",
                                                eventButtonOKPress: () {
                                                  _handlePayment;
                                                },
                                                isTwoButton: true);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16, horizontal: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: TextApp(
                                            text: 'Thanh Toán',
                                            color: Colors.white,
                                            fontsize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 150.h,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.w),
                                              color: const Color.fromRGBO(
                                                  255, 250, 235, 1)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: Color.fromRGBO(
                                                          207, 162, 14, 1),
                                                      size: 20,
                                                    ),
                                                    TextApp(
                                                      color:
                                                          const Color.fromRGBO(
                                                              207, 162, 14, 1),
                                                      text:
                                                          " Đã gửi bằng chứng thanh toán chờ duyệt lệnh!",
                                                      fontsize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 8.h,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    TextApp(
                                                      color:
                                                          const Color.fromRGBO(
                                                              207, 162, 14, 1),
                                                      text: "Phương thức: ",
                                                      fontsize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                    TextApp(
                                                      color:
                                                          const Color.fromRGBO(
                                                              207, 162, 14, 1),
                                                      text: widget
                                                              .debitDetailResponse
                                                              .debit
                                                              ?.methodLabel
                                                              .toString() ??
                                                          '',
                                                      fontsize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 8.h,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    TextApp(
                                                      color:
                                                          const Color.fromRGBO(
                                                              207, 162, 14, 1),
                                                      text: "Time payment: ",
                                                      fontsize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                    TextApp(
                                                      color:
                                                          const Color.fromRGBO(
                                                              207, 162, 14, 1),
                                                      text: formatDateTime(widget
                                                              .debitDetailResponse
                                                              .debit
                                                              ?.createdAt
                                                              .toString() ??
                                                          ''),
                                                      fontsize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        ButtonApp(
                                          icon: Icons.remove_red_eye_sharp,
                                          iconSize: 18.sp,
                                          text: 'Hiển thị',
                                          fontsize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          colorText: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          outlineColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          event: () async {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  clipBehavior: Clip
                                                      .antiAliasWithSaveLayer,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.w),
                                                  ),
                                                  actionsPadding:
                                                      EdgeInsets.zero,
                                                  contentPadding:
                                                      EdgeInsets.all(10.w),
                                                  titlePadding:
                                                      EdgeInsets.all(15.w),
                                                  surfaceTintColor:
                                                      Colors.white,
                                                  backgroundColor: Colors.white,
                                                  title: TextApp(
                                                    text:
                                                        'Bằng chứng thanh toán (Hình ảnh)',
                                                    fontsize: 20.sp,
                                                  ),
                                                  content: SizedBox(
                                                    width: double.maxFinite,
                                                    height: 400,
                                                    child: widget
                                                                    .debitDetailResponse
                                                                    .debit!
                                                                    .debitImages ==
                                                                null ||
                                                            widget
                                                                .debitDetailResponse
                                                                .debit!
                                                                .debitImages!
                                                                .isEmpty
                                                        ? Center(
                                                            child: TextApp(
                                                              text:
                                                                  'Không có ảnh để hiển thị',
                                                              fontsize: 18.sp,
                                                            ),
                                                          )
                                                        : GridView.builder(
                                                            gridDelegate:
                                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount:
                                                                  2, // 2 ảnh mỗi hàng
                                                              crossAxisSpacing:
                                                                  8.0,
                                                              mainAxisSpacing:
                                                                  8.0,
                                                              childAspectRatio:
                                                                  1, // Tỷ lệ 1:1 cho ảnh
                                                            ),
                                                            itemCount: widget
                                                                .debitDetailResponse
                                                                .debit
                                                                ?.debitImages!
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              final imageUrl =
                                                                  httpImage +
                                                                      widget
                                                                          .debitDetailResponse
                                                                          .debit!
                                                                          .debitImages![index];
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  // Mở trang toàn màn hình để phóng to ảnh
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              FullScreenImageView(
                                                                        imageUrl:
                                                                            imageUrl,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      imageUrl,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      const Center(
                                                                    child:
                                                                        CircularProgressIndicator(),
                                                                  ),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const Center(
                                                                    child: Icon(
                                                                        Icons
                                                                            .error,
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: TextApp(
                                                        text: 'Đóng',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontsize: 16.sp,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Card(
                color: Colors.white,
                margin: const EdgeInsets.all(16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: TextApp(
                        text: 'Tạm ứng',
                        fontsize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      height: 20.h,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

// Trang 2: Danh sách Shipment
class ListShipmentDebitScreen extends StatefulWidget {
  final String? userPosition;
  final bool? canUploadLabel;
  final bool? canUploadPayment;
  final int debitID;
  const ListShipmentDebitScreen(
      {super.key,
      this.userPosition,
      this.canUploadLabel,
      this.canUploadPayment,
      required this.debitID});

  @override
  State<ListShipmentDebitScreen> createState() =>
      _ListShipmentDebitScreenState();
}

class _ListShipmentDebitScreenState extends State<ListShipmentDebitScreen>
    with SingleTickerProviderStateMixin {
  List<ExpansionTileController> expansionTileControllers = [];
  final scrollListShipmentFWDController = ScrollController();
  final textSearchController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  final serviceTextController = TextEditingController();
  bool isMoreDetailShipment = false;
  int? serviceID;
  String query = '';
  final formatter = NumberFormat("#,###", "vi_VN");

  AreaModel? areaModel;
  List<IconData> iconStatus = [
    Icons.all_inbox,
    Icons.add,
    Icons.create,
    Icons.outbond,
    Icons.refresh
  ];

  DetailsShipmentModel? detailsShipment;

  DeliveryServiceModel? deliveryServiceMode;
  AllUnitShipmentModel? allUnitShipmentModel;
  AuditEpacketService? servicesAuditEpacket;
  List<String> listStatus = [
    "Create Bill",
    "Imported",
    "Exported",
    "Returned",
    "Hold"
  ];
  List<String> listKeyType = [
    "shipment_code",
    "shipment_reference_code",
    "receiver_contact_name",
    "sender_company_name",
    "receiver_address_1",
    "package_code",
    "package_tracking_code"
  ];
  String searchMethod = 'Mã shipment';
  String currentSearchMethod = "shipment_code";
  DateTime? _startDate; //type ngày bắt đầu
  DateTime? _endDate; //type ngày kết thúc
  String? _endDateError; //text lỗi khi ngày kết thúc nhỏ hơn ngày bắt đầu
  int? branchID;
  BranchResponse? branchResponse;
  File? selectedImage;
  bool hasMore = false;
  final ImagePicker picker = ImagePicker();
  MethodPayCharater? _methodPay = MethodPayCharater.bank;
  String? selectedFile;
  late TabController _tabController;

  List countryFlagList = [];
  List countryListReciver = [];
  List stateListReciver = [];
  List cityListReciver = [];

  List<int>? countryIDList = [];
  List<int>? stateIDList = [];
  List<int>? cityIDList = [];

  void getDetailsShipment(
      {required String? shipmentCode, required bool isMoreDetail}) {
    context.read<DetailsShipmentBloc>().add(
          HanldeDetailsShipment(
              shipmentCode: shipmentCode, isMoreDetail: isMoreDetail),
        );
  }

  void showDialogDetailsShipment({required String shipmentCode}) {
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
            maxChildSize: 0.8,
            initialChildSize: 0.8,
            expand: false,
            builder: (BuildContext context,
                ScrollController scrollControllerMoreInfor) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(
                              child: TextApp(
                                text: 'Thông tin lô hàng',
                                fontsize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                            Tab(
                              child: TextApp(
                                text: 'Thông tin kiện hàng',
                                fontsize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              PackageInfoWidgetTab1(
                                shipmentCode: shipmentCode,
                                scrollController: scrollControllerMoreInfor,
                                detailsShipment: detailsShipment,
                                selectedPDFLabelString: selectedFile,
                                selectedImage: selectedImage,
                                methodPay: _methodPay,
                                userPosition: widget.userPosition,
                                canUploadLabel: widget.canUploadLabel,
                                canUploadPayment: widget.canUploadPayment,
                              ),
                              PackageInfoWidgetTab2(
                                scrollController: scrollControllerMoreInfor,
                                detailsShipment: detailsShipment,
                                allUnitShipmentModel: allUnitShipmentModel,
                              )
                            ],
                          ),
                        ),
                      ],
                    ));
              });
            },
          );
        });
  }

  String getCountryName(int? countryId) {
    if (areaModel == null ||
        areaModel!.areas.countries.isEmpty ||
        countryId == null) {
      return 'Không xác định';
    }
    try {
      final country = areaModel!.areas.countries.firstWhere(
        (country) => country.countryId == countryId,
      );
      return country.countryName;
    } catch (e) {
      return 'Không xác định';
    }
  }

  String getServiceName(int? serviceId) {
    if (servicesAuditEpacket == null ||
        servicesAuditEpacket!.services.isEmpty ||
        serviceId == null) {
      return 'Không xác định';
    }
    try {
      final service = servicesAuditEpacket!.services.firstWhere(
        (service) => service.id == serviceId,
      );
      return service.serviceName;
    } catch (e) {
      return 'Không xác định';
    }
  }

//Lấy danh sách dịch vụ
  Future<void> getAllServicePackageManager() async {
    final response = await http.get(
      Uri.parse('$baseUrl$getListServicePackageManager'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        log("getAllServiceAuditEpacket OK");
        mounted
            ? setState(() {
                servicesAuditEpacket = AuditEpacketService.fromJson(data);
              })
            : null;
      } else {
        log("getAllServicePackageManager error 1");
      }
    } catch (error) {
      log("getAllServicePackageManager error $error 2");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              eventConfirm: () {
                Navigator.pop(context);
              },
            );
          });
    }
  }

  String _getPositionName(int positionID) {
    const statusMap = {
      1: 'ADMIN',
      2: 'Kế toán',
      3: 'OPS/Pickup',
      4: 'Sale',
      5: 'Fwd',
      7: 'Chứng từ',
      8: 'OPS trưởng',
      9: 'Tài xế'
    };
    return statusMap[positionID] ?? 'Unknown';
  }

  Color _getPositionColor(int positionID) {
    const statusMap = {
      1: Colors.black,
      // 2: 'Kế toán',
      // 3: 'OPS/Pickup',
      4: Color.fromRGBO(0, 214, 127, 1),
      5: Color.fromRGBO(24, 221, 239, 1),
      // 7: 'Chứng từ',
      // 8: 'OPS trưởng',
      // 9: 'Tài xế'
    };
    return statusMap[positionID] ?? const Color.fromRGBO(24, 221, 239, 1);
  }

  String _getStatusName(int statusID) {
    const statusMap = {
      0: 'Create Bill',
      1: 'Imported',
      2: 'Exported',
      3: 'Returned',
      4: 'Hold',
    };
    return statusMap[statusID] ?? 'Unknown';
  }

  Color _getStatusColor(int statusID) {
    const statusMap = {
      0: Colors.grey,
      1: Color.fromRGBO(24, 221, 239, 1),
      2: Color.fromRGBO(0, 214, 127, 1),
      3: Colors.red,
      4: Colors.red,
    };
    return statusMap[statusID] ?? Colors.grey;
  }

  Future<void> showDialogMoreDetailShipment({
    required DetailsShipmentModel shipmentdetail,
  }) async {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.8,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  // Header
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: TextApp(
                      text: 'Thông tin thêm',
                      fontsize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thông tin tài chính
                          _buildInfoCard(
                            title: 'Tổng đơn',
                            value: formatter.format(
                                shipmentdetail.shipment.shipmentFinalAmount ??
                                    0),
                            icon: Icons.monetization_on_rounded,
                          ),
                          _buildInfoCard(
                            title: 'Số kiện',
                            value: shipmentdetail.shipment.packages.length
                                .toString(), // Tổng số package
                            icon: Icons.inventory_rounded,
                          ),
                          _buildInfoCard(
                            title: 'Charge Weight',
                            value:
                                "${shipmentdetail.shipment.packages.first.packageChargedWeight ?? 0} kg",
                            icon: Icons.scale_rounded,
                          ),
                          _buildInfoCard(
                            title: 'Thu khách',
                            value: formatter.format(
                                shipmentdetail.shipment.shipmentFinalAmount ??
                                    0),
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                          _buildInfoCard(
                            title: 'Lợi nhuận',
                            value: formatter.format(
                                shipmentdetail.shipment.shipmentAmountProfit ??
                                    0),
                            icon: Icons.trending_up_rounded,
                            textColor:
                                shipmentdetail.shipment.shipmentAmountProfit > 0
                                    ? Colors.green
                                    : Colors.red,
                          ),
                          _buildInfoCard(
                            title: 'Phụ thu',
                            value: formatter.format(shipmentdetail
                                    .shipment.shipmentAmountSurcharge ??
                                0),
                            icon: Icons.add_circle_outline_rounded,
                          ),
                          _buildInfoCard(
                            title: 'Bảo hiểm',
                            value: formatter.format(shipmentdetail
                                    .shipment.shipmentAmountInsurance ??
                                0),
                            icon: Icons.security_rounded,
                          ),
                          _buildInfoCard(
                            title: 'Cước gốc',
                            value: formatter.format(
                                shipmentdetail.shipment.shipmentAmountService ??
                                    0),
                            icon: Icons.local_shipping_rounded,
                          ),
                          _buildInfoCard(
                            title: 'Nội địa',
                            value: formatter.format(shipmentdetail
                                    .shipment.shipmentDomesticCharges ??
                                0),
                            icon: Icons.home_rounded,
                          ),
                          _buildInfoCard(
                            title: 'VAT',
                            value: formatter.format(
                                shipmentdetail.shipment.shipmentAmountVat ?? 0),
                            icon: Icons.receipt_rounded,
                          ),
                          _buildInfoCard(
                            title: 'Thu hộ',
                            value: formatter.format(
                                shipmentdetail.shipment.shipmentCollectionFee ??
                                    0),
                            icon: Icons.handshake_rounded,
                          ),
                          _buildInfoCard(
                            title: 'CPVH',
                            value: formatter.format(shipmentdetail
                                    .shipment.shipmentAmountOperatingCosts ??
                                0),
                            icon: Icons.build_rounded,
                          ),

                          // Packages với trạng thái riêng
                          SizedBox(height: 16.h),
                          _buildSectionTitle('Packages'),
                          ...shipmentdetail.shipment.packages.map((package) {
                            return _buildPackageCard(
                              packageCode: package.packageCode,
                              weight:
                                  "${formatter.format(package.packageWeight ?? 0)} kg",
                              status: _getStatusName(shipmentdetail.shipment
                                  .shipmentStatus), // Giả sử trạng thái từ shipment áp dụng cho package
                              statusColor: _getStatusColor(
                                  shipmentdetail.shipment.shipmentStatus),
                              statusIcon: _getStatusIcon(
                                  shipmentdetail.shipment.shipmentStatus),
                            );
                          }).toList(),

                          // Trạng thái chung và thanh toán
                          SizedBox(height: 16.h),
                          _buildSectionTitle('Trạng thái chung'),
                          _buildStatusCard(
                            title: 'Thanh toán',
                            value:
                                shipmentdetail.shipment.shipmentPaymentStatus ==
                                        0
                                    ? 'Chưa thanh toán'
                                    : 'Đã thanh toán',
                            color:
                                shipmentdetail.shipment.shipmentPaymentStatus ==
                                        0
                                    ? Colors.red
                                    : const Color.fromRGBO(0, 214, 127, 1),
                            icon: Icons.payment_rounded,
                          ),

                          // Mô tả hàng hóa
                          SizedBox(height: 16.h),
                          _buildInfoCard(
                            title: 'Description of Goods',
                            value: shipmentdetail.shipment.packages.first
                                    .packageDescription ??
                                'Không có',
                            icon: Icons.description_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Helper Widgets
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: TextApp(
        text: title,
        fontsize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700] ?? Colors.grey,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon,
                size: 20.sp, color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: title,
                  fontsize: 14.sp,
                  color: Colors.grey[600] ?? Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 4.h),
                TextApp(
                  text: value,
                  fontsize: 16.sp,
                  color: textColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required String packageCode,
    required String weight,
    required String status,
    required Color statusColor,
    required IconData statusIcon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.local_shipping_rounded,
                    size: 20.sp, color: Theme.of(context).colorScheme.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextApp(
                      text: packageCode,
                      fontsize: 15.sp,
                      color: Colors.grey[600] ?? Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(width: 4.h),
                    TextApp(
                      text: "-",
                      fontsize: 15.sp,
                      color: Colors.grey[600] ?? Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(width: 4.h),
                    TextApp(
                      text: weight,
                      fontsize: 15.sp,
                      color: Colors.grey[600] ?? Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(statusIcon, size: 20.sp, color: statusColor),
              ),
              SizedBox(width: 8.w),
              TextApp(
                text: status,
                fontsize: 14.sp,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextApp(
                  text: title,
                  fontsize: 14.sp,
                  color: Colors.grey[600] ?? Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 4.h),
                TextApp(
                  text: value,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.circle_notifications;
      case 1:
        return Icons.check_circle_rounded;
      case 2:
        return Icons.outbound_rounded;
      default:
        return Icons.history;
    }
  }

  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      branchResponse = BranchResponse.fromJson(jsonDecode(branchResponseJson));
      log("GET BRANCH OK LIST");
    }
  }

  void init() async {
    BlocProvider.of<GetListDebitShipmentBloc>(context)
        .add(FetchListShipmentDebit(keywords: query, debitID: widget.debitID));
    getBranchKango();
    handleGetAreaGobal(countryID: null, stateID: null);
    getAllServicePackageManager();
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _slidableController = SlidableController(vsync: this);
    init();
    for (int i = 0; i < 5; i++) {
      expansionTileControllers.add(ExpansionTileController());
    }
    scrollListShipmentFWDController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollListShipmentFWDController.position.maxScrollExtent ==
        scrollListShipmentFWDController.offset) {
      BlocProvider.of<GetListDebitShipmentBloc>(context)
          .add(FetchListShipmentDebit(
        keywords: query,
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    textSearchController.clear();
    serviceTextController.clear();
    _dateStartController.clear();
    _dateEndController.clear();
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;

            BlocProvider.of<GetListDebitShipmentBloc>(context).add(
                FetchListShipmentDebit(
                    keywords: query, debitID: widget.debitID));
          })
        : null;
  }

  Future<void> applyFilterFuntion() async {
    // Kiểm tra nếu một trong hai ngày bị thiếu
    if ((_startDate != null && _endDate == null) ||
        (_startDate == null && _endDate != null)) {
      showCustomDialogModal(
        context: context,
        textDesc: "Vui lòng chọn cả ngày bắt đầu và ngày kết thúc.",
        title: "Thông báo",
        colorButtonOk: Colors.red,
        btnOKText: "Xác nhận",
        typeDialog: "error",
        eventButtonOKPress: () {},
        isTwoButton: false,
      );
      return; // Dừng hàm nếu không đủ điều kiện
    }

    log(_startDate.toString());
    log(_endDate.toString());
    Navigator.pop(context);

    BlocProvider.of<GetListDebitShipmentBloc>(context)
        .add(FetchListShipmentDebit(keywords: query, debitID: widget.debitID));
  }

  Future<void> clearFilterFuntion() async {
    setState(() {
      _endDateError = null;
      _dateStartController.clear();
      _dateEndController.clear();
      _startDate = null;
      _endDate = null;
      branchID = null;
    });
    Navigator.pop(context);
    BlocProvider.of<GetListDebitShipmentBloc>(context)
        .add(FetchListShipmentDebit(keywords: query, debitID: widget.debitID));
  }

  /// This builds cupertion date picker in iOS
  void buildCupertinoDateStartPicker(BuildContext context) {
    // Lưu lại giá trị ban đầu của controller
    String originalControllerText = _dateStartController.text;
    DateTime? originalStartDate = _startDate;

    showCupertinoDatePicker(
      context,
      initialDate: _startDate,
      onDateChanged: (picked) {
        setState(() {
          _startDate = picked;
        });
      },
      onCancel: () {
        // Khôi phục lại giá trị ban đầu
        setState(() {
          _startDate = originalStartDate;
          _dateStartController.text = originalControllerText;
        });
        Navigator.of(context).pop();
      },
      onConfirm: () {
        setState(() {
          _dateStartController.text = formatDateMonthYear(
              (_startDate ?? DateTime.now()).toString().split(" ")[0]);
          _endDateError = null;
          Navigator.of(context).pop();
        });
      },
    );
  }

  void buildCupertinoDateEndPicker(BuildContext context) {
    DateTime? originalEndDate = _endDate; // Store the original date

    showCupertinoDatePicker(
      context,
      initialDate: _endDate,
      onDateChanged: (picked) {
        setState(() {
          _endDate = picked;
        });
      },
      onCancel: () {
        // Restore the original date and clear the text field
        setState(() {
          _endDate = originalEndDate;
          _dateEndController.clear();
        });
        Navigator.of(context).pop();
      },
      onConfirm: () {
        if ((_endDate ?? DateTime.now())
            .isBefore(_startDate ?? DateTime.now())) {
          showCustomDialogModal(
              context: context,
              textDesc: "Nhỏ hơn ngày bắt đầu",
              title: "Thông báo",
              colorButtonOk: Colors.red,
              btnOKText: "Xác nhận",
              typeDialog: "error",
              eventButtonOKPress: () {},
              isTwoButton: false);
        } else {
          setState(() {
            _dateEndController.text = formatDateMonthYear(
                (_endDate ?? DateTime.now()).toString().split(" ")[0]);
            _endDateError = null;
            Navigator.of(context).pop();
          });
        }
      },
    );
  }

  /// This builds material date picker in Android
  Future<void> buildMaterialDateStartPicker(BuildContext context) async {
    // Lưu lại giá trị ban đầu của controller
    String originalControllerText = _dateStartController.text;
    DateTime? originalStartDate = _startDate;

    await showMaterialDatePicker(
      context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
      onDatePicked: (picked) {
        setState(() {
          _startDate = picked;
          _dateStartController.text = formatDateMonthYear(
              (_startDate ?? DateTime.now()).toString().split(" ")[0]);
          _endDateError = null;
        });
      },
      onCancel: () {
        // Nếu đã có giá trị ban đầu, khôi phục lại giá trị đó
        setState(() {
          _startDate = originalStartDate;
          _dateStartController.text = originalControllerText;
        });
      },
    );
  }

  Future<void> buildMaterialDateEndPicker(BuildContext context) async {
    // Lưu lại giá trị ban đầu của controller
    String originalControllerText = _dateEndController.text;
    DateTime? originalEndDate = _endDate;

    await showMaterialDatePicker(
      context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
      onDatePicked: (picked) {
        setState(() {
          _endDate = picked;
          _dateEndController.text = formatDateMonthYear(
              (_endDate ?? DateTime.now()).toString().split(" ")[0]);
          _endDateError = null;
        });
      },
      onCancel: () {
        // Nếu đã có giá trị ban đầu, khôi phục lại giá trị đó
        setState(() {
          _endDate = originalEndDate;
          _dateEndController.text = originalControllerText;
        });
      },
    );
  }

  Future<void> selectDayStart() async {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDateStartPicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDateStartPicker(context);
      // return buildMaterialDateStartPicker(context);
    }
  }

  Future<void> selectDayEnd() async {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDateEndPicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDateEndPicker(context);
      // return buildMaterialDateEndPicker(context);
    }
  }

  String _getNameBranch(int brandId) {
    final branch = branchResponse?.branchs.firstWhere(
      (branch) => branch.branchId == brandId,
    );
    if (branch != null) {
      return branch.branchName;
    } else {
      throw Exception('Branch not found');
    }
  }

  Future<void> handleGetAreaGobal({
    required int? countryID,
    required int? stateID,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$getAreaApi'),
      headers: ApiUtils.getHeaders(),
      body: jsonEncode({
        'country_id': countryID,
        'state_id': stateID,
      }),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        mounted
            ? setState(() {
                countryListReciver.clear();
                stateListReciver.clear();
                cityListReciver.clear();
                areaModel = AreaModel.fromJson(data);
                var countryDataRes = AreaModel.fromJson(data);
                countryListReciver = countryDataRes.areas.countries
                    .map((country) => country.countryName)
                    .toList(); //get Name Country and add to countryList
                countryFlagList = countryDataRes.areas.countries
                    .map((country) => country.countryCode)
                    .toList(); //get code Country and add to countryFlag to render flag
                // wardList.clear();
                countryIDList = countryDataRes.areas.countries
                    .map((country) => country.countryId)
                    .toList(); //get ID Country and add to countryIDList

                stateListReciver = countryDataRes.areas.states
                    .map((state) => state.stateName)
                    .toList(); //get Name State and add to cityList

                stateIDList = countryDataRes.areas.states
                    .map((state) => state.stateId)
                    .toList(); //get ID state and add to stateIDList

                cityListReciver = countryDataRes.areas.cities
                    .map((city) => city.cityName)
                    .toList();
                cityIDList = countryDataRes.areas.cities
                    .map((city) => city.cityId)
                    .toList(); //get ID state and add to stateIDList
              })
            : null;
      } else if (response.statusCode == 401) {
        showCustomDialogModal(
            context: context,
            textDesc: "Có lỗi trong việc lấy dữ liệu",
            title: "Thông báo",
            colorButtonOk: Colors.red,
            btnOKText: "Xác nhận",
            typeDialog: "error",
            eventButtonOKPress: () {
              StorageUtils.instance.removeKey(key: 'token');
              StorageUtils.instance.removeKey(key: 'branch_response');
            },
            isTwoButton: false);
      } else {
        log("ERROR handleGetAreaGobal 1");
      }
    } catch (error) {
      log("ERROR handleGetAreaGobal $error 2");
    }
  }

// Hàm xây dựng biểu tượng trạng thái
  Widget _buildStatusIcon(int status) {
    switch (status) {
      case 0:
        return _statusIcon(Icons.circle_notifications,
            Theme.of(context).colorScheme.secondary, "Create Bill");
      case 1:
        return _statusIcon(Icons.check_circle_rounded,
            const Color.fromRGBO(24, 221, 239, 1), "Imported");
      case 2:
        return _statusIcon(Icons.outbound_rounded,
            const Color.fromRGBO(0, 214, 127, 1), "Exported");
      case 3:
        return _statusIcon(Icons.restart_alt_rounded, Colors.red, "Returned");
      default:
        return _statusIcon(FontAwesomeIcons.box, Colors.red, "Hold");
    }
  }

  Widget _statusIcon(IconData icon, Color color, String label) {
    return SizedBox(
      width: 70.w,
      child: Column(
        children: [
          Icon(icon, color: color, size: 40.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: Colors.black87),
          ),
        ],
      ),
    );
  }

// Hàm xây dựng dòng thông tin
  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[700]),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  double _getExtentRatio(int? positionID, bool isShipper, int shipmentStatus) {
    if (isShipper) return 0.3; // Shipper chỉ có nút "Thêm"
    switch (positionID) {
      case 1: // Admin
      case 2: // Kế toán
      case 7: // Chứng từ
        return 0.9; // 3 nút: Thêm, Sửa, Xóa
      case 4: // Sale
      case 5: // Fwd
        return shipmentStatus != 1
            ? 0.6
            : 0.3; // Sửa + Thêm nếu status != 1, ngược lại chỉ Thêm
      case 8: // OPS trưởng
        return 0.3; // Chỉ Thêm
      default:
        return 0.3; // Mặc định chỉ Thêm
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool? isShipper = StorageUtils.instance.getBool(key: 'is_shipper');
    return Scaffold(
        backgroundColor: Colors.white,
        body: MultiBlocListener(
            listeners: [
              BlocListener<DetailsShipmentBloc, DetailsShipmentState>(
                listener: (context, state) {
                  if (state is DetailsShipmentStateSuccess) {
                    detailsShipment = state.detailsShipmentModel;
                    Navigator.pop(context);
                    if (state.isMoreDetail) {
                      showDialogMoreDetailShipment(
                          shipmentdetail: detailsShipment!);
                    } else {
                      showDialogDetailsShipment(
                          shipmentCode:
                              state.detailsShipmentModel.shipment.shipmentCode);
                    }
                  } else if (state is DetailsShipmentStateFailure) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            eventConfirm: () {
                              Navigator.pop(context);
                            },
                            errorText: state.message,
                          );
                        });
                  }
                },
              ),
              BlocListener<DeleteShipmentBloc, DeleteShipmentState>(
                listener: (context, state) {
                  if (state is DeleteShipmentStateSuccess) {
                    showCustomDialogModal(
                        context: context,
                        textDesc: "Xóa shipment thành công",
                        title: "Thông báo",
                        colorButtonOk: Colors.green,
                        btnOKText: "Xác nhận",
                        typeDialog: "success",
                        eventButtonOKPress: () {},
                        isTwoButton: false);
                    init();
                  } else if (state is DeleteShipmentStateFailure) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            eventConfirm: () {
                              Navigator.pop(context);
                            },
                            errorText: state.message,
                          );
                        });
                  }
                },
              ),
            ],
            child: BlocBuilder<GetListDebitShipmentBloc, GetDetailDebitState>(
              builder: (context, state) {
                if (state is GetListShipmentDebitStateloading) {
                  return Center(
                    child: SizedBox(
                      width: 100.w,
                      height: 100.w,
                      child: Lottie.asset('assets/lottie/loading_kango.json'),
                    ),
                  );
                } else if (state is GetListShipmentDebitStateSuccess) {
                  return SlidableAutoCloseBehavior(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // Close any open slidable when tapping outside
                        Slidable.of(context)?.close();
                      },
                      child: RefreshIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        onRefresh: () async {
                          // shipmentItemData.clear();
                          _endDateError = null;
                          _dateStartController.clear();
                          _dateEndController.clear();
                          _startDate = null;
                          _endDate = null;
                          branchID = null;
                          BlocProvider.of<GetListDebitShipmentBloc>(context)
                              .add(FetchListShipmentDebit(
                                  keywords: query, debitID: widget.debitID));
                        },
                        child: Column(
                          children: [
                            Container(
                                width: 1.sw,
                                padding: EdgeInsets.all(10.w),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        onTapOutside: (event) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        // onChanged: searchProduct,
                                        controller: textSearchController,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black),
                                        cursorColor: Colors.black,
                                        onFieldSubmitted: (value) {
                                          searchProduct(
                                              textSearchController.text);
                                        },
                                        decoration: InputDecoration(
                                            suffixIcon: InkWell(
                                              onTap: () {
                                                searchProduct(
                                                    textSearchController.text);
                                              },
                                              child: const Icon(Icons.search),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
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
                                            isDense: true,
                                            hintText: "Tìm kiếm...",
                                            contentPadding:
                                                const EdgeInsets.all(15)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    // FilterTransferWidget(
                                    //     isPakageManger: false,
                                    //     dateStartController:
                                    //         _dateStartController,
                                    //     dateEndController: _dateEndController,
                                    //     selectDayStart: selectDayStart,
                                    //     selectDayEnd: selectDayEnd,
                                    //     getEndDateError: () => _endDateError,
                                    //     clearFliterFunction: clearFilterFuntion,
                                    //     applyFliterFunction:
                                    //         applyFilterFuntion),
                                  ],
                                )),
                            SizedBox(
                              height: 15.h,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollListShipmentFWDController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        width: 1.sw,
                                        child: state.data.isEmpty
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Center(
                                                    child: SizedBox(
                                                      width: 200.w,
                                                      height: 200.w,
                                                      child: Lottie.asset(
                                                          'assets/lottie/empty_box.json',
                                                          fit: BoxFit.contain),
                                                    ),
                                                  ),
                                                  TextApp(
                                                    text:
                                                        "Không tìm thấy đơn hàng!",
                                                    fontsize: 18.sp,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ],
                                              )
                                            : ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: state.hasReachedMax
                                                    ? state.data.length
                                                    : state.data.length + 1,
                                                itemBuilder: (context, index) {
                                                  if (index >=
                                                      state.data.length) {
                                                    return Center(
                                                      child: SizedBox(
                                                        width: 100.w,
                                                        height: 100.w,
                                                        child: Lottie.asset(
                                                            'assets/lottie/loading_kango.json'),
                                                      ),
                                                    );
                                                  } else {
                                                    final dataShipment =
                                                        state.data[index];

                                                    return Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8.h,
                                                              horizontal: 10.w),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.r),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.1),
                                                            spreadRadius: 2,
                                                            blurRadius: 5,
                                                            offset:
                                                                const Offset(
                                                                    0, 3),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Slidable(
                                                        key: ValueKey(
                                                            dataShipment),
                                                        endActionPane:
                                                            ActionPane(
                                                          extentRatio: 0.25,
                                                          motion:
                                                              const ScrollMotion(),
                                                          children: [
                                                            CustomSlidableAction(
                                                              onPressed:
                                                                  (context) async {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  barrierDismissible:
                                                                      false,
                                                                  builder:
                                                                      (context) =>
                                                                          Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          100.w,
                                                                      height:
                                                                          100.w,
                                                                      child: Lottie
                                                                          .asset(
                                                                              'assets/lottie/loading_kango.json'),
                                                                    ),
                                                                  ),
                                                                );
                                                                await Future
                                                                    .delayed(
                                                                        Duration
                                                                            .zero);
                                                                getDetailsShipment(
                                                                    shipmentCode:
                                                                        dataShipment
                                                                            .shipmentCode,
                                                                    isMoreDetail:
                                                                        true);
                                                              },
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Icon(
                                                                    Icons.info,
                                                                    size: 24,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          4.h),
                                                                  Text(
                                                                    'Chi tiết',
                                                                    style: TextStyle(
                                                                        fontSize: 13
                                                                            .sp,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  12.w),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8
                                                                            .r),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: _getStatusColor(
                                                                          dataShipment
                                                                              .shipmentStatus)
                                                                      .withOpacity(
                                                                          0.1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.r),
                                                                ),
                                                                child: Icon(
                                                                  _getStatusIcon(
                                                                      dataShipment
                                                                          .shipmentStatus),
                                                                  color: _getStatusColor(
                                                                      dataShipment
                                                                          .shipmentStatus),
                                                                  size: 36.sp,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 12.w),
                                                              // Thông tin chi tiết
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    // Mã đơn hàng và ngày tạo
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            showDialog(
                                                                              context: context,
                                                                              barrierDismissible: false,
                                                                              builder: (context) => Center(
                                                                                child: SizedBox(
                                                                                  width: 100.w,
                                                                                  height: 100.w,
                                                                                  child: Lottie.asset('assets/lottie/loading_kango.json'),
                                                                                ),
                                                                              ),
                                                                            );
                                                                            await Future.delayed(Duration.zero);
                                                                            getDetailsShipment(
                                                                                shipmentCode: dataShipment.shipmentCode,
                                                                                isMoreDetail: false);
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            dataShipment.shipmentCode.toString(),
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 18.sp,
                                                                              color: Theme.of(context).colorScheme.primary,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          formatDateTime(dataShipment
                                                                              .createdAt
                                                                              .toString()),
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                12.sp,
                                                                            color:
                                                                                Colors.grey[600],
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            8.h),
                                                                    // Người nhận
                                                                    _buildInfoRow(
                                                                      icon: Icons
                                                                          .person,
                                                                      text:
                                                                          "Người nhận: ${dataShipment.receiverContactName}",
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            6.h),

                                                                    SizedBox(
                                                                        height:
                                                                            6.h),
                                                                    // Địa chỉ
                                                                    _buildInfoRow(
                                                                        icon: Icons
                                                                            .local_shipping_rounded,
                                                                        text:
                                                                            "Dịch vụ: ${getServiceName(dataShipment.shipmentServiceId)}"),
                                                                    SizedBox(
                                                                        height:
                                                                            6.h),
                                                                    // Điểm đến
                                                                    _buildInfoRow(
                                                                      icon: Icons
                                                                          .flag,
                                                                      text:
                                                                          "Điểm đến: ${getCountryName(dataShipment.receiverCountryId)}",
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            6.h),
                                                                    // Loại hàng
                                                                    _buildInfoRow(
                                                                      icon: FontAwesomeIcons
                                                                          .box,
                                                                      text:
                                                                          "Type: PACK",
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is GetListShipmentDebitStateFailure) {
                  return AlertDialog(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.w),
                    ),
                    actionsPadding: EdgeInsets.zero,
                    contentPadding: EdgeInsets.only(
                        top: 0.w, bottom: 30.w, left: 35.w, right: 35.w),
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
                            child: Lottie.asset(
                                'assets/lottie/error_dialog.json',
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
                          text: state.message ??
                              "Đã có lỗi xảy ra! \nVui lòng liên hệ quản trị viên.",
                          fontsize: 18.sp,
                          softWrap: true,
                          isOverFlow: false,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: NoDataFoundWidget());
              },
            )));
  }
}
